//
//  SetupWindowController.h
//  SymSteam
//
//  Created by Alex Jackson on 03/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SetupWindowController : NSWindowController

@property (strong) IBOutlet NSTextField *pathToSymLinkField;
@property (strong) IBOutlet NSTextField *pathToNonSymLinkField;
@property (strong) IBOutlet NSButton *continueButton;

@property (assign) BOOL symLinkPathProvided;
@property (assign) BOOL nonSymLinkPathProvided;
@property (assign) BOOL formComplete;

-(void)checkPathsProvided;

-(IBAction)choosePathToSymLink:(id)sender;
-(IBAction)choosePathToNonSymLink:(id)sender;
-(IBAction)doneButtonPressed:(id)sender;

@end
