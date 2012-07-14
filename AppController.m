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
@synthesize saController = _saController;


-(id)init{
    self = [super init];
    if(self){
        _saController = [[SteamAppsController alloc] init];
    }
    return self;
}

-(void)performInitialDriveScan{
    NSString *symbolicLinkPath = [[NSUserDefaults standardUserDefaults] stringForKey:steamAppsSymbolicLinkPathKey];
    NSString *localPath = [[[NSUserDefaults standardUserDefaults] stringForKey:steamAppsLocalPathKey] stringByDeletingPathExtension];
    NSString *symbolicLinkDestination = [[NSUserDefaults standardUserDefaults] stringForKey:symbolicPathDestinationKey];
    NSString *steamAppsLocPath = [[NSString alloc] initWithFormat:@"%@/SteamAppsLoc", localPath.stringByDeletingLastPathComponent];
    
    NSFileManager *fManager = [[NSFileManager alloc] init];
    
    BOOL steamAppsSymbExists = NO;
    BOOL steamAppsLocExists = NO;
    BOOL steamAppsExists = NO;
    
    steamAppsSymbExists = [fManager fileExistsAtPath:symbolicLinkPath];
    steamAppsLocExists = [fManager fileExistsAtPath:steamAppsLocPath];
    steamAppsExists = [fManager fileExistsAtPath:localPath];
    
    if(!steamAppsSymbExists && steamAppsLocExists && steamAppsExists){
        NSError *moveSteamAppsToSymbError;
        if(![fManager moveItemAtPath:localPath toPath:symbolicLinkPath error:&moveSteamAppsToSymbError]){
            NSLog(@"Unabled to rename %@ to %@ because: %@", localPath, symbolicLinkPath, [moveSteamAppsToSymbError localizedDescription]);
            if([[NSUserDefaults standardUserDefaults] boolForKey:growlNotificationsEnabledKey])
                [GrowlApplicationBridge notifyWithTitle:@"Something's Gone Wrong!"
                                            description:@"Check the console for details."
                                       notificationName:@"An Error Occured"
                                               iconData:nil
                                               priority:2
                                               isSticky:NO
                                           clickContext:nil];
        }
        
        NSError *moveLocToSteamApps;
        if(![fManager moveItemAtPath:steamAppsLocPath toPath:localPath error:&moveLocToSteamApps]){
            NSLog(@"Unabled to rename %@ to %@ because: %@",steamAppsLocPath, localPath, [moveLocToSteamApps localizedDescription]);
            
            if([[NSUserDefaults standardUserDefaults] boolForKey:growlNotificationsEnabledKey])
                [GrowlApplicationBridge notifyWithTitle:@"Something's Gone Wrong!"
                                            description:@"Check the console for details."
                                       notificationName:@"An Error Occured"
                                               iconData:nil
                                               priority:2
                                               isSticky:NO
                                           clickContext:nil];
        }
    }    
    
    if(!steamAppsExists && steamAppsSymbExists && steamAppsLocExists){
        NSError *renameSteamAppsLocToSteamAppsError;
        if(![fManager moveItemAtPath:steamAppsLocPath toPath:steamAppsLocalPathKey error:&renameSteamAppsLocToSteamAppsError]){
            NSLog(@"Unabled to rename %@ to %@ because: %@", steamAppsLocPath, localPath, [renameSteamAppsLocToSteamAppsError localizedDescription]);
            
            if([[NSUserDefaults standardUserDefaults] boolForKey:growlNotificationsEnabledKey])
                [GrowlApplicationBridge notifyWithTitle:@"Something's Gone Wrong!"
                                            description:@"Check the console for details."
                                       notificationName:@"An Error Occured"
                                               iconData:nil
                                               priority:2
                                               isSticky:NO
                                           clickContext:nil];
        }
    }
    
    if([fManager fileExistsAtPath:symbolicLinkDestination]){
        if(![self.saController makeSymbolicSteamAppsPrimary])
            return;
        self.saController.steamDriveIsConnected = YES;
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


-(void)startWatchingDrives{
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
    NSNotificationCenter *center = [workspace notificationCenter];
    [center addObserver:self.saController selector:@selector(didMountDrive:) name:NSWorkspaceDidMountNotification object:nil];
    [center addObserver:self.saController selector:@selector(didUnMountDrive:) name:NSWorkspaceDidUnmountNotification object:nil];
}


@end
