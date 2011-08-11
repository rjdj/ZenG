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
  [builtInObjectLabelsArray release];
  [allObjectLabelsArray release];
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

- (void)windowDidLoad {
  
  // set delegate for canvas view
  canvasView.delegate = self;
  
  // initialise set of all object labels for autocomplete
  builtInObjectLabelsArray = [[NSMutableArray alloc] initWithObjects:@"adc~", @"+~", @"bp~", @"bang~",
                              @"catch~", @"clip~", @"cos~", @"dac~", @"delread~", @"delwrite~", @"/~", @"env~", @"hip~",
                              @"inlet~", @"line~", @"log~", @"lop~", @"min~", @"*~", @"noise~", @"osc~", @"outlet~",
                              @"phasor~", @"print~", @"receive~", @"r~", @"rsqrt~", @"rfft~", @"rifft~", @"send~", @"s~",
                              @"sig~", @"snapshot~", @"sqrt~", @"-~", @"tabplay~", @"tabread~", @"tabread4~", @"throw~",
                              @"vd~", @"vcf~", @"wrap~", @"abs", @"+", @"atan", @"atan2", @"b", @"bang", @"change", @"clip",
                              @"cos", @"cputime", @"dbtopow", @"dbtorms", @"declare", @"del", @"delay", @"/", @"==", @"exp",
                              @"f", @"float", @"ftom", @">", @">=", @"inlet", @"int", @"<", @"<=", @"line", @"list",
                              @"list append", @"list prepend", @"list split", @"list trim", @"loadbang", @"log", @"&&", @"||",
                              @"max", @"msg", @"metro", @"mtof", @"min", @"mod", @"moses", @"*", @"notein", @"!=", @"openpanel",
                              @"outlet", @"pack", @"pipe", @"pow", @"powtodb", @"print", @"random", @"r", @"recieve", @"%",
                              @"rmstodb", @"route", @"samplerate", @"sel", @"select", @"s", @"send", @"sendcontroller", @"sin",
                              @"soundfiler", @"spigot", @"sqrt", @"stripnote", @"-", @"swap", @"switch", @"symbol", @"table",
                              @"tabread", @"tabwrite", @"tan", @"text", @"timer", @"tgl", @"toggle", @"t", @"trigger",
                              @"unpack", @"until", @"v", @"value", @"wrap", nil];
}

- (NSArray *)getAllObjectLabels {
  // returns an array of current object labels for use in autocompletion
  
  NSArray *anArray = [[[NSArray alloc] init] autorelease];
  unsigned int i, count;
  
  if (allObjectLabelsArray == nil) {
    
    allObjectLabelsArray = [builtInObjectLabelsArray mutableCopy];
    
    if (anArray != nil) {
      
      count = (unsigned int)[anArray count];
      
      for (i=0; i<count; i++) {
        
        if ([allObjectLabelsArray indexOfObject:[anArray objectAtIndex:i]] == NSNotFound) {
          [allObjectLabelsArray addObject:[anArray objectAtIndex:i]];
        }
      }
    }
    //[allObjectLabelsArray sortUsingSelector:@selector(compare:)];
  }
  return allObjectLabelsArray;
}
             
@end
