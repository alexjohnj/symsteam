//
//  SetupWindowController.m
//  SymSteam
//
//  Created by Alex Jackson on 03/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SetupWindowController.h"

@implementation SetupWindowController
@synthesize pathToSymLinkField, pathToNonSymLinkField, continueButton;
@synthesize symLinkPathProvided, nonSymLinkPathProvided, formComplete;

#pragma mark - Window Lifecycle methods

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        symLinkPathProvided = NO;
        nonSymLinkPathProvided = NO;
        formComplete = NO;
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    NSLog(@"Loaded");
}

#pragma mark - UI Code

-(IBAction)choosePathToSymLink:(id)sender{
    NSOpenPanel *openPanel = [[NSOpenPanel alloc] init];
    openPanel.canChooseDirectories = YES;
    openPanel.allowsMultipleSelection = NO;
    openPanel.resolvesAliases = NO;
    
    NSArray *libArray = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    openPanel.directoryURL = [NSURL fileURLWithPath:[libArray objectAtIndex:0]];
    
    NSInteger result = [openPanel runModal];
    if(result == NSOKButton){
        self.pathToSymLinkField.stringValue = openPanel.URL.path;
        self.symLinkPathProvided = YES;
        [self checkPathsProvided];
    }
    
    else{
        if(self.symLinkPathProvided == YES)
            self.symLinkPathProvided = NO;
        [self checkPathsProvided];
    }
}
-(IBAction)choosePathToNonSymLink:(id)sender{
    NSOpenPanel *openPanel = [[NSOpenPanel alloc] init];
    openPanel.canChooseDirectories = YES;
    openPanel.allowsMultipleSelection = NO;
    
    NSArray *libArray = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    openPanel.directoryURL = [NSURL fileURLWithPath:[libArray objectAtIndex:0]];
    
    NSInteger result = [openPanel runModal];
    if(result == NSOKButton){
        self.pathToNonSymLinkField.stringValue = openPanel.URL.path;
        self.nonSymLinkPathProvided = YES;
        [self checkPathsProvided];
    }
    else{
        if(self.nonSymLinkPathProvided == YES)
            self.nonSymLinkPathProvided = NO;
        [self checkPathsProvided];
    }
}

-(IBAction)doneButtonPressed:(id)sender{
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:@"setupComplete"];
    [[NSUserDefaults standardUserDefaults] setValue:self.pathToNonSymLinkField.stringValue forKey:@"steamAppsLocalPath"];
    [[NSUserDefaults standardUserDefaults] setValue:self.pathToSymLinkField.stringValue forKey:@"steamAppsSymbolicLinkPath"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self close];
}

-(void)checkPathsProvided{
    if(self.symLinkPathProvided == YES && self.nonSymLinkPathProvided == YES)
        self.formComplete = YES;
    
    else
        self.formComplete = NO;
}
@end