//
//  SetupWindowController.h
//  SymSteam
//
//  Created by Alex Jackson on 03/02/2012.

#import <Cocoa/Cocoa.h>
#import <Growl/Growl.h>
#import "SymbolicLinkGuideController.h"

@interface SetupWindowController : NSWindowController

@property (weak) IBOutlet NSTextField *pathToSymLinkField;
@property (weak) IBOutlet NSTextField *pathToNonSymLinkField;
@property (weak) IBOutlet NSButton *continueButton;
@property (weak) IBOutlet NSButton *createSymbolicLinkButton;
@property (weak) IBOutlet NSButton *quitSetupButton;

@property (assign) BOOL symLinkPathProvided;
@property (assign) BOOL nonSymLinkPathProvided;
@property (assign) BOOL formComplete;

@property (strong) SymbolicLinkGuideController *symbolicLinkGuideSheet;

- (void)checkPathsProvided;

- (IBAction)choosePathToSymLink:(id)sender;
- (IBAction)choosePathToNonSymLink:(id)sender;
- (IBAction)doneButtonPressed:(id)sender;
- (IBAction)createSymbolicLink:(id)sender;
- (IBAction)quitSetup:(id)sender;


- (void)sheetDidEnd:(NSWindow *)sheet resultCode:(NSInteger)resultCode contextInfo:(void *)contextInfo;
@end