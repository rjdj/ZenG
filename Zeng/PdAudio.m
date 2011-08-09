#import <Accelerate/Accelerate.h>
#import "PdAudio.h"

@implementation PdAudio

@synthesize numInputChannels;
@synthesize numOutputChannels;
@synthesize blockSize;
@synthesize sampleRate;
@synthesize contextSet;


PdAudio *globalPdAudio = nil;

+ (PdAudio *)controller {
  return globalPdAudio;
}

void renderCallback(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer) {
  PdAudio *pdAudio = (PdAudio *) inUserData;

  // normal audio thread priority is 0.5 (default). Set it to be as high as possible.
  [NSThread setThreadPriority:1.0]; // necessary?
  
  // the buffer contains the input, and when libpd_process_float returns, it contains the output
  short *shortBuffer = (short *) inBuffer->mAudioData;
  
  inBuffer->mAudioDataByteSize = inBuffer->mAudioDataBytesCapacity; // entire buffer is filled
  int floatBufferLength = inBuffer->mAudioDataBytesCapacity / sizeof(short); // total samples
  float floatBuffer[floatBufferLength];
  
  // convert short to float, and uninterleave the samples into the float buffer
  // allow fallthrough in all cases
  switch (pdAudio.numInputChannels) {
    default: { // input channels > 2
      for (int i = 3; i < pdAudio.numInputChannels; ++i) {
        vDSP_vflt16(shortBuffer+i-1, pdAudio.numInputChannels, floatBuffer+(i-1)*pdAudio.blockSize, 1, pdAudio.blockSize);
      }
    }
    case 2: vDSP_vflt16(shortBuffer+1, pdAudio.numInputChannels, floatBuffer+pdAudio.blockSize, 1, pdAudio.blockSize);
    case 1: vDSP_vflt16(shortBuffer, pdAudio.numInputChannels, floatBuffer, 1, pdAudio.blockSize); break;
    case 0: memset(inBuffer->mAudioData, 0, inBuffer->mAudioDataBytesCapacity); break; // clear the floatBuffer for input
  }
  
  // convert samples to range of [-1,+1]
  float a = 0.000030517578125f;
  vDSP_vsmul(floatBuffer, 1, &a, floatBuffer, 1, floatBufferLength);
  
  // process the samples
  float outputFloatBuffer[pdAudio.blockSize];
  memset(outputFloatBuffer, 0, pdAudio.blockSize*sizeof(float));
  float tempFloatBuffer[pdAudio.blockSize];
  for (NSValue *zgContext in pdAudio.contextSet) {
    zg_context_process([zgContext pointerValue], floatBuffer, tempFloatBuffer);
    vDSP_vmul(tempFloatBuffer, 1, outputFloatBuffer, 1, outputFloatBuffer, 1, pdAudio.blockSize);
  }

  // clip the output to [-1,+1]
  float min = -1.0f;
  float max = 1.0f;
  vDSP_vclip(floatBuffer, 1, &min, &max, floatBuffer, 1, floatBufferLength);
  
  // scale the floating-point samples to short range
  a = 32767.0f;
  vDSP_vsmul(floatBuffer, 1, &a, floatBuffer, 1, floatBufferLength);
  
  // convert float to short and interleave into short buffer
  // allow fallthrough in all cases
  switch (pdAudio.numOutputChannels) {
    default: { // output channels > 2
      for (int i = 3; i < pdAudio.numOutputChannels; ++i) {
        vDSP_vfix16(floatBuffer+(i-1)*pdAudio.blockSize, pdAudio.numOutputChannels, shortBuffer+i-1, 1, pdAudio.blockSize);
      }
    }
    case 2: vDSP_vfix16(floatBuffer+pdAudio.blockSize, 1, shortBuffer+1, pdAudio.numOutputChannels, pdAudio.blockSize);
    case 1: vDSP_vfix16(floatBuffer, 1, shortBuffer, pdAudio.numOutputChannels, pdAudio.blockSize); break;
    case 0: memset(inBuffer->mAudioData, 0, inBuffer->mAudioDataBytesCapacity); break; // clear the output
  }

  AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
}


#pragma mark - PdAudio

#define NUM_AUDIO_BUFFERS 5
- (id)initWithInputChannels:(NSUInteger)inputChannels OutputChannels:(NSUInteger)outputChannels
    blockSize:(NSUInteger)framesPerBlock andSampleRate:(Float64)samplerate {
  self = [super init];
  if (self != nil) {
    numInputChannels = inputChannels;
    numOutputChannels = outputChannels;
    blockSize = framesPerBlock;
    sampleRate = samplerate;
    contextSet = [[NSMutableSet alloc] init];
    
    // configure the output audio format to standard 16-bit stereo
    AudioStreamBasicDescription outAsbd;
    outAsbd.mSampleRate = sampleRate;
    outAsbd.mFormatID = kAudioFormatLinearPCM;
    outAsbd.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    outAsbd.mBytesPerPacket = 4;
    outAsbd.mFramesPerPacket = 1;
    outAsbd.mBytesPerFrame = 4;
    outAsbd.mChannelsPerFrame = 2;
    outAsbd.mBitsPerChannel = 16;
    outAsbd.mReserved = 0;
    
    // create the new audio buffer
    // http://developer.apple.com/library/mac/#documentation/MusicAudio/Reference/AudioQueueReference/Reference/reference.html
    OSStatus err = AudioQueueNewOutput(&outAsbd, renderCallback, self, NULL, kCFRunLoopCommonModes, 0, &outAQ);
    AudioQueueSetParameter(outAQ, kAudioQueueParam_Volume, 1.0f);
    
    // create the new context
    //zgContext = zg_context_new(2, 2, (int)blockSize, 44100.0f, NULL, NULL);
    
    // create three audio buffers to go into the new queue and initialise them
    AudioQueueBufferRef outBuffer;
    for (int i = 0; i < NUM_AUDIO_BUFFERS; i++) {
      err = AudioQueueAllocateBuffer(outAQ, outAsbd.mBytesPerFrame*blockSize, &outBuffer);
      renderCallback(self, outAQ, outBuffer);
    }
    
    err = AudioQueuePrime(outAQ, 0, NULL);
  }
  globalPdAudio = self;
  return self;
}

- (void)dealloc {
  AudioQueueStop(outAQ, YES);
  AudioQueueDispose(outAQ, YES);
  for (NSValue *zgContext in contextSet) {
    zg_context_delete((ZGContext *) [zgContext pointerValue]);
  }
  [contextSet release];
  [super dealloc];
}

- (ZGContext *)newContext {
  ZGContext *zgContext = zg_context_new(numInputChannels, numOutputChannels, blockSize, sampleRate, NULL, NULL);
  [contextSet addObject:[NSValue valueWithPointer:zgContext]];
  return zgContext;
}

- (void)play {
  AudioQueueStart(outAQ, NULL);
}

- (void)pause {
  AudioQueuePause(outAQ);
}


@end
