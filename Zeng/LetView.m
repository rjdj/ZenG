//
//  LetView.m
//  ZenGarden_GUI
//
//  Created by Joe White on 17/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LetView.h"
#import "ObjectView.h"

@implementation LetView

@synthesize isInlet;
@synthesize isHighlighted;

- (id)initWithFrame:(NSRect)frame delegate:(NSObject<LetViewDelegate> *)aDelegate {
  self = [super initWithFrame:frame];
  if (self) {
    delegate = [aDelegate retain];
    isHighlighted = NO;
    [self resetTrackingArea];
    [[self window] setAcceptsMouseMovedEvents:YES];
  }
  
  return self;
}

- (void)dealloc {
  [delegate dealloc];
  [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect {
  
  [self drawBackground];

}

- (BOOL)isFlipped { return YES; }

- (void)drawBackground {
  
  if (isHighlighted) {
    [[NSColor redColor] setFill];
  }
  else {
    [[NSColor blackColor] setFill];
  }
  NSRectFill(NSMakeRect(self.bounds.origin.x, self.bounds.origin.y, 12, 4));
}

#pragma mark - Tracking Mouse

- (void)updateTrackingAreas {
  [self resetTrackingArea];
}

- (void)resetTrackingArea {
  NSRect trackingRect = self.bounds; 
  
  [self removeTrackingArea:letTrackingArea];
  [letTrackingArea release];
  letTrackingArea = [[NSTrackingArea alloc] initWithRect:trackingRect
                                                 options: (NSTrackingMouseEnteredAndExited | 
                                                           NSTrackingMouseMoved | 
                                                           NSTrackingActiveInKeyWindow | 
                                                           NSTrackingCursorUpdate)
                                                   owner:self userInfo:nil];
  [self addTrackingArea:letTrackingArea];
}

- (void)mouseDown:(NSEvent *)theEvent {
  if (!isInlet) {
    [delegate mouseDownOfLet:self];
  }
}

- (void)mouseDragged:(NSEvent *)theEvent {
  if (!isInlet) {
    [delegate mouseDraggedOfLet:self withEvent:theEvent];
  }
}

- (void)mouseUp:(NSEvent *)theEvent {
  if (!isInlet) {
    [delegate mouseUpOfLet:self withEvent:theEvent];
  }
}

- (void)mouseEntered:(NSEvent *)theEvent {
  cursor = [NSCursor crosshairCursor];
}

- (void)mouseExited:(NSEvent *)theEvent {
  cursor = [NSCursor arrowCursor];
  [cursor set];
}

- (void)cursorUpdate:(NSEvent *)event {
  [cursor set];
}

@end
