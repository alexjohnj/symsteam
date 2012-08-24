//
//  AppController.m
//  SymSteam
//
//  Created by Alex Jackson on 02/02/2012.


#import "AppController.h"

static NSString * const steamAppsSymbolicLinkPathKey = @"steamAppsSymbolicLinkPath";
static NSString * const steamAppsLocalPathKey = @"steamAppsLocalPath";
static NSString * const symbolicPathDestinationKey = @"symbolicPathDestination";
static NSString * const growlNotificationsEnabledKey = @"growlNotificationsEnabled";

@implementation AppController

- (id)init{
    self = [super init];
    if(self){
        _saController = [[SteamAppsController alloc] init];
    }
    return self;
}

- (void)performInitialDriveScan{
    NSString *symbolicSteamAppsFolderPath = [[NSUserDefaults standardUserDefaults] stringForKey:steamAppsSymbolicLinkPathKey];
    NSString *localSteamAppsFolderPath = [[NSUserDefaults standardUserDefaults] stringForKey:steamAppsLocalPathKey];
    
    NSString *steamAppsLocPath = [localSteamAppsFolderPath stringByDeletingLastPathComponent];
    steamAppsLocPath = [steamAppsLocPath stringByAppendingPathComponent:@"SteamAppsLoc"];
    
    NSFileManager *fManager = [[NSFileManager alloc] init];
    
    BOOL symbolicSteamAppsFolderExists = NO;
    BOOL localSteamAppsFolderExists = [fManager fileExistsAtPath:localSteamAppsFolderPath];
    BOOL steamAppsLocFolderExists = [fManager fileExistsAtPath:steamAppsLocPath];
    
    NSDictionary *symbolicSteamAppsFolderAttributes = [fManager attributesOfItemAtPath:symbolicSteamAppsFolderPath error:nil];
    if(!symbolicSteamAppsFolderAttributes)
        symbolicSteamAppsFolderExists = NO; //we check the link exists using the attributes instead of fileExistsAtPath: since the afformentioned method will try to follow the symbolic link and return NO if the link isn't reachable, even if the actual symbolic link exists.
    else
        symbolicSteamAppsFolderExists = YES;
    
    if(localSteamAppsFolderExists && !steamAppsLocFolderExists && symbolicSteamAppsFolderExists){
        NSLog(@"SteamApps exists & SteamAppsSymb exists, suggesting everything is A-OK.");
        if([self.saController externalSteamAppsFolderExists] && !self.saController.steamDriveIsConnected) //check the external SteamApps folder exists and a Steam Drive isn't registered as connected.
            [self.saController makeSymbolicSteamAppsPrimary];
        return;
    }
    
    if(!localSteamAppsFolderExists && steamAppsLocFolderExists && symbolicSteamAppsFolderExists){
        NSError *renameSteamAppsLocToSteamApps;
        BOOL success = [fManager moveItemAtPath:steamAppsLocPath toPath:localSteamAppsFolderPath error:&renameSteamAppsLocToSteamApps];
        if(!success){
            NSLog(@"I was trying to fix the SteamApps setup by renaming SteamAppsLoc to SteamApps while keeping SteamAppsSymb the same but couldn't move [%@] to [%@] because: [%@]", steamAppsLocPath, localSteamAppsFolderPath, [renameSteamAppsLocToSteamApps localizedDescription]);
            [self displayGenericErrorNotification];
        }
        else{ // if SymSteam was able to fix this configuration issue, check to see if a drive is connected and if it is, update the Steam Folders.
            if([self.saController externalSteamAppsFolderExists] && !self.saController.steamDriveIsConnected)
                [self.saController makeSymbolicSteamAppsPrimary];
        }
        return;
    }
    
    else if(!localSteamAppsFolderExists && !steamAppsLocFolderExists && symbolicSteamAppsFolderExists){
        NSLog(@"A symbolic link exists but neither a SteamApps folder nor a SteamAppsLoc folder exists! I can't do anything about this.");
        [self displayGenericErrorNotification];
        return;
    }
    
    else if(localSteamAppsFolderExists && !steamAppsLocFolderExists && !symbolicSteamAppsFolderExists){
        NSLog(@"A SteamApps folder exists but there's no SteamAppsLoc or SteamAppsSymb folder. Setup probably needs to be carried out again.");
        [self displayGenericErrorNotification];
        return;
    }
    
    else if(localSteamAppsFolderExists && steamAppsLocFolderExists && symbolicSteamAppsFolderExists){
        NSLog(@"A SteamApps, SteamAppsLoc & SteamAppsSymb folder exists. I can't take this! That's too many folders. I can't do anything with this setup. Get rid of either the SteamApps or SteamAppsLoc folder.");
        [self displayGenericErrorNotification];
        return;
    }
    
    else if(localSteamAppsFolderPath && steamAppsLocFolderExists && !symbolicSteamAppsFolderExists){
        NSDictionary *steamAppsFolderAttributes = [fManager attributesOfItemAtPath:localSteamAppsFolderPath error:nil];
        if([[steamAppsFolderAttributes fileType] isEqualToString:NSFileTypeSymbolicLink] && [self.saController externalSteamAppsFolderExists] && !self.saController.steamDriveIsConnected){
            self.saController.steamDriveIsConnected = YES;
            if([[NSUserDefaults standardUserDefaults] boolForKey:growlNotificationsEnabledKey])
                [SCNotificationCenter notifyWithDictionary:(@{
                                                            SCNotificationCenterNotificationTitle : @"Updated Steam Folders",
                                                            SCNotificationCenterNotificationDescription : @"You're now playing games off of your external drive.",
                                                            SCNotificationCenterNotificationName : @"Changed SteamApps Folders"})];
        }
        
        else if([[steamAppsFolderAttributes fileType] isEqualToString:NSFileTypeSymbolicLink] && ![self.saController externalSteamAppsFolderExists] && !self.saController.steamDriveIsConnected)
            [self.saController makeLocalSteamAppsPrimary];
        
        else{
            NSLog(@"A SteamApps & SteamAppsLoc folder exists but a SteamAppsSymb folder doesn't. I checked to see if the SteamApps folder is a symbolic link and it wasn't, so SteamAppsSymb has gone missing and needs to be recreated and setup needs to be run again. ");
            [self displayGenericErrorNotification];
        }
        return;
    }
}

- (void)displayGenericErrorNotification{
    if([[NSUserDefaults standardUserDefaults] boolForKey:growlNotificationsEnabledKey])
        [SCNotificationCenter notifyWithDictionary:(@{
                                                    SCNotificationCenterNotificationTitle: @"Something's Gone Wrong!",
                                                    SCNotificationCenterNotificationDescription: @"Check the console for details.",
                                                    SCNotificationCenterNotificationName: @"An Error Occurred"})];
}


- (void)startWatchingDrives{
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
    NSNotificationCenter *center = [workspace notificationCenter];
    [center addObserver:self.saController selector:@selector(didMountDrive:) name:NSWorkspaceDidMountNotification object:nil];
    [center addObserver:self.saController selector:@selector(didUnMountDrive:) name:NSWorkspaceDidUnmountNotification object:nil];
}

@end
