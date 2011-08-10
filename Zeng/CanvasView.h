//
//  CanvasView.h
//  ZenGarden_GUI
//
//  Created by Joe White on 04/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ZenGarden.h"
#import "ObjectView.h"


@interface CanvasView : NSView <ObjectViewDelegate> {

  NSObject <ObjectViewDelegate> *delegate;
  
  BOOL isEditModeOn;
  ZGGraph *zgGraph;
  NSMutableSet *objectSet;
  
}

@property (nonatomic, readonly) BOOL isEditModeOn;
@property (nonatomic) ZGGraph *zgGraph;

- (void)drawZgGraph:(ZGGraph *)aZgGraph;

- (void)toggleEditMode:(id)sender;

- (void)drawBackground:(NSRect)rect;

- (void)drawExistingConnections;

@end