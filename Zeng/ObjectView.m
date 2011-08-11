//
//  ObjectView.m
//  ObjectDrawing
//
//  Created by Joe White on 03/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ObjectView.h"
#import "CanvasView.h"


@implementation ObjectView

@synthesize inletArray;
@synthesize outletArray;
@synthesize isHighlighted;
@synthesize zgObject;


#pragma mark - Initalisation & Deallocation

- (BOOL)isFlipped { return YES; }

- (BOOL)acceptsFirstResponder { return YES; }

- (id)initWithFrame:(NSRect)frame delegate:(NSObject<ObjectViewDelegate> *)aDelegate {
  self = [super initWithFrame:frame];
  if (self) {
    
    delegate = [aDelegate retain];
    inletArray = [[NSMutableArray alloc] init];
    outletArray = [[NSMutableArray alloc] init]; 
    
    isObjectNew = YES;
    zgObject = NULL;

    // text initialisations
    [self addTextField:frame];
    didTextChange = NO;
    previousString = NULL;
    
    mouseDownPositionInObject = NSZeroPoint;
    [self setIsHighlighted:NO];
    
    // set up tracking areas
    [self addObjectResizeTrackingRect:frame];
    objectResizeTrackingArea = [[NSTrackingArea alloc] 
                                initWithRect:objectResizeTrackingRect
                                options: (NSTrackingMouseEnteredAndExited | 
                                          NSTrackingMouseMoved | 
                                          NSTrackingActiveInKeyWindow|
                                          NSTrackingCursorUpdate)
                                owner:self userInfo:nil];
    [self addTrackingArea:objectResizeTrackingArea];
    
  }
  return self;
}

- (id)initWithObject:(ZGObject *)aZgObject andDelegate:(NSObject<ObjectViewDelegate> *)aDelegate {
  // when drawing objects from a graph
  // get object canvas position
  float canvasX = 0.0f;
  float canvasY = 0.0f;
  zg_object_get_canvas_position(aZgObject, &canvasX, &canvasY);
  NSRect frame = NSMakeRect(canvasX, canvasY, 70.0f, 30.0f);
  
  // initialise object
  self = [self initWithFrame:frame delegate:aDelegate];
  if (self != nil) {
    
    // get object textfield string and set it
    zgObject = aZgObject;
    char *str = zg_object_to_string(zgObject);
    [textField setStringValue:[NSString stringWithCString:str encoding:NSASCIIStringEncoding]];
    free(str);
    
    // add inlets
    for (int i = 0; i < zg_object_get_num_inlets(zgObject); i++) {
      [self addLet:NSMakePoint(self.bounds.origin.x + 10 + 38*i, 3) isInlet:YES];
    }
    // add outlets
    for (int i = 0; i < zg_object_get_num_outlets(zgObject); i++) {
      [self addLet:NSMakePoint(self.bounds.origin.x + 10 + 70*i, self.bounds.size.height - 6) isInlet:NO];
    }
    
  }
  return self;
}

- (void)dealloc {
  [delegate release];
  [LetView release];
  [textField release];
  [super dealloc];
}


#pragma mark - Drawing

- (void)setIsHighlighted:(BOOL)state {
  [self setNeedsDisplay:YES];
  [self needsDisplay];
}

- (void)drawRect:(NSRect)dirtyRect {
  
  if ([(CanvasView *)self.superview isEditModeOn]) {
    // if object is first responder or manually highlighted
    if ([[self window] firstResponder] == self && ([[self window] isKeyWindow]) || (isHighlighted == YES)) {
      
      // draw focus ring
      [NSGraphicsContext saveGraphicsState];
      NSSetFocusRingStyle(NSFocusRingOnly);
      [[NSBezierPath bezierPathWithRoundedRect:[self bounds] xRadius:5 yRadius:5] fill];
      [NSGraphicsContext restoreGraphicsState];
    }
  }
  
  [textField setFrame:NSMakeRect(self.bounds.origin.x + 5,
                                 self.bounds.origin.y + 8,
                                 self.bounds.size.width - 10,
                                 self.bounds.size.height - 14)];
  
  [self drawBackground:self.bounds];
}

- (void)drawBackground:(NSRect)rect {
   
  NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(rect.origin.x + 2,
                                                                          rect.origin.y + 2.5,
                                                                          rect.size.width - 4,
                                                                          rect.size.height - 4)
                                                               xRadius:4 yRadius:4];
  
  [[NSColor whiteColor] setFill];
  [path fill];
  
  NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:1 alpha:1]
                                                       endingColor:[NSColor colorWithCalibratedWhite:0.7 alpha:0.7]];
  [gradient drawInBezierPath:path angle:90.0];
  
  [path setLineWidth:1];
  NSColor *outsideStroke;
  outsideStroke = [NSColor colorWithCalibratedRed:0.7 green:0.7 blue:0.8 alpha:1.0];
  [outsideStroke setStroke];
  [path stroke];
}

- (void)addLet:(NSPoint)letOrigin isInlet:(BOOL)state {
  
  // initialise let view and add it as a subview
  NSRect letRect = NSMakeRect(letOrigin.x, letOrigin.y, 12, 4);
  LetView *aLetView = [[LetView alloc] initWithFrame:letRect delegate:self];
  [self addSubview:aLetView];
  
  [aLetView setIsInlet:state];
  
  // store let view in to appropriate array
  if (state) {
    [inletArray addObject:aLetView]; 
  }
  else {
    [outletArray addObject:aLetView];
  }
}


#pragma mark - Let Events

- (void)mouseDownOfLet:(LetView *)aLetView {
  [delegate startNewConnectionDrawingFromLet:aLetView];
}

- (void)mouseDraggedOfLet:(LetView *)aLetView withEvent:(NSEvent *)theEvent {
  [delegate setNewConnectionEndPointFromLet:aLetView withEvent:theEvent];
}

- (void)mouseUpOfLet:(LetView *)aLetView withEvent:(NSEvent *)theEvent {
  [delegate endNewConnectionDrawingFromLet:aLetView withEvent:theEvent];
}


#pragma mark - TextField & Events

- (void)addTextField:(NSRect)rect {
  textField = [[NSTextField alloc] initWithFrame:NSMakeRect(self.bounds.origin.x + 5,
                                                            self.bounds.origin.y + 8,
                                                            self.bounds.size.width - 10,
                                                            self.bounds.size.height - 14)];
  [textField setEditable:[(CanvasView *)self.superview isEditModeOn]];
  [textField setSelectable:[(CanvasView *)self.superview isEditModeOn]];
  [textField setBezeled:NO];
  [textField setDrawsBackground:NO];
  [textField setFont:[NSFont fontWithName:@"Monaco" size:12.0]];
  [textField setFocusRingType:NSFocusRingOnly];
  [self addSubview:textField];
  [textField setDelegate:self];
}

- (void)setTextFieldEditable:(BOOL)state {
  [textField setEditable:state];
  [textField setSelectable:state];
}

- (void)controlTextDidBeginEditing:(NSNotification *)obj {
  [self setIsHighlighted:YES];
  
  // (joewhite4): Not meant to do this I think. Needed for auto complete though.
  //  fieldEditor = [[obj userInfo] objectForKey:@"NSFieldEditor"];  
  //  [fieldEditor setDelegate:self];
  previousString = NULL;
}

- (void)textDidChange:(NSNotification *)notification {
  
  NSLog(@"%@",[textField stringValue]);
  if (!isObjectNew) {
    didTextChange = YES;
  }
  // Currently an infinite loop
  //[fieldEditor completionsForPartialWordRange:NSRangeFromString([textField stringValue]) indexOfSelectedItem:0];
  //[fieldEditor complete:nil];
  
  BOOL textDidNotChange = [previousString isEqualToString:[fieldEditor string]];
  
  if( textDidNotChange ){
    return;
  }
  else {
    previousString = [[fieldEditor string] copy];
    [fieldEditor complete:nil];
  }
}

- (BOOL)textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
  
  if (commandSelector == @selector(delete:)) {
    NSLog(@"Backspace has been pressed");
  }
  if (commandSelector == @selector(cancelOperation:)) {
    NSLog(@"escape key has been pressed");
  }
  return YES;
}

- (NSArray *)textView:(NSTextView *)textView completions:(NSArray *)words 
  forPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index {
  // returns list of available objects based on text input from the field editor
  
  NSMutableArray *matches = [NSMutableArray array];
  NSString *partialString = [[textView string] substringWithRange:charRange];
  NSArray *keywords = [delegate allObjectLabels];
  unsigned int i;
  unsigned int count = (unsigned int)[keywords count];
  NSString *aString;
  
  for (i=0; i<count; i++) {
    aString = [keywords objectAtIndex:i];
    if ([aString rangeOfString:partialString options:NSAnchoredSearch | NSCaseInsensitiveSearch
                        range:NSMakeRange(0, [aString length])].location != NSNotFound) {
      [matches addObject:aString];
    }
  }
  [matches sortUsingSelector:@selector(compare:)];
  
  return matches;
}

- (void)textDidEndEditing:(NSNotification *)notification {
  // if textfield changes reinstantiate object 
  NSLog(@"Ended editing");
  if (didTextChange) {
    [self removeZGObjectFromZGGraph:[(CanvasView *)self.superview zgGraph]];
    for (LetView *aLetView in inletArray) {
      [aLetView removeFromSuperview];
    }
    for (LetView *aLetView in outletArray) {
      [aLetView removeFromSuperview];
    }
    [inletArray removeAllObjects];
    [outletArray removeAllObjects];
    didTextChange = NO;
  }
  // Add zgObject
  zgObject = [delegate addNewObjectToGraphWithInitString:[textField stringValue]
                                            withLocation:self.frame.origin];
  if (zgObject == NULL) {
    NSLog(@"zgObject could not be created.");
  } else {
    // Add inlets
    for (int i = 0; i < zg_object_get_num_inlets(zgObject); i++) {
      [self addLet:NSMakePoint(self.bounds.origin.x + 10 + 38*i, 3) isInlet:YES];
    }
    // Add outlets
    for (int i = 0; i < zg_object_get_num_outlets(zgObject); i++) {
      [self addLet:NSMakePoint(self.bounds.origin.x + 10 + 70*i, self.bounds.size.height - 6) isInlet:NO];
    }
  }
  isObjectNew = NO;
  [self setIsHighlighted:NO];
  [[textField window] endEditingFor: nil];
  [[textField window] makeFirstResponder: nil];
}


#pragma mark - Mouse events

- (void)mouseDown:(NSEvent *)theEvent {
  // convert mouse location to object view coordinate base
  mouseDownPositionInObject = [self convertPoint:[theEvent locationInWindow] fromView:nil];
  
  [[self window] resignFirstResponder];
  [self becomeFirstResponder];
  [self setNeedsDisplay:YES];
  [self needsDisplay];
}

- (void)mouseDragged:(NSEvent *)theEvent {
  
  if ([(CanvasView *)self.superview isEditModeOn]) {
    // convert mouse location to canvas view coordinate base
    NSPoint mouseDraggedPositionInObject = [self convertPoint:[theEvent locationInWindow] fromView:nil]; 
    NSPoint mousePositionInCanvas = [self convertPoint:mouseDraggedPositionInObject toView:self.superview];   
    
    // adjust object origin based on mouseDownPositionInObject
    [self setFrame:NSMakeRect(mousePositionInCanvas.x - mouseDownPositionInObject.x,
                              mousePositionInCanvas.y - mouseDownPositionInObject.y,
                              self.frame.size.width, self.frame.size.height)];
    
    [self.superview setNeedsDisplay:YES];
    [self setNeedsDisplay:YES];
    
    [self.superview needsDisplay];
    [self needsDisplay];
  }
}

- (void)mouseUp:(NSEvent *)theEvent {
  mouseDownPositionInObject = NSZeroPoint;
}

- (void)mouseEntered:(NSEvent *)theEvent { cursor = [NSCursor resizeRightCursor]; }

- (void)mouseExited:(NSEvent *)theEvent { cursor = [NSCursor arrowCursor]; }

- (void)cursorUpdate:(NSEvent *)event { [cursor set]; }

- (void)addObjectResizeTrackingRect:(NSRect)rect {
  objectResizeTrackingRect = NSMakeRect(self.frame.size.width - 10, 20,
                                        10, self.frame.size.height - 40);
}

- (void)updateTrackingAreas {
  
  [self addObjectResizeTrackingRect:self.frame];
  
  [self removeTrackingArea:objectResizeTrackingArea];
  [objectResizeTrackingArea release];
  objectResizeTrackingArea = [[NSTrackingArea alloc] 
                              initWithRect:objectResizeTrackingRect
                              options: (NSTrackingMouseEnteredAndExited |
                                        NSTrackingMouseMoved |
                                        NSTrackingActiveInKeyWindow | 
                                        NSTrackingCursorUpdate)
                              owner:self userInfo:nil];
  [self addTrackingArea:objectResizeTrackingArea];
}


#pragma mark - ZenGarden Objects

- (void)removeZGObjectFromZGGraph:(ZGGraph *)graph {
  if (zgObject != NULL) {
    zg_object_remove(zgObject);
  }
  else {
    NSLog(@"No ZGObject to remove");
  }
}

@end
