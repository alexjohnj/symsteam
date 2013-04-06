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
    
    BOOL setupIsComplete = [[NSUserDefaults standardUserDefaults] boolForKey:SCSetupCompleteKey];
    if([[SCNotificationCenter sharedCenter] systemNotificationCenterAvailable]){
        [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self.notificationCenterDelegate];
    }
    
    [GrowlApplicationBridge setGrowlDelegate:self.notificationCenterDelegate]; // Set this regardless of if we're using Growl or NSUserNotificationCenter as the user could change it later on.
    
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
    if(![[NSUserDefaults standardUserDefaults] boolForKey:SCSetupCompleteKey])
        return NO;
    
    else{
        if(self.preferencesWindowController == nil)
            self.preferencesWindowController = [self preparePreferencesWindow];        
        [self.preferencesWindowController showWindow:self];
        
        return YES;
    }
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
    BOOL setupComplete = [[NSUserDefaults standardUserDefaults] boolForKey:SCSetupCompleteKey];
    if(setupComplete)
        return NO;
    else
        return YES;
}

+ (void)initialize {
    NSDictionary *defaults = @{
                               SCSetupCompleteKey: @NO,
                               SCSteamAppsSymbolicLinkLocationKey: @"",
                               SCSteamAppsLocalLocationKey: @"",
                               SCSteamAppsSymbolicLinkDestinationKey: @"",
                               SCNotificationsEnabledKey: @YES,
                               SCSteamDriveUUIDKey: @""
                               };
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

@end
