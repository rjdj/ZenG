//
//  CanvasView.m
//  ZenGarden_GUI
//
//  Created by Joe White on 04/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CanvasView.h"

@implementation CanvasView

@synthesize isEditModeOn;
@synthesize zgGraph;

- (BOOL)isFlipped { return YES; }

- (BOOL)acceptsFirstResponder { return YES; }

- (void)mouseDown:(NSEvent *)theEvent {
  NSLog(@"Mouse Down");

}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)setZgGraph:(ZGGraph *)graph {
  NSLog(@"setZgGraph");
  // set instance zgGraph
  zgGraph = graph;
  
  // query graph for all objects
  unsigned int numObjects = 0;
  ZGObject **zgObjectArray = zg_graph_get_objects(zgGraph, &numObjects);
  
  // create array of ObjectViews representing each zgObject
  for (int i = 0; i < numObjects; i++) {
    ObjectView *objectView = [[[ObjectView alloc] initWithObject:zgObjectArray[i]
                                                     andDelegate:self] autorelease];
    [objectSet addObject:objectView];
    [self addSubview:objectView];
  }
  
  free(zgObjectArray);
  
  // set up all connections
  // set up everything necessary to draw
  
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    
  }
  return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect
{
  // Drawing code here
  [self drawBackground:self.bounds];
}

- (void)toggleEditMode:(id)sender {
  
  isEditModeOn = !isEditModeOn;
  NSLog(@"EditMode %d", isEditModeOn);
  [sender setState:isEditModeOn ? NSOnState : NSOffState];
  
  // Set objects to be editable
  /*
   for (ObjectView *object in arrayOfObjects) {
   [object setTextFieldEditable:isEditModeOn];
   }
   */
   [self setNeedsDisplay:YES];
   [self needsDisplay];
}

#pragma mark - Background Drawing

- (void)drawBackground:(NSRect)rect {
  if (isEditModeOn) {
    [[[NSColor blueColor] colorWithAlphaComponent:0.2f] setFill];
    [NSBezierPath fillRect:rect];
  }
  else {
    [[NSColor whiteColor] setFill];
    NSRectFill(rect);
  }
}

@end
