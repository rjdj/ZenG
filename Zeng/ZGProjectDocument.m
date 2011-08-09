//
//  Zeng.m
//  Zeng
//
//  Created by Joe White on 08/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ZGProjectDocument.h"

@implementation ZGProjectDocument


- (id)init {
    self = [super init];
    if (self) {
    // Add your subclass-specific initialization here.
      // If an error occurs here, send a [self release] message and return nil.
    }
    return self;
}

- (void)dealloc {
  [zgProjectWindowController release];
  [super dealloc];
}

- (void)makeWindowControllers {
  // Initialise window controller
  zgProjectWindowController = [[ZGProjectWindowController alloc] initWithWindowNibName:@"Zeng"];
  zgProjectWindowController.projectFilePath = [self fileName];
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController {
  [super windowControllerDidLoadNib:aController];
  // Add any code here that needs to be executed once the windowController has loaded the document's window.
}


- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
  /*
   Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
  You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
  */
  if (outError) {
      *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
  }
  return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
  /*
   Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
   You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
   */
  
  if (outError) {
      *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
  }
  return YES;
}

- (IBAction)toggleEditMode:(id)sender {
  
}

@end
