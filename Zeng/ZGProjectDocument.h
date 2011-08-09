//
//  Zeng.h
//  Zeng
//
//  Created by Joe White on 08/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ZGProjectWindowController.h"
#import "ZenGarden.h"
#import "PdAudio.h"

@interface ZGProjectDocument : NSDocument {

  ZGProjectWindowController *zgProjectWindowController;
  PdAudio *pdAudio;
  
}

- (IBAction)toggleEditMode:(id)sender;

@end
