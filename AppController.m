//
//  AppController.m
//  SymSteam
//
//  Created by Alex Jackson on 02/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppController.h"

static NSString * const steamAppsSymbolicLinkPath = @"steamAppsSymbolicLinkPath";
static NSString * const steamAppsLocalPath = @"steamAppsLocalPath";
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
    NSString *symbolicLinkPath = [[NSUserDefaults standardUserDefaults] stringForKey:steamAppsSymbolicLinkPath];
    NSString *localPath = [[[NSUserDefaults standardUserDefaults] stringForKey:steamAppsLocalPath] stringByDeletingPathExtension];
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
            NSLog(@"Unabled to rename %@ to %@, %@", localPath, symbolicLinkPath, [moveSteamAppsToSymbError localizedDescription]);
            if([[NSUserDefaults standardUserDefaults] boolForKey:growlNotificationsEnabledKey])
                [GrowlApplicationBridge notifyWithTitle:@"There's something up with your Steam Setup"
                                            description:@"I tried to fix it but failed with style. Please check your Steam folder and check you have a SteamApps folder and a SteamAppsSymb folder only."
                                       notificationName:@"localPrimaryFail"
                                               iconData:nil
                                               priority:2
                                               isSticky:NO
                                           clickContext:nil];
        }
        
        NSError *moveLocToSteamApps;
        if(![fManager moveItemAtPath:steamAppsLocPath toPath:localPath error:&moveLocToSteamApps]){
            NSLog(@"Unabled to rename %@ to %@, %@",steamAppsLocPath, localPath, [moveLocToSteamApps localizedDescription]);
            
            if([[NSUserDefaults standardUserDefaults] boolForKey:growlNotificationsEnabledKey])
                [GrowlApplicationBridge notifyWithTitle:@"There's something up with your Steam Setup"
                                            description:@"I tried to fix it but failed with style. Please check your Steam folder and check you have a SteamApps folder and a SteamAppsSymb folder only."
                                       notificationName:@"localPrimaryFail"
                                               iconData:nil
                                               priority:2
                                               isSticky:NO
                                           clickContext:nil];
        }
    }    
    
    if(!steamAppsExists && steamAppsSymbExists && steamAppsLocExists){
        NSError *renameSteamAppsLocToSteamAppsError;
        if(![fManager moveItemAtPath:steamAppsLocPath toPath:steamAppsLocalPath error:&renameSteamAppsLocToSteamAppsError]){
            NSLog(@"Unabled to rename %@ to %@, %@", steamAppsLocPath, localPath, [renameSteamAppsLocToSteamAppsError localizedDescription]);
            
            if([[NSUserDefaults standardUserDefaults] boolForKey:growlNotificationsEnabledKey])
                [GrowlApplicationBridge notifyWithTitle:@"There's something up with your Steam Setup"
                                            description:@"I tried to fix it but failed with style. Please check your Steam folder and check you have a SteamApps folder and a SteamAppsSymb folder only."
                                       notificationName:@"localPrimaryFail"
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
            [GrowlApplicationBridge notifyWithTitle:@"The symbolic SteamApps Folder is now active"
                                        description:@"Your Steam drive was plugged in."
                                   notificationName:@"symbolicSteamAppsPrimary"
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
