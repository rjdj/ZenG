//
//  LetView.h
//  ZenGarden_GUI
//
//  Created by Joe White on 17/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class LetView;

@protocol LetViewDelegate

- (void)mouseDownOfLet:(LetView *)aLetView;
- (void)mouseDraggedOfLet:(LetView *)aLetView withEvent:(NSEvent *)theEvent;
- (void)mouseUpOfLet:(LetView *)aLetView withEvent:(NSEvent *)theEvent;

@end

@interface LetView : NSView {
  
  NSObject <LetViewDelegate> *delegate;
  NSCursor *cursor;
  NSTrackingArea *letTrackingArea;
  BOOL isInlet; // YES is Inlet, NO is Outlet
  
  BOOL isHighlighted;
}

@property (nonatomic, readwrite) BOOL isInlet;
@property (nonatomic, readwrite) BOOL isHighlighted;

- (void)drawBackground;

- (void)resetTrackingArea;

@end
