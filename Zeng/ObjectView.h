//
//  ObjectView.h
//  ObjectDrawing
//
//  Created by Joe White on 03/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LetView.h"
#import "ZenGarden.h"


@protocol ObjectViewDelegate

- (ZGObject *)addNewObjectToGraphWithInitString:(NSString *)initString withLocation:(NSPoint)location;

- (void)startNewConnectionDrawingFromLet:(LetView *)aLetView;;

- (void)setNewConnectionEndPointFromLet:(LetView *)aLetView withEvent:(NSEvent *)theEvent;

- (void)endNewConnectionDrawingFromLet:(LetView *)aLetView withEvent:(NSEvent *)theEvent;

- (NSArray *)allObjectLabels;

@end

@interface ObjectView : NSView <NSTextViewDelegate, NSTextFieldDelegate, LetViewDelegate> {

  // Delegate
  NSObject <ObjectViewDelegate> *delegate;
  
  // Lets
  NSMutableArray *inletArray;
  NSMutableArray *outletArray;
  
  // Textfield
  NSTextField *textField;
  NSTextView *fieldEditor;
  BOOL didTextChange;
  BOOL isObjectNew;
  NSString *previousString;
  
  BOOL completePosting;
  
  // Tracking Rectangles
  NSRect objectResizeTrackingRect;
  NSTrackingArea *objectResizeTrackingArea;
  NSCursor *cursor;
  
  // Background
  BOOL isHighlighted;
  NSColor *backgroundColour;
  
  // ZenGarden
  ZGObject *zgObject;
}

@property (nonatomic, readonly) NSMutableArray *inletArray;
@property (nonatomic, readonly) NSMutableArray *outletArray;
@property (nonatomic, readonly) BOOL isHighlighted;
@property (nonatomic, readonly) ZGObject *zgObject;

- (id)initWithObject:(ZGObject *)zgObject andDelegate:(NSObject<ObjectViewDelegate> *)aDelegate;

- (id)initWithFrame:(NSRect)frame delegate:(NSObject<ObjectViewDelegate> *)aDelegate;

- (void)drawBackground:(NSRect)rect;

- (void)highlightObject:(BOOL)state;

- (void)addTextField:(NSRect)rect;

- (void)setTextFieldEditable:(BOOL)state;

- (void)addLet:(NSPoint)letOrigin isInlet:(BOOL)isInlet;

- (void)addObjectResizeTrackingRect:(NSRect)rect;

- (NSPoint)positionInsideObject:(NSPoint)fromEventPosition;

- (void)removeZGObjectFromZGGraph:(ZGGraph *)graph;

@end
