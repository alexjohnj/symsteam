//
//  SteamAppsController.m
//  SymSteam
//
//  Created by Alex Jackson on 05/04/2012.


#import "SteamAppsController.h"

static NSString * const steamAppsSymbolicLinkPathKey = @"steamAppsSymbolicLinkPath";
static NSString * const steamAppsLocalPathKey = @"steamAppsLocalPath";
static NSString * const growlNotificationsEnabledKey = @"growlNotificationsEnabled";
static NSString * const symbolicPathDestinationKey = @"symbolicPathDestination";
static NSString * const setupComplete = @"setupComplete";

@implementation SteamAppsController

- (id)init{
    self = [super init];
    if(self){
        _steamDriveIsConnected = NO;
    }
    return self;
}

- (BOOL)connectedDriveIsSteamDrive:(NSURL *)connectedDrive{
    NSString *steamAppsDriveName = [[[NSUserDefaults standardUserDefaults] stringForKey:symbolicPathDestinationKey] pathComponents][2];
    NSString *connectedDriveName;
    @try {
        connectedDriveName = connectedDrive.pathComponents[2]; // If there's an exception here, it's probably caused on login by /home and /net mounting. 
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
        connectedDriveName = nil;
    }
    @finally {
        return [steamAppsDriveName isEqualToString:connectedDriveName];
    }
}

- (BOOL)externalSteamAppsFolderExists{
    return [[NSFileManager defaultManager] fileExistsAtPath:[[NSUserDefaults standardUserDefaults] stringForKey:symbolicPathDestinationKey]];
}

- (void)didMountDrive:(NSNotification *)aNotification{
    if(self.steamDriveIsConnected) // If a Steam Drive is connected, we can ignore this drive. 
        return;
    
    if(![self connectedDriveIsSteamDrive:aNotification.userInfo[NSWorkspaceVolumeURLKey]]) // Check the connected drive's name to see if it is the same as the one the user specified in setup.
        return;
    
    if(![self externalSteamAppsFolderExists]){ // Check the SteamApps folder exists on the drive. If this fails we display an error since we're now 100% certain the connected drive is a Steam drive.
        NSLog(@"The SteamApps folder wasn't found on the drive connected. Drive: %@", aNotification.userInfo[NSWorkspaceVolumeURLKey]);
        if([[NSUserDefaults standardUserDefaults] boolForKey:growlNotificationsEnabledKey]){
            [SCNotificationCenter notifyWithDictionary:(@{
                                                        SCNotificationCenterNotificationTitle : @"Something's Gone Wrong!",
                                                        SCNotificationCenterNotificationDescription : @"The SteamApps folder wasn't found on the Steam drive you connected.",
                                                        SCNotificationCenterNotificationName : @"An Error Occurred"})];
        }
        return;
    }
    
    BOOL success = [self makeSymbolicSteamAppsPrimary];
    
    if(!success){
        return;
    }
    
    else{
        self.steamDriveIsConnected = YES;
        if([[NSUserDefaults standardUserDefaults] boolForKey:growlNotificationsEnabledKey]){
            [[SCNotificationCenter sharedCenter] notifyWithDictionary:@{
                               SCNotificationCenterNotificationTitle : @"Updated Steam Folders",
                         SCNotificationCenterNotificationDescription : @"You're now playing games off of your external drive.",
                                SCNotificationCenterNotificationName : @"Changed SteamApps Folders",
                            SCNotificationCenterNotificationPriority : @0,
                              SCNotificationCenterNotificationSticky : @NO,
                     SCNotificationCenterNotificationHasActionButton : @YES,
                   SCNotificationCenterNotificationActionButtonTitle : @"OK"
             }];
        }
    }
}

- (void)didUnMountDrive:(NSNotification *)aNotification{
    if(!self.steamDriveIsConnected)
        return;
    
    else if(![self connectedDriveIsSteamDrive:aNotification.userInfo[NSWorkspaceVolumeURLKey]])
        return;
    
    
    if(![self makeLocalSteamAppsPrimary]){
        self.steamDriveIsConnected = NO;
    }
    
    else{
        self.steamDriveIsConnected = NO;
        if([[NSUserDefaults standardUserDefaults] boolForKey:growlNotificationsEnabledKey]){
            [SCNotificationCenter notifyWithDictionary:(@{
                                                        SCNotificationCenterNotificationTitle: @"Updated Steam Folders",
                                                        SCNotificationCenterNotificationDescription: @"You're now playing games off of your internal drive.",
                                                        SCNotificationCenterNotificationName: @"Changed SteamApps Folders"})];
        }
    }
}

- (BOOL)makeSymbolicSteamAppsPrimary{
    NSString *localSteamAppsPath = [[NSUserDefaults standardUserDefaults] valueForKey:steamAppsLocalPathKey];
    NSString *symbolicSteamAppsPath = [[NSUserDefaults standardUserDefaults] valueForKey:steamAppsSymbolicLinkPathKey];
    NSString *newLocalSteamAppsPath = [[localSteamAppsPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"SteamAppsLoc"];
    NSFileManager *fManager = [[NSFileManager alloc] init];
    BOOL success = YES;
    
    // rename the local SteamApps Folder to SteamAppsLoc:
    NSError *localSteamAppsFolderRename;
    success = [fManager moveItemAtPath:localSteamAppsPath toPath:newLocalSteamAppsPath error:&localSteamAppsFolderRename];
    
    if(!success){
        NSLog(@"I was trying to rename the local SteamApps folder to SteamAppsLoc but couldn't rename [%@] to [%@] because: [%@]", localSteamAppsPath, newLocalSteamAppsPath, [localSteamAppsFolderRename localizedDescription]);
        if([[NSUserDefaults standardUserDefaults] boolForKey:growlNotificationsEnabledKey]){
            [SCNotificationCenter notifyWithDictionary:(@{
                                                        SCNotificationCenterNotificationTitle: @"Something's Gone Wrong!",
                                                        SCNotificationCenterNotificationDescription: @"Check the console for details.",
                                                        SCNotificationCenterNotificationName: @"An Error Occurred"})];
        }
        return NO;
    }
    
    // rename SteamAppsSymb (the symbolic link) to SteamApps
    NSError *symbolicSteamAppsFolderRename;
    success = [fManager moveItemAtPath:symbolicSteamAppsPath toPath:localSteamAppsPath error:&symbolicSteamAppsFolderRename];
    
    if(!success){
        NSLog(@"I was trying to rename SteamAppsSymb to SteamApps but couldn't rename item [%@] to [%@] because [%@]", symbolicSteamAppsPath, localSteamAppsPath, [symbolicSteamAppsFolderRename localizedDescription]);
        if([[NSUserDefaults standardUserDefaults] boolForKey:growlNotificationsEnabledKey]){
            [SCNotificationCenter notifyWithDictionary:(@{
                                                        SCNotificationCenterNotificationTitle: @"Something's Gone Wrong!",
                                                        SCNotificationCenterNotificationDescription: @"Check the console for details.",
                                                        SCNotificationCenterNotificationName: @"An Error Occurred"})];
        }
        return NO;
    }
    
    // If we get to this point, everything went A-OK, so we can notify the user that the folders have changed and set steamDriveIsConnected to YES.
   
    if([[NSUserDefaults standardUserDefaults] boolForKey:growlNotificationsEnabledKey])
        [SCNotificationCenter notifyWithDictionary:(@{
                                                    SCNotificationCenterNotificationTitle : @"Updated Steam Folders",
                                                    SCNotificationCenterNotificationDescription : @"You're now playing games off of your external drive.",
                                                    SCNotificationCenterNotificationName : @"Changed SteamApps Folders"})];
    self.steamDriveIsConnected = YES;
    return YES;
}

- (BOOL)makeLocalSteamAppsPrimary{
    NSString *localSteamAppsPath = [[NSUserDefaults standardUserDefaults] valueForKey:steamAppsLocalPathKey];
    NSString *symbolicSteamAppsPath = [[NSUserDefaults standardUserDefaults] valueForKey:steamAppsSymbolicLinkPathKey];
    NSFileManager *fManager = [[NSFileManager alloc] init];
    BOOL success = YES;
    
    // Attempt to rename SteamApps to SteamAppsSymb
    NSError *renameSymbolicError;
    success = [fManager moveItemAtPath:localSteamAppsPath toPath:symbolicSteamAppsPath error:&renameSymbolicError];
    if(!success){
        NSLog(@"I was trying to rename SteamApps to SteamAppsSymb but couldn't rename [%@] to [%@] because [%@]", localSteamAppsPath, symbolicSteamAppsPath, [renameSymbolicError localizedDescription]);
        
        if([[NSUserDefaults standardUserDefaults] boolForKey:growlNotificationsEnabledKey]){
            [[SCNotificationCenter sharedCenter] notifyWithTitle:@"Something's Gone Wrong!"
                                                     description:@"Check the console for details."
                                                notificationName:@"An Error occurred"
                                                        iconData:nil
                                                        priority:0
                                                        isSticky:NO
                                                    clickContext:nil];
        }
        
        return NO;
    }
    
    NSError *renameLocalError;
    
    NSString *currentLocalSteamAppsFolderPath = [localSteamAppsPath stringByDeletingLastPathComponent];
    currentLocalSteamAppsFolderPath = [currentLocalSteamAppsFolderPath stringByAppendingPathComponent:@"SteamAppsLoc"];
    
    success = [fManager moveItemAtPath:currentLocalSteamAppsFolderPath toPath:localSteamAppsPath error:&renameLocalError];
    
    if(!success){
        NSLog(@"I was trying to rename SteamAppsLoc to SteamApps but couldn't rename [%@] to [%@] because [%@]", currentLocalSteamAppsFolderPath,localSteamAppsPath, [renameLocalError localizedDescription]);
        if([[NSUserDefaults standardUserDefaults] boolForKey:growlNotificationsEnabledKey]){
            [[SCNotificationCenter sharedCenter] notifyWithTitle:@"Something's Gone Wrong!"
                                                     description:@"Check the console for details."
                                                notificationName:@"An Error occurred"
                                                        iconData:nil
                                                        priority:0
                                                        isSticky:NO
                                                    clickContext:nil];
        }
        
        return NO;
    }
    
    return YES;
}

@end
