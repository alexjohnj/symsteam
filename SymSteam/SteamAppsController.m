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
        return;
    
    if(![fManager fileExistsAtPath:[[NSUserDefaults standardUserDefaults] stringForKey:symbolicPathDestinationKey]]){
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
    
    if(![self makeSymbolicSteamAppsPrimary])
        return;
    
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

-(void)didUnMountDrive:(NSNotification *)aNotification{
    if(![[NSUserDefaults standardUserDefaults] boolForKey:setupComplete])
        return;
    
    if(!self.steamDriveIsConnected)
        return;
    
    NSFileManager *fManager = [[NSFileManager alloc] init];
    if([fManager fileExistsAtPath:[[NSUserDefaults standardUserDefaults] stringForKey:symbolicPathDestinationKey]])
        return;
    
    if(![self makeLocalSteamAppsPrimary]){
        self.steamDriveIsConnected = NO;
        return;
    }
    
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

-(BOOL)makeSymbolicSteamAppsPrimary{
    NSFileManager *fManager = [[NSFileManager alloc] init];
    
    NSError *localFolderRename;
    NSString *newLocalPath = [[NSString alloc] initWithFormat:@"%@/SteamAppsLoc", [[[NSUserDefaults standardUserDefaults] valueForKey:steamAppsLocalPathKey] stringByDeletingLastPathComponent]];
    
    if(![fManager moveItemAtPath:[[NSUserDefaults standardUserDefaults] valueForKey:steamAppsLocalPathKey] toPath:newLocalPath error:&localFolderRename]){
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
    
    NSError *symbFolderRename;
    if(![fManager moveItemAtPath:[[NSUserDefaults standardUserDefaults] valueForKey:steamAppsSymbolicLinkPathKey] toPath:[[NSUserDefaults standardUserDefaults] valueForKey:steamAppsLocalPathKey] error:&symbFolderRename]){
        
        NSLog(@"Couldn't rename item [%@] to [%@] because [%@]", [[NSUserDefaults standardUserDefaults] valueForKey:steamAppsSymbolicLinkPathKey], [[NSUserDefaults standardUserDefaults] valueForKey:steamAppsLocalPathKey], [symbFolderRename localizedDescription]);
        
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
    NSFileManager *fManager = [[NSFileManager alloc] init];
    
    NSError *renameSymbolicError;
    if(![fManager moveItemAtPath:[[NSUserDefaults standardUserDefaults] valueForKey:steamAppsLocalPathKey] toPath:[[NSUserDefaults standardUserDefaults] valueForKey:steamAppsSymbolicLinkPathKey] error:&renameSymbolicError]){
        NSLog(@"Couldn't rename [%@] to [%@] because [%@]",[[NSUserDefaults standardUserDefaults] valueForKey:steamAppsLocalPathKey], [[NSUserDefaults standardUserDefaults] valueForKey:steamAppsSymbolicLinkPathKey], [renameSymbolicError localizedDescription]);
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
    NSString *currentSteamAppsPath = [[NSString alloc] initWithFormat:@"%@/SteamAppsLoc", [[[NSUserDefaults standardUserDefaults] valueForKey:steamAppsLocalPathKey]stringByDeletingLastPathComponent]];
    if(![fManager moveItemAtPath:currentSteamAppsPath toPath:[[NSUserDefaults standardUserDefaults] valueForKey:steamAppsLocalPathKey] error:&renameLocalError]){
        NSLog(@"Couldn't rename [%@] to [%@] because [%@]", currentSteamAppsPath, [[NSUserDefaults standardUserDefaults] valueForKey:steamAppsLocalPathKey], [renameLocalError localizedDescription]);
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
