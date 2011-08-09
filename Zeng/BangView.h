//
//  BangView.h
//  ZenGarden_GUI
//
//  Created by Joe White on 20/07/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LetView.h"

@protocol BangViewDelegate

@end

@interface BangView : NSView {
  
  // Delegate
  NSObject <BangViewDelegate> *delegate;
  
  BOOL isHighlighted;
  NSColor *backgroundColour;
    
}

@property (nonatomic, readonly) BOOL isHighlighted;

- (void)highlightObject:(BOOL)state;

- (void)resetBangColour;

@end
