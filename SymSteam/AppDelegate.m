//
//  AppDelegate.m
//  SymSteam
//
//  Created by Alex Jackson on 02/02/2012.

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize aController = _aController;
@synthesize setupController = _setupController;
@synthesize preferencesWindowController = _preferencesWindowController;

-(id)init{
    self = [super init];
    if(self){
        _aController = [[AppController alloc] init];
    }
    
    return self;
}

- (MASPreferencesWindowController *)preparePreferencesWindow{
    
    GeneralPreferencesViewController *generalPrefs = [[GeneralPreferencesViewController alloc] initWithNibName:@"GeneralPreferencesView" 
                                                                                                        bundle:[NSBundle mainBundle]];
    
    AboutPreferencesViewController *aboutPrefs = [[AboutPreferencesViewController alloc] initWithNibName:@"AboutPreferencesView" 
                                                                                                  bundle:[NSBundle mainBundle]];
    
    UpdatesPreferencesViewController *updatePrefs = [[UpdatesPreferencesViewController alloc] initWithNibName:@"UpdatesPreferencesView" 
                                                                                                       bundle:[NSBundle mainBundle]];
    NSArray *viewsArray = @[generalPrefs, updatePrefs, aboutPrefs];
    
    MASPreferencesWindowController *preferencesWindowController = [[MASPreferencesWindowController alloc] initWithViewControllers:viewsArray
                                                                                                                            title:NSLocalizedString(@"Preferences", @"Preferences Window Name")];
    return preferencesWindowController;
}

# pragma mark - NSApplication Delegate Methods

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    BOOL setupIsComplete = [[NSUserDefaults standardUserDefaults] boolForKey:@"setupComplete"];
    
    if(setupIsComplete == NO){
        _setupController = [[SetupWindowController alloc] initWithWindowNibName:@"SetupWindow"];
        [self.setupController showWindow:self];
    }
    
    else{
        [self.aController performInitialDriveScan];
        [self.aController startWatchingDrives];
        if([NSEvent modifierFlags] == NSAlternateKeyMask){
            if(!_preferencesWindowController)
                _preferencesWindowController = [self preparePreferencesWindow];
            [self.preferencesWindowController showWindow:self];
        }
    }
}

-(void)applicationWillTerminate:(NSNotification *)notification{
    if(self.aController.saController.steamDriveIsConnected)
        [self.aController.saController makeLocalSteamAppsPrimary];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag{
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"setupComplete"])
        return NO;
    
    else{
        if(_preferencesWindowController == nil){
            _preferencesWindowController = [self preparePreferencesWindow];
        }
        
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

+(void)initialize{
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
    
    
    NSMutableDictionary *defaults = [@{ setupCompleteKey : setupComplete,
                                     steamAppsSymbolicLinkPathKey : steamAppsSymbolicLinkPath,
                                     steamAppsLocalPathKey : steamAppsLocalPath,
                                     symbolicPathDestinationKey : symbolicPathDestination,
                                     growlNotificationsEnabledKey : growlNotificationsEnabled } mutableCopy];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

@end
