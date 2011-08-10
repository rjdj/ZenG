#import <AudioToolbox/AudioToolbox.h>
#import <AudioUnit/AudioUnit.h>
#import <Foundation/Foundation.h>

#import "ZenGarden.h"

// http://developer.apple.com/library/mac/#documentation/MusicAudio/Conceptual/AudioQueueProgrammingGuide/Introduction/Introduction.html
// http://developer.apple.com/library/mac/#documentation/MusicAudio/Reference/AudioQueueReference/Reference/reference.html
@interface PdAudio : NSObject {
  AudioQueueRef outAQ;
  NSUInteger numInputChannels;
  NSUInteger numOutputChannels;
  NSUInteger blockSize;
  Float64 sampleRate;
  ZGContext *zgContext;
}

@property (nonatomic, readonly) NSUInteger numInputChannels;
@property (nonatomic, readonly) NSUInteger numOutputChannels;
@property (nonatomic, readonly) NSUInteger blockSize;
@property (nonatomic, readonly) Float64 sampleRate;
@property (nonatomic, readonly) ZGContext *zgContext;

- (id)initWithInputChannels:(NSUInteger)inputChannels OutputChannels:(NSUInteger)outputChannels
    blockSize:(NSUInteger)framesPerBlock andSampleRate:(Float64)sampleRate;

- (void)play;
- (void)pause;

@end
