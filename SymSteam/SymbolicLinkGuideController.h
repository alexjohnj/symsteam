//
//  SymbolicLinkGuideController.h
//  SymSteam
//
//  Created by Alex Jackson on 07/04/2012.
//

#import <Cocoa/Cocoa.h>
#import "SymbolicLinkCreator.h"

@interface SymbolicLinkGuideController : NSWindowController

@property (copy) __block NSURL *steamAppsLocation;
@property (weak) __block IBOutlet NSButton *createSymbolicLinkButton;

- (IBAction)locateSteamAppsFolder:(id)sender;
- (IBAction)createSymbolicLink:(id)sender;
- (IBAction)dismissSheet:(id)sender;

- (void)sheetDidEnd:(NSWindow *)sheet resultCode:(NSInteger)resultCode contextInfo:(void *)contextInfo;

@end
