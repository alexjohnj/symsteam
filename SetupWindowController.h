//
//  SetupWindowController.h
//  SymSteam
//
//  Created by Alex Jackson on 03/02/2012.

#import <Cocoa/Cocoa.h>
#import <Growl/Growl.h>
#import "SCSetupController.h"
#import "SCLoginController.h"
#import "SCSteamDiskManager.h"

@interface SetupWindowController : NSWindowController

@property (weak) IBOutlet NSButton *quitSetupButton;
@property (weak) IBOutlet NSButton *chooseSymbolicLinkDestinationButton;
@property (weak) IBOutlet NSTextField *symbolicLinkDestinationField;
@property (weak) IBOutlet NSButton *nextButton;

@property (strong) NSURL *symbolicLinkDestination;

- (IBAction)nextButtonPressed:(id)sender;
- (IBAction)chooseSymbolicLinkDestination:(id)sender;
- (BOOL)checkSymbolicLinkDestinationProvided:(NSURL *)url;
- (IBAction)quitSetup:(id)sender;

- (void)showStartAtLoginSheet;
- (void)alertDidEnd:(NSAlert *)alert resultCode:(NSInteger)resultCode contextInfo:(void *)contextInfo;

@end