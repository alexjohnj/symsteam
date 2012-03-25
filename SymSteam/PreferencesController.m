//
//  PreferencesController.m
//  SymSteam
//
//  Created by Alex Jackson on 15/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PreferencesController.h"

@implementation PreferencesController

@synthesize localPathTextField, symbolicPathTextField, growlNotificationsCheckBox;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

-(IBAction)toggleGrowlNotifications:(id)sender{
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(IBAction)chooseLocalSteamAppsPath:(id)sender{
    NSOpenPanel *oPanel = [[NSOpenPanel alloc] init];
    oPanel.canChooseFiles = NO;
    oPanel.canChooseDirectories = YES;
    oPanel.canCreateDirectories = YES;
    
    NSInteger result;
    result = [oPanel runModal];
    
    if(result != NSOKButton) 
        return;
    
    else if(result == NSOKButton){
        [[NSUserDefaults standardUserDefaults] setValue:[[oPanel URL] path] forKey:@"steamAppsLocalPath"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}

-(IBAction)chooseSymbolicSteamAppsPath:(id)sender{
    NSOpenPanel *oPanel = [[NSOpenPanel alloc] init];
    oPanel.canChooseDirectories = YES;
    oPanel.canCreateDirectories = YES;
    
    NSInteger result;
    result = [oPanel runModal];
    
    if(result != NSOKButton)
        return;
    
    else if(result == NSOKButton){
        [[NSUserDefaults standardUserDefaults] setValue:[[oPanel URL] path] forKey:@"steamAppsSymbolicLinkPath"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

-(IBAction)quitApplication:(id)sender{
    [[NSApplication sharedApplication] terminate:self];
}

-(IBAction)aboutApplication:(id)sender{
    [[NSApplication sharedApplication] orderFrontStandardAboutPanel:self];
}

@end