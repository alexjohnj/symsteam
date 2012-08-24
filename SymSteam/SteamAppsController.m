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
    if(!connectedDrive)
        return NO;
    
    NSString *steamAppsDriveName = [[[NSUserDefaults standardUserDefaults] stringForKey:symbolicPathDestinationKey] pathComponents][2];
    
    if (connectedDrive.pathComponents.count < 3)
        return NO; // External drives must have at least 3 components and we need the third component anyway so lets just avoid an out of bounds exception.
    else
        return [steamAppsDriveName isEqualToString:connectedDrive.pathComponents[2]];
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
    [self makeSymbolicSteamAppsPrimary];
}

- (void)didUnMountDrive:(NSNotification *)aNotification{
    if(!self.steamDriveIsConnected)
        return;
    
    else if(![self connectedDriveIsSteamDrive:aNotification.userInfo[NSWorkspaceVolumeURLKey]])
        return;
    
    [self makeLocalSteamAppsPrimary];
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
    self.steamDriveIsConnected = NO; // Update this here since the Steam drive will have been disconnected regardless of if this method completes successfully.
    
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
            [SCNotificationCenter notifyWithDictionary:(@{
                                                        SCNotificationCenterNotificationTitle: @"Something's Gone Wrong!",
                                                        SCNotificationCenterNotificationDescription: @"Check the console for details.",
                                                        SCNotificationCenterNotificationName: @"An Error Occurred"})];
        }
        return NO;
    }
    
    // Attempt to rename SteamAppsLoc to SteamApps
    NSError *renameLocalError;
    NSString *currentLocalSteamAppsFolderPath = [[localSteamAppsPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"SteamAppsLoc"];
    
    success = [fManager moveItemAtPath:currentLocalSteamAppsFolderPath toPath:localSteamAppsPath error:&renameLocalError];
    if(!success){
        NSLog(@"I was trying to rename SteamAppsLoc to SteamApps but couldn't rename [%@] to [%@] because [%@]", currentLocalSteamAppsFolderPath,localSteamAppsPath, [renameLocalError localizedDescription]);
        if([[NSUserDefaults standardUserDefaults] boolForKey:growlNotificationsEnabledKey]){
            [SCNotificationCenter notifyWithDictionary:(@{
                                                        SCNotificationCenterNotificationTitle: @"Something's Gone Wrong!",
                                                        SCNotificationCenterNotificationDescription: @"Check the console for details.",
                                                        SCNotificationCenterNotificationName: @"An Error Occurred"})];
        }
        return NO;
    }
    
    // If we make it to this point then everything will have been succesful and we can notify the user (assuming they want us to).
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:growlNotificationsEnabledKey])
        [SCNotificationCenter notifyWithDictionary:(@{
                                                    SCNotificationCenterNotificationTitle: @"Updated Steam Folders",
                                                    SCNotificationCenterNotificationDescription: @"You're now playing games off of your internal drive.",
                                                    SCNotificationCenterNotificationName: @"Changed SteamApps Folders"})];
    
    return YES;
}

@end
