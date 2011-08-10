#import <Accelerate/Accelerate.h>
#import "PdAudio.h"

@implementation PdAudio

@synthesize numInputChannels;
@synthesize numOutputChannels;
@synthesize blockSize;
@synthesize sampleRate;
@synthesize zgContext;


void renderCallback(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer) {
  PdAudio *pdAudio = (PdAudio *) inUserData;
  
  inBuffer->mAudioDataByteSize = inBuffer->mAudioDataBytesCapacity; // entire buffer is filled
  
  // the buffer contains the input, and when libpd_process_float returns, it contains the output
  short *shortBuffer = (short *) inBuffer->mAudioData;
  
  // process the samples
  zg_context_process_s(pdAudio.zgContext, shortBuffer, shortBuffer);

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
    zgContext = zg_context_new((int) inputChannels, (int) outputChannels, (int) framesPerBlock, sampleRate, NULL, NULL);
    
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
    
    // create three audio buffers to go into the new queue and initialise them
    AudioQueueBufferRef outBuffer;
    for (int i = 0; i < NUM_AUDIO_BUFFERS; i++) {
      err = AudioQueueAllocateBuffer(outAQ, outAsbd.mBytesPerFrame*(UInt32)blockSize, &outBuffer);
      renderCallback(self, outAQ, outBuffer);
    }
    
    err = AudioQueuePrime(outAQ, 0, NULL);
  }
  return self;
}

- (void)dealloc {
  AudioQueueStop(outAQ, YES);
  AudioQueueDispose(outAQ, YES);
  zg_context_delete(zgContext); zgContext = NULL;
  [super dealloc];
}

- (void)play {
  AudioQueueStart(outAQ, NULL);
}

- (void)pause {
  AudioQueuePause(outAQ);
}


@end
