//
//  ObjectTextField.m
//  Zeng
//
//  Created by Joe White on 11/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ObjectTextField.h"


@implementation ObjectTextField

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
      NSLog(@"INIT TEXT FIELD");
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
}

- (void)textDidChange:(NSNotification *)notification {
  
}

- (void)textDidBeginEditing:(NSNotification *)notification {
  NSLog(@"Text BEgin Editing"); 
}

- (void)textDidEndEditing:(NSNotification *)notification {
  
}

- (void)controlTextDidChange:(NSNotification *)obj {
  
}


@end
