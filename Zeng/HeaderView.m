//
//  HeaderView.m
//  ZenGarden_GUI
//
//  Created by Joe White on 03/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HeaderView.h"


@implementation HeaderView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
  NSBezierPath *path = [NSBezierPath bezierPathWithRect:[self bounds]];
  
  [[NSColor whiteColor] setFill];
  [path fill];
  
  NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:1 alpha:1]
                                                       endingColor:[NSColor colorWithCalibratedWhite:0.7 alpha:0.7]];
  [gradient drawInBezierPath:path angle:270];
  [[NSColor grayColor] setStroke];
  [path stroke];
}

@end
