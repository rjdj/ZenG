//
//  ObjectView.h
//  ObjectDrawing
//
//  Created by Joe White on 03/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LetView.h"
#import "ObjectTextField.h"
#import "ZenGarden.h"

@class ObjectView;

@protocol ObjectViewDelegate

//- (ZGObject *)addNewObjectToGraphWithInitString:(NSString *)initString withLocation:(NSPoint)location;

//- (void)startNewConnectionDrawingFromLet:(LetView *)aLetView;;

//- (void)setNewConnectionEndPointFromLet:(LetView *)aLetView withEvent:(NSEvent *)theEvent;

//- (void)endNewConnectionDrawingFromLet:(LetView *)aLetView withEvent:(NSEvent *)theEvent;

- (NSArray *)allObjectLabels;

@end

@interface ObjectView : NSView <NSTextViewDelegate, NSTextFieldDelegate, LetViewDelegate> {

  // Delegate
  NSObject <ObjectViewDelegate> *delegate;
  
  // Lets
  NSMutableArray *inletArray;
  NSMutableArray *outletArray;

  // Textfield
  ObjectTextField *textField;
//  NSTextView *fieldEditor;
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
  NSPoint mouseDownPositionInObject;
  
  // ZenGarden
  ZGObject *zgObject;
}

@property (nonatomic, readonly) NSMutableArray *inletArray;
@property (nonatomic, readonly) NSMutableArray *outletArray;
@property (nonatomic, readonly) ZGObject *zgObject;
@property (nonatomic) BOOL isHighlighted;

- (id)initWithFrame:(NSRect)frame delegate:(NSObject<ObjectViewDelegate> *)aDelegate;

- (id)initWithObject:(ZGObject *)zgObject andDelegate:(NSObject<ObjectViewDelegate> *)aDelegate;

- (void)drawBackground:(NSRect)rect;

- (void)addTextField:(NSRect)rect;

- (void)setTextFieldEditable:(BOOL)state;

- (void)addLet:(NSPoint)letOrigin isInlet:(BOOL)state;

- (void)addObjectResizeTrackingRect:(NSRect)rect;

- (NSPoint)positionInsideObject:(NSPoint)fromEventPosition;

- (void)removeZGObjectFromZGGraph:(ZGGraph *)graph;

@end
