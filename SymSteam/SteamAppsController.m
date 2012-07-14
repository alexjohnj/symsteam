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

@synthesize steamDriveIsConnected = _steamDriveIsConnected;

-(id)init{
    self = [super init];
    if(self){
        _steamDriveIsConnected = NO;
    }
    return self;
}

-(void)didMountDrive:(NSNotification *)aNotification{
    if(![[NSUserDefaults standardUserDefaults] boolForKey:setupComplete])
        return;
    
    if(self.steamDriveIsConnected)
        return;
    
    NSURL *notificationDriveURL = [aNotification.userInfo valueForKey:NSWorkspaceVolumeURLKey];
    NSFileManager *fManager = [[NSFileManager alloc] init];
    
    if(![[notificationDriveURL.pathComponents objectAtIndex:2] isEqualToString:[[[[NSUserDefaults standardUserDefaults] stringForKey:symbolicPathDestinationKey]pathComponents]objectAtIndex:2]])
        return; // check to see if the name of the drive is the same as the drive the user has specified to contain the SteamApps folder. 
    
    BOOL success = NO;
    
    success = [fManager fileExistsAtPath:[[NSUserDefaults standardUserDefaults] stringForKey:symbolicPathDestinationKey]]; // check to see if the SteamApps folder exists on the external drive where the user specified it should. 
    if(!success){
        if([[NSUserDefaults standardUserDefaults] boolForKey:growlNotificationsEnabledKey]){
            [GrowlApplicationBridge notifyWithTitle:@"Something's Gone Wrong!"
                                        description:@"Check the console for details."
                                   notificationName:@"An Error Occured"
                                           iconData:nil
                                           priority:0
                                           isSticky:NO
                                       clickContext:nil];
        }
        return;
    }
    
    success = [self makeSymbolicSteamAppsPrimary];
    
    if(!success){
        return;
    }
    
    else{
        self.steamDriveIsConnected = YES;
        if([[NSUserDefaults standardUserDefaults] boolForKey:growlNotificationsEnabledKey]){
            [GrowlApplicationBridge notifyWithTitle:@"Updated Steam Folders"
                                        description:@"You're now playing games off of your external drive."
                                   notificationName:@"Changed SteamApps Folders"
                                           iconData:nil
                                           priority:0
                                           isSticky:NO
                                       clickContext:nil];
        }
    }
}

-(void)didUnMountDrive:(NSNotification *)aNotification{
    if(![[NSUserDefaults standardUserDefaults] boolForKey:setupComplete])
        return;
    
    if(!self.steamDriveIsConnected) // check to see if the drive unmounted was the user's Steam drive. From this point on, we assume it was.
        return;
    
    BOOL success = NO;
    
    success = [self makeLocalSteamAppsPrimary];
    
    if(!success){
        self.steamDriveIsConnected = NO;
        return;
    }
    else{
        self.steamDriveIsConnected = NO;
        
        if([[NSUserDefaults standardUserDefaults] boolForKey:growlNotificationsEnabledKey]){
            [GrowlApplicationBridge notifyWithTitle:@"Updated Steam Folders"
                                        description:@"You're now playing games off of your internal drive."
                                   notificationName:@"Changed SteamApps Folders"
                                           iconData:nil
                                           priority:0
                                           isSticky:NO
                                       clickContext:nil];
        }
    }
}

-(BOOL)makeSymbolicSteamAppsPrimary{
    NSString *localSteamAppsPath = [[NSUserDefaults standardUserDefaults] valueForKey:steamAppsLocalPathKey];
    NSString *symbolicSteamAppsPath = [[NSUserDefaults standardUserDefaults] valueForKey:steamAppsSymbolicLinkPathKey];
    NSFileManager *fManager = [[NSFileManager alloc] init];
    BOOL success = YES;
    
    
    NSString *newLocalSteamAppsPath = [localSteamAppsPath stringByDeletingLastPathComponent];
    newLocalSteamAppsPath = [newLocalSteamAppsPath stringByAppendingPathComponent:@"SteamAppsLoc"];
    
    // rename the local SteamApps Folder to SteamAppsLoc:
    NSError *localSteamAppsFolderRename;
    success = [fManager moveItemAtPath:localSteamAppsPath toPath:newLocalSteamAppsPath error:&localSteamAppsFolderRename]; 
    
    if(!success){
        NSLog(@"I was trying to rename the local SteamApps folder to SteamAppsLoc but couldn't rename [%@] to [%@] because: [%@]", localSteamAppsPath, newLocalSteamAppsPath, [localSteamAppsFolderRename localizedDescription]);
        if([[NSUserDefaults standardUserDefaults] boolForKey:growlNotificationsEnabledKey]){
            [GrowlApplicationBridge notifyWithTitle:@"Something's Gone Wrong!"
                                        description:@"Check the console for details."
                                   notificationName:@"An Error Occured"
                                           iconData:nil
                                           priority:0
                                           isSticky:NO
                                       clickContext:nil];
        }
        
        return NO;
    }
    
    // rename SteamAppsSymb (the symbolic link) to SteamApps
    NSError *symbolicSteamAppsFolderRename;
    success = [fManager moveItemAtPath:symbolicSteamAppsPath toPath:localSteamAppsPath error:&symbolicSteamAppsFolderRename];
    
    if(!success){
        NSLog(@"I was trying to rename SteamAppsSymb to SteamApps but couldn't rename item [%@] to [%@] because [%@]", symbolicSteamAppsPath, localSteamAppsPath, [symbolicSteamAppsFolderRename localizedDescription]);
        
        if([[NSUserDefaults standardUserDefaults] boolForKey:growlNotificationsEnabledKey]){
            [GrowlApplicationBridge notifyWithTitle:@"Something's Gone Wrong!"
                                        description:@"Check the console for details."
                                   notificationName:@"An Error Occured"
                                           iconData:nil
                                           priority:0
                                           isSticky:NO
                                       clickContext:nil];
        }
        
        return NO;
    }
    
    return YES;
}

-(BOOL)makeLocalSteamAppsPrimary{
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
            [GrowlApplicationBridge notifyWithTitle:@"Something's Gone Wrong!"
                                        description:@"Check the console for details."
                                   notificationName:@"An Error Occured"
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
            [GrowlApplicationBridge notifyWithTitle:@"Something's Gone Wrong!"
                                        description:@"Check the console for details."
                                   notificationName:@"An Error Occured"
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
