//
//  GeneralPreferencesViewController.m
//  SymSteam
//
//  Created by Alex Jackson on 08/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GeneralPreferencesViewController.h"
#import "AppDelegate.h"

static NSString * const steamAppsLocalPathKey = @"steamAppsLocalPath";
static NSString * const steamAppsSymbolicLinkPathKey = @"steamAppsSymbolicLinkPath";
static NSString * const symbolicPathDestinationKey = @"symbolicPathDestination";

@implementation GeneralPreferencesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)awakeFromNib{
    SCLoginController *loginController = [[SCLoginController alloc] init];
    NSURL *bundleURL = [[NSBundle mainBundle] bundleURL];
    
    if([loginController checkSessionLoginItemsForApplication:bundleURL]){
        [self.startAtLoginCheckbox setState:NSOnState];
    }
    else{
        [self.startAtLoginCheckbox setState:NSOffState];
    }
}

#pragma mark -

- (IBAction)chooseExternalSteamAppsFolderLocation:(id)sender{
    NSOpenPanel *oPanel = [[NSOpenPanel alloc] init];
    oPanel.canChooseDirectories = YES;
    oPanel.canCreateDirectories = YES;
    oPanel.canChooseFiles = NO;
    
    [oPanel beginSheetModalForWindow:[NSApp mainWindow] completionHandler:^(NSInteger result) {
        if(result == NSFileHandlingPanelOKButton){
            [oPanel orderOut:self];
            SCSetupController *setupController = [[SCSetupController alloc] init];
            if([setupController verifyProvidedFolderIsUsable:oPanel.URL]){
                [[SCSteamDiskManager steamDiskManager] stopWatchingForDrives];
                if([setupController createSymbolicLinkToFolder:oPanel.URL]){
                    [setupController saveSymbolicLinkDestinationToUserDefaults:oPanel.URL];
                    DADiskRef disk = [setupController createDADiskFromDrivePath:[setupController getDrivePathFromFolderPath:oPanel.URL]];
                    [setupController saveDriveUUIDToUserDefaults:disk];
                    CFRelease(disk);
                    [[SCSteamDiskManager steamDiskManager] startWatchingForDrives];
                }
            }
        }
    }];
}

- (IBAction)toggleGrowlNotifications:(id)sender{
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)toggleLaunchSymSteamAtLogin:(id)sender{
    SCLoginController *loginController = [[SCLoginController alloc] init];
    NSURL *bundleURL = [[NSBundle mainBundle] bundleURL];
    
    if([sender state] == NSOnState){
        [loginController addApplicationToLoginItems:bundleURL];
    }
    
    else{
        [loginController removeApplicationFromLoginItems:bundleURL];
    }
}

#pragma mark - Setters for MASPreferencesWindow

-(NSString *)identifier{
    return @"General Prefsr";
}

-(NSString *)toolbarItemLabel{
    return NSLocalizedString(@"General", @"Toolbar label for the general preference tab");
}

-(NSImage *)toolbarItemImage{
    return [NSImage imageNamed:NSImageNamePreferencesGeneral];
}

@end
