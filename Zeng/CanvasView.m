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
@synthesize delegate;


#pragma mark - Initalisation & Deallocation

- (BOOL)isFlipped { return YES; }

- (BOOL)acceptsFirstResponder { return YES; }

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
      objectSet = [[NSMutableSet alloc] init];
      selectionStartPoint = NSZeroPoint;
      selectionEndPoint = NSZeroPoint;
    }
  
    return self;
}

- (void)setZgGraph:(ZGGraph *)graph {
  // set instance zgGraph and objectSet
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
  
  [self setNeedsDisplay:YES];
  [self needsDisplay];
}

- (void)dealloc
{
  [objectSet release];
  [super dealloc];
}


#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect
{
  [self drawBackground:self.bounds];
  
  if (isEditModeOn) {
    [self drawSelectionRectangle];
  }
  
  [self drawExistingConnections];
}

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

- (void)drawExistingConnections {
  
  // for every object in the canvas view
  for (ObjectView *anObject in objectSet) {
    
    // for every outletView in each object
    for (LetView *outletView in anObject.outletArray) {
      
      // set connection start point at current outlet
      NSPoint outletMidPoint = NSMakePoint(NSMidX(outletView.frame), outletView.frame.origin.y);
      NSPoint connectionStartPoint = NSMakePoint(outletMidPoint.x + anObject.frame.origin.x,
                                               outletMidPoint.y + anObject.frame.origin.y);
      
      // query object's outlet array for outletView index
      unsigned int outletIndex = (unsigned int)[anObject.outletArray indexOfObject:outletView];
      unsigned int numConnections = 0;
      
      // return array of connection pairs for give outlet
      ZGConnectionPair *zgConnectionPair =  zg_object_get_connections_at_outlet(anObject.zgObject, outletIndex, &numConnections);
      
      // for number of connected objects to outlet
      for (int i = 0; i < numConnections; i++) {
        
        // find object view (and its associated inlet view) for given zgObject
        ZGObject *zgObject = zgConnectionPair[i].object;
        NSSet *matchingSet = [objectSet objectsPassingTest:^BOOL(id obj, BOOL *stop) {
          ObjectView *objectView = (ObjectView *)obj;
          return (objectView.zgObject == zgObject);
        }];
        ObjectView *objectView = [matchingSet anyObject];
        NSView *inletView = [objectView.inletArray objectAtIndex:zgConnectionPair[i].letIndex];
        
        // set connection end point
        NSPoint inletMidPoint = NSMakePoint(NSMidX(inletView.frame), inletView.frame.origin.y);
        NSPoint connectionEndPoint = NSMakePoint(inletMidPoint.x + objectView.frame.origin.x,
                                                 inletMidPoint.y + objectView.frame.origin.y);
        
        // draw a line from start point to end point
        [[NSColor blackColor] setStroke];
        [NSBezierPath setDefaultLineWidth:2.0f];
        [NSBezierPath strokeLineFromPoint:connectionStartPoint
                                  toPoint:connectionEndPoint];
      }
      
      free(zgConnectionPair);
    }
  }
}

- (void)drawSelectionRectangle {
  
  NSRect selectionRect = [self rectFromTwoPoints:selectionStartPoint toLocation:selectionEndPoint];
  NSBezierPath *selectionPath = [NSBezierPath bezierPathWithRect:selectionRect];
  NSColor *theSelectionColor = [NSColor blackColor];
  CGFloat selectionDashArray[2] = { 5.0, 2.0 };
  [selectionPath setLineWidth:1];
  [selectionPath setLineDash: selectionDashArray count: 2 phase: 0.0];
  [theSelectionColor setStroke];
  [selectionPath stroke];
  
  // highlight objects within selection rect
  selectedObjectsCount = 0;
  for (ObjectView *anObject in objectSet) {
    if (NSIntersectsRect(selectionRect, [anObject frame])) {
      selectedObjectsCount++;
      [(ObjectView *)anObject setIsHighlighted:YES];
    }
    else {
      [(ObjectView *)anObject setIsHighlighted:NO];
    }
  }
}

- (NSRect)rectFromTwoPoints:(NSPoint)firstPoint toLocation:(NSPoint)secondPoint {
  return NSMakeRect(MIN(firstPoint.x, secondPoint.x),
                    MIN(firstPoint.y, secondPoint.y),
                    fabs(firstPoint.x - secondPoint.x),
                    fabs(firstPoint.y - secondPoint.y));
} 

#pragma mark - Mouse Events

- (void)mouseDown:(NSEvent *)theEvent {
  selectionStartPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
}

- (void)mouseDragged:(NSEvent *)theEvent {
  selectionEndPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
  [self setNeedsDisplay:YES];
  [self needsDisplay];
}


- (void)mouseUp:(NSEvent *)theEvent {
  // reset selection path points
  selectionStartPoint = NSZeroPoint;
  selectionEndPoint = NSZeroPoint;
  [self setNeedsDisplay:YES];
  [self needsDisplay];
}

#pragma mark - Autocomplete

- (NSArray *)allObjectLabels {
  return [delegate getAllObjectLabels];
}


#pragma mark - Menu

- (void)toggleEditMode:(id)sender {
  
  isEditModeOn = !isEditModeOn;
  [sender setState:isEditModeOn ? NSOnState : NSOffState];
  
  for (ObjectView *object in objectSet) {
    [object setTextFieldEditable:isEditModeOn];
  }
  
  [self setNeedsDisplay:YES];
  [self needsDisplay];
}

@end
