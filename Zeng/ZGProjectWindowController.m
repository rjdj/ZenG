//
//  ZGProjectWindowController.m
//  Zeng
//
//  Created by Joe White on 09/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ZGProjectWindowController.h"


@implementation ZGProjectWindowController

@synthesize headerView;
@synthesize projectView;
@synthesize helpView;
@synthesize canvasView;
@synthesize projectFilePath;

void zgCallbackFunction(ZGCallbackFunction function, void *userData, void *ptr) {
  switch (function) {
    case ZG_PRINT_STD: {
      NSLog(@"%s", ptr);
      break;
    }
    case ZG_PRINT_ERR: {
      NSLog(@"ERROR: %s", ptr);
      break;
    }
    default: {
      NSLog(@"unknown ZGCallbackFunction received: %i", function);
      break;
    }
  }
}

- (id)initWithWindowNibName:(NSString *)windowNibName {
  self = [super initWithWindowNibName:windowNibName];
  if (self) {
    // Add pdAudio and zgContext 
    pdAudio = [[PdAudio alloc] initWithInputChannels:0 OutputChannels:2 blockSize:256
        andSampleRate:44100.0];
    [pdAudio play];
    zgContext = pdAudio.zgContext;
    
    
    [self showWindow:windowNibName];
  }
  return self;
}

- (void)dealloc
{
  [pdAudio pause];
  [pdAudio release];
  [super dealloc];
}

- (void)setProjectFilePath:(NSString *)projectFilePath {
  
  // create new zgGraph based on project file path
  NSString *directory = [[projectFilePath stringByDeletingLastPathComponent] stringByAppendingString:@"/"];
  NSString *fileName = [projectFilePath lastPathComponent];
  ZGGraph *zgGraph = zg_context_new_graph_from_file(zgContext,
                                                    [directory cStringUsingEncoding:NSASCIIStringEncoding],
                                                    [fileName cStringUsingEncoding:NSASCIIStringEncoding]);
  if (zgGraph) {
    // attach new graph to current context
    zg_graph_attach(zgGraph);
    
    // attach new graph to canvasView
    canvasView.zgGraph = zgGraph;
  }
}

@end
