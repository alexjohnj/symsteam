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
static NSString * const notificationsEnabledKey = @"growlNotificationsEnabled";


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
    
    if (![[SCNotificationCenter sharedCenter] systemNotificationCenterAvailable]) {
        [self.notificationOptions removeRow:0];
        [self.notificationOptions sizeToCells];
        
        if (![[NSUserDefaults standardUserDefaults] boolForKey:notificationsEnabledKey])
            [self.notificationOptions selectCellAtRow:1 column:0];
        else
            [self.notificationOptions selectCellAtRow:0 column:0];
    }
    
    else {
        if (![[NSUserDefaults standardUserDefaults] boolForKey:notificationsEnabledKey])
            [self.notificationOptions selectCellAtRow:2 column:0];
        else if ([[SCNotificationCenter sharedCenter] getNotificationMethod] == SCNotificationCenterNotifyWithNotificationCenter || [[SCNotificationCenter sharedCenter] getNotificationMethod] == SCNotificationCenterNotifyByAvailability)
            [self.notificationOptions selectCellAtRow:0 column:0];
        else if ([[SCNotificationCenter sharedCenter] getNotificationMethod] == SCNotificationCenterNotifyWithGrowl)
            [self.notificationOptions selectCellAtRow:1 column:0];
    }
    
    if ([loginController checkSessionLoginItemsForApplication:bundleURL]) {
        [self.startAtLoginCheckbox setState:NSOnState];
    }
    else {
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
                NSError __autoreleasing *symbolicLinkCreationError;
                
                if([setupController createSymbolicLinkToFolder:oPanel.URL error:&symbolicLinkCreationError]){
                    [setupController saveSymbolicLinkDestinationToUserDefaults:oPanel.URL];
                    DADiskRef disk = [setupController createDADiskFromDrivePath:[setupController getDrivePathFromFolderPath:oPanel.URL]];
                    [setupController saveDriveUUIDToUserDefaults:disk];
                    CFRelease(disk);
                }
                else {
                    NSAlert *alert = [NSAlert alertWithError:symbolicLinkCreationError];
                    [alert beginSheetModalForWindow:[NSApp mainWindow] modalDelegate:self didEndSelector:@selector(symbolicLinkCreationAlertDidEnd:returnCode:contextInfo:) contextInfo:NULL];
                }
                [[SCSteamDiskManager steamDiskManager] startWatchingForDrives];
            }
        }
    }];
}

- (IBAction)changeNotificationOptions:(id)sender{
    if ([[SCNotificationCenter sharedCenter] systemNotificationCenterAvailable]){
        if (self.notificationOptions.selectedRow == 0 || self.notificationOptions.selectedRow == 1){
            [[NSUserDefaults standardUserDefaults] setValue:@YES forKey:notificationsEnabledKey];
            [[SCNotificationCenter sharedCenter] setNotificationMethodPreference:self.notificationOptions.selectedRow];
        }
        else {
            [[NSUserDefaults standardUserDefaults] setValue:@NO forKey:notificationsEnabledKey];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    else {
        if (self.notificationOptions.selectedRow == 0)
            [[NSUserDefaults standardUserDefaults] setValue:@YES forKey:notificationsEnabledKey];
        else
            [[NSUserDefaults standardUserDefaults] setValue:@NO forKey:notificationsEnabledKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
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

#pragma mark Alert Completion Handlers

- (void)symbolicLinkCreationAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
	[alert.window orderOut:self];
}

#pragma mark - Setters for MASPreferencesWindow

-(NSString *)identifier{
    return @"General Prefsr";
}

-(NSString *)toolbarItemLabel{
    return NSLocalizedString(@"General Preference Pane Title", @"Toolbar label for the general preference tab");
}

-(NSImage *)toolbarItemImage{
    return [NSImage imageNamed:NSImageNamePreferencesGeneral];
}

@end
