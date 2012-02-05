//
//  AppDelegate.m
//  SymSteam
//
//  Created by Alex Jackson on 02/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize aController, setupController;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    BOOL setupIsComplete = [[NSUserDefaults standardUserDefaults] boolForKey:@"setupComplete"];
    if(setupIsComplete == NO){
        setupController = [[SetupWindowController alloc] initWithWindowNibName:@"SetupWindow"];
        [self.setupController showWindow:self];
    }
    
    [self.aController startWatchingDrives];
}

-(id)init{
    self = [super init];
    if(self){
        aController = [[AppController alloc] init];
    }
    
    return self;
}

+(void)initialize{
    NSString *setupCompleteKey = [[NSString alloc] initWithString:@"setupComplete"];
    BOOL setupComplete = NO;
    
    NSString *steamAppsSymbolicLinkPathKey = [[NSString alloc] initWithString:@"steamAppsSymbolicLinkPath"];
    NSString *steamAppsSymbolicLinkPath = [[NSString alloc] initWithString:@""];
    
    NSString *steamAppsLocalPathKey = [[NSString alloc] initWithString:@"steamAppsLocalPath"];
    NSString *steamAppsLocalPath = [[NSString alloc] initWithString:@""];
    
    NSUserDefaults *uDefaults = [NSUserDefaults standardUserDefaults];
   
    NSMutableDictionary *defaultValues = [[NSMutableDictionary alloc] init];
    
    [defaultValues setValue:[NSNumber numberWithBool:setupComplete] forKey:setupCompleteKey];
    [defaultValues setValue:steamAppsSymbolicLinkPath forKey:steamAppsSymbolicLinkPathKey];
    [defaultValues setValue:steamAppsLocalPath forKey:steamAppsLocalPathKey];
    
    [uDefaults registerDefaults:defaultValues];
}

@end