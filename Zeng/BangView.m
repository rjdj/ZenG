//
//  BangView.m
//  ZenGarden_GUI
//
//  Created by Joe White on 20/07/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BangView.h"


@implementation BangView

@synthesize isHighlighted;

- (id)initWithFrame:(NSRect)frame delegate:(NSObject<BangViewDelegate> *)aDelegate {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
      [self highlightObject:NO];
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect
{
  
  NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:
                          NSMakeRect(self.bounds.origin.x + 5, self.bounds.origin.y + 5,
                                     self.bounds.size.width - 10, self.bounds.size.height - 10) 
                        xRadius:20 yRadius:20];

  [backgroundColour setFill];
  [path fill];

  [[NSColor blackColor] setStroke];
  [path stroke];
}


- (BOOL)isFlipped { return YES; }

- (BOOL)acceptsFirstResponder { return YES; }

- (void)mouseDown:(NSEvent *)theEvent {
  NSLog(@"Mouse Down");
  backgroundColour = [NSColor redColor];
  [self setNeedsDisplay:YES];
  [self needsDisplay];
  [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(resetBangColour) userInfo:nil repeats:NO];

}

- (void)mouseUp:(NSEvent *)theEvent {
  NSLog(@"Mouse Up");
}

- (void)resetBangColour {
  [self highlightObject:NO];
}

- (void)highlightObject:(BOOL)state {
  if (state) {
    isHighlighted = YES;
    backgroundColour = [NSColor greenColor];
  }
  else {
    isHighlighted = NO;
    backgroundColour = [NSColor blueColor];
  }
  [self setNeedsDisplay:YES];
  [self needsDisplay];
}


@end
