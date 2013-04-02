//
//  AppDelegate.m
//  SymSteam
//
//  Created by Alex Jackson on 02/02/2012.

#import "AppDelegate.h"

@implementation AppDelegate

- (id)init{
    self = [super init];
    if(self){
        _notificationCenterDelegate = [[SCUserNotificationCenterDelegate alloc] init];
    }
    
    return self;
}

- (MASPreferencesWindowController *)preparePreferencesWindow{
    
    GeneralPreferencesViewController *generalPrefs = [[GeneralPreferencesViewController alloc] initWithNibName:@"GeneralPreferencesView"
                                                                                                        bundle:[NSBundle mainBundle]];
    
    UpdatesPreferencesViewController *updatePrefs = [[UpdatesPreferencesViewController alloc] initWithNibName:@"UpdatesPreferencesView"
                                                                                                       bundle:[NSBundle mainBundle]];
    
    AboutPreferencesViewController *aboutPrefs = [[AboutPreferencesViewController alloc] initWithNibName:@"AboutPreferencesView"
                                                                                                  bundle:[NSBundle mainBundle]];
    NSArray *viewsArray = @[generalPrefs, updatePrefs, aboutPrefs];
    
    MASPreferencesWindowController *preferencesWindowController = [[MASPreferencesWindowController alloc] initWithViewControllers:viewsArray
                                                                                                                            title:NSLocalizedString(@"Preferences", @"Preferences Window Name")];
    return preferencesWindowController;
}

# pragma mark - NSApplication Delegate Methods

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    BOOL setupIsComplete = [[NSUserDefaults standardUserDefaults] boolForKey:@"setupComplete"];
    if([[SCNotificationCenter sharedCenter] systemNotificationCenterAvailable]){
        [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self.notificationCenterDelegate];
    }
    
    if(setupIsComplete == NO){
        self.setupController = [[SetupWindowController alloc] initWithWindowNibName:@"SetupWindow"];
        [NSApp activateIgnoringOtherApps: YES];
        [self.setupController.window makeKeyAndOrderFront:self];
    }
    
    else{
        [[SCSteamDiskManager steamDiskManager] startWatchingForDrives];
        if([NSEvent modifierFlags] == NSAlternateKeyMask){
            if(!self.preferencesWindowController)
                self.preferencesWindowController = [self preparePreferencesWindow];
            [self.preferencesWindowController showWindow:self];
        }
    }
}

-(void)applicationWillTerminate:(NSNotification *)notification{
    if([[SCSteamDiskManager steamDiskManager] isRegisteredForDACallbacks])
        [[SCSteamDiskManager steamDiskManager] stopWatchingForDrives];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag{
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"setupComplete"])
        return NO;
    
    else{
        if(self.preferencesWindowController == nil)
            self.preferencesWindowController = [self preparePreferencesWindow];        
        [self.preferencesWindowController showWindow:self];
        
        return YES;
    }
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
    BOOL setupComplete = [[NSUserDefaults standardUserDefaults] boolForKey:@"setupComplete"];
    if(setupComplete)
        return NO;
    else
        return YES;
}

+ (void)initialize{
    NSString *setupCompleteKey = @"setupComplete";
    NSNumber *setupComplete = @NO;
    
    NSString *steamAppsSymbolicLinkPathKey = @"steamAppsSymbolicLinkPath";
    NSString *steamAppsSymbolicLinkPath = @"";
    
    NSString *steamAppsLocalPathKey = @"steamAppsLocalPath";
    NSString *steamAppsLocalPath = @"";
    
    NSString *symbolicPathDestinationKey = @"symbolicPathDestination";
    NSString *symbolicPathDestination = @"";
    
    NSString *growlNotificationsEnabledKey = @"growlNotificationsEnabled";
    NSNumber *growlNotificationsEnabled = @YES;
    
    NSString *steamDriveUUIDKey = @"steamDriveUUID";
    NSString *steamDriveUUID = @"";
    
    
    NSMutableDictionary *defaults = [@{
                                     setupCompleteKey: setupComplete,
                                     steamAppsSymbolicLinkPathKey: steamAppsSymbolicLinkPath,
                                     steamAppsLocalPathKey: steamAppsLocalPath,
                                     symbolicPathDestinationKey: symbolicPathDestination,
                                     growlNotificationsEnabledKey: growlNotificationsEnabled,
                                     steamDriveUUIDKey: steamDriveUUID} mutableCopy];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

@end
