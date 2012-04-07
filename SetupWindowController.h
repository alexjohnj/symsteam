//
//  SetupWindowController.h
//  SymSteam
//
//  Created by Alex Jackson on 03/02/2012.

#import <Cocoa/Cocoa.h>

@interface SetupWindowController : NSWindowController

@property (weak) IBOutlet NSTextField *pathToSymLinkField;
@property (weak) IBOutlet NSTextField *pathToNonSymLinkField;
@property (weak) IBOutlet NSButton *continueButton;

@property (assign) BOOL symLinkPathProvided;
@property (assign) BOOL nonSymLinkPathProvided;
@property (assign) BOOL formComplete;

-(void)checkPathsProvided;

-(IBAction)choosePathToSymLink:(id)sender;
-(IBAction)choosePathToNonSymLink:(id)sender;
-(IBAction)doneButtonPressed:(id)sender;

@end