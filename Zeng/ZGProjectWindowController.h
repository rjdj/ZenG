//
//  ZGProjectWindowController.h
//  Zeng
//
//  Created by Joe White on 09/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ZenGarden.h"
#import "PdAudio.h"
#import "HeaderView.h"
#import "ProjectView.h"
#import "HelpView.h"
#import "CanvasView.h"

@interface ZGProjectWindowController : NSWindowController <CanvasViewDelegate> {
  
  HeaderView *headerView;
  ProjectView *projectView;
  HelpView *helpView;
  CanvasView *canvasView;
  
  PdAudio *pdAudio;
  ZGContext *zgContext;
  
  NSString *projectFilePath;
  NSMutableArray *builtInObjectLabelsArray;
  NSMutableArray *allObjectLabelsArray;
  
  BOOL isDSPSwitchOn;
  
@private
  
}

@property (nonatomic, retain) IBOutlet HeaderView *headerView;
@property (nonatomic, retain) IBOutlet ProjectView *projectView;
@property (nonatomic, retain) IBOutlet HelpView *helpView;
@property (nonatomic, retain) IBOutlet CanvasView *canvasView;
@property (nonatomic, retain) NSString *projectFilePath;

- (IBAction)toggleDSPSwitch:(id)sender;

@end
