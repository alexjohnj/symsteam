//
//  SymbolicLinkGuideController.h
//  SymSteam
//
//  Created by Alex Jackson on 07/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SymbolicLinkGuideController : NSWindowController

@property (copy) __block NSURL *steamAppsLocation;
@property (weak) __block IBOutlet NSButton *createSymbolicLinkButton;

- (IBAction)locateSteamAppsFolder:(id)sender;
- (IBAction)createSymbolicLink:(id)sender;
- (IBAction)dismissSheet:(id)sender;

- (void)sheetDidEnd:(NSWindow *)sheet resultCode:(NSInteger)resultCode contextInfo:(void *)contextInfo;

@end
