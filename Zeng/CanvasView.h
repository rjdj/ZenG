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

@class CanvasView;

@protocol CanvasViewDelegate

- (NSArray *)getAllObjectLabels;

@end

@interface CanvasView : NSView <ObjectViewDelegate> {
  
  NSObject <CanvasViewDelegate> *delegate;
  
  BOOL isEditModeOn;
  ZGGraph *zgGraph;
  NSMutableSet *objectSet;
  
  // selection path
  NSPoint selectionStartPoint;
  NSPoint selectionEndPoint;
  int selectedObjectsCount;
  
}

@property (nonatomic, readonly) BOOL isEditModeOn;
@property (nonatomic) ZGGraph *zgGraph;
@property (nonatomic, retain) NSObject <CanvasViewDelegate> *delegate;

- (void)drawZgGraph:(ZGGraph *)aZgGraph;

- (void)toggleEditMode:(id)sender;

- (void)drawBackground:(NSRect)rect;

- (void)drawExistingConnections;

- (void)drawSelectionRectangle;

- (NSRect)rectFromTwoPoints:(NSPoint)firstPoint toLocation:(NSPoint)secondPoint;

@end