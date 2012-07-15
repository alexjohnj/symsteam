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
    NSArray *viewsArray = [NSArray arrayWithObjects:generalPrefs, updatePrefs, aboutPrefs,  nil];
    
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
    
    [self.aController performInitialDriveScan];
    [self.aController startWatchingDrives];
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
