//
//  AppDelegate.m
//  SymSteam
//
//  Created by Alex Jackson on 02/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize aController, setupController, prefController;

-(id)init{
    self = [super init];
    if(self){
        aController = [[AppController alloc] init];
    }
    
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    BOOL setupIsComplete = [[NSUserDefaults standardUserDefaults] boolForKey:@"setupComplete"];
    if(setupIsComplete == NO){
        setupController = [[SetupWindowController alloc] initWithWindowNibName:@"SetupWindow"];
        [self.setupController showWindow:self];
    }
    [self.aController performInitialDriveScan];
    [self.aController startWatchingDrives];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag{
    if(self.prefController == nil)
        self.prefController = [[PreferencesController alloc] initWithWindowNibName:@"PreferencesWindow"];
    [self.prefController showWindow:self];
    
    return YES;
}

+(void)initialize{
    NSString *setupCompleteKey = [[NSString alloc] initWithString:@"setupComplete"];
    BOOL setupComplete = NO;
    
    NSString *steamAppsSymbolicLinkPathKey = [[NSString alloc] initWithString:@"steamAppsSymbolicLinkPath"];
    NSString *steamAppsSymbolicLinkPath = [[NSString alloc] initWithString:@""];
    
    NSString *steamAppsLocalPathKey = [[NSString alloc] initWithString:@"steamAppsLocalPath"];
    NSString *steamAppsLocalPath = [[NSString alloc] initWithString:@""];
    
    NSString *symbolicPathDestinationKey = [[NSString alloc] initWithString:@"symbolicPathDestination"];
    NSString *symbolicPathDestination = [[NSString alloc] initWithString:@""];
    
    NSString *growlNotificationsEnabledKey = [[NSString alloc] initWithString:@"growlNotificationsEnabled"];
    NSNumber *growlNotificationsEnabled = [[NSNumber alloc] initWithBool:YES]; 
    
    NSUserDefaults *uDefaults = [NSUserDefaults standardUserDefaults];
   
    NSMutableDictionary *defaultValues = [[NSMutableDictionary alloc] init];
    
    [defaultValues setValue:[NSNumber numberWithBool:setupComplete] forKey:setupCompleteKey];
    [defaultValues setValue:steamAppsSymbolicLinkPath forKey:steamAppsSymbolicLinkPathKey];
    [defaultValues setValue:steamAppsLocalPath forKey:steamAppsLocalPathKey];
    [defaultValues setValue:growlNotificationsEnabled forKey:growlNotificationsEnabledKey];
    [defaultValues setValue:symbolicPathDestination forKey:symbolicPathDestinationKey];
    
    [uDefaults registerDefaults:defaultValues];
}
@end