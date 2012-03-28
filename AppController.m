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
static NSString * const growlNotificationsEnabledKey = @"growlNotificatonsEnabled";

@implementation AppController

@synthesize driveURL, remoteSteamAppsFolder, steamDriveIsConnected, steamAppsPath, connectedDrives;

-(id)init{
    self = [super init];
    if(self){
        steamDriveIsConnected = NO;
        NSArray *libarray = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        steamAppsPath = [[NSString alloc] initWithFormat:@"%@/Application Support/Steam/SteamApps", [libarray objectAtIndex:0]];
    }
    return self;
}

-(void)startWatchingDrives{
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
    NSNotificationCenter *center = [workspace notificationCenter];
    [center addObserver:self selector:@selector(didUnmount:) name:NSWorkspaceDidUnmountNotification object:nil];
    [center addObserver:self selector:@selector(didMount:) name:NSWorkspaceDidMountNotification object:nil];
}

-(void)didUnmount:(NSNotification *)aNotification{
    NSURL *notificationDriveURL = [aNotification.userInfo valueForKey:NSWorkspaceVolumeURLKey];
    
    if(self.steamDriveIsConnected == NO){
        [self deRegisterDrive:notificationDriveURL.path];
        return;
    }
    
    BOOL steamDrive = NO;
    for (NSString *driveKey in self.connectedDrives) { 
        if ([driveKey isEqualToString:notificationDriveURL.path]) {
            steamDrive = [[self.connectedDrives valueForKey:driveKey] boolValue];
        }
    }
    
    if(!steamDrive){
        [self deRegisterDrive:notificationDriveURL.path];
        return;
    }
    
    NSFileManager *fManager = [[NSFileManager alloc] init];
    
    NSError *renameSymbolicError;
    if(![fManager moveItemAtPath:[[NSUserDefaults standardUserDefaults] valueForKey:steamAppsLocalPath] toPath:[[NSUserDefaults standardUserDefaults] valueForKey:steamAppsSymbolicLinkPath] error:&renameSymbolicError]){
        if([[NSUserDefaults standardUserDefaults] boolForKey:growlNotificationsEnabledKey]){
            [GrowlApplicationBridge notifyWithTitle:@"Error reverting symbolic SteamApps folder"
                                        description:[renameSymbolicError localizedDescription]
                                   notificationName:@"driveUnplugFailure"
                                           iconData:nil
                                           priority:0
                                           isSticky:NO
                                       clickContext:nil];
        }
        
        [self deRegisterDrive:notificationDriveURL.path];
        self.steamDriveIsConnected = NO;
        return;
    }
    
    NSError *renameLocalError;
    NSString *currentSteamAppsPath = [[NSString alloc] initWithFormat:@"%@/SteamAppsLoc", [[[NSUserDefaults standardUserDefaults] valueForKey:steamAppsLocalPath]stringByDeletingLastPathComponent]];
    if(![fManager moveItemAtPath:currentSteamAppsPath toPath:[[NSUserDefaults standardUserDefaults] valueForKey:steamAppsLocalPath] error:&renameLocalError]){
        if([[NSUserDefaults standardUserDefaults] boolForKey:growlNotificationsEnabledKey]){
            [GrowlApplicationBridge notifyWithTitle:@"Error reverting local SteamApps folder" 
                                        description:[renameSymbolicError localizedDescription]
                                   notificationName:@"driveUnplugFailure"
                                           iconData:nil
                                           priority:0
                                           isSticky:NO
                                       clickContext:nil];
        }
        
        [self deRegisterDrive:notificationDriveURL.path];
        self.steamDriveIsConnected = NO;
        return;
    }
    
    [self deRegisterDrive:notificationDriveURL.path];
    self.steamDriveIsConnected = NO;
    if([[NSUserDefaults standardUserDefaults] boolForKey:growlNotificationsEnabledKey]){
        [GrowlApplicationBridge notifyWithTitle:@"Successfully reverted SteamApps Folders"
                                    description:[NSString stringWithFormat:@"Reverted folders after your Steam Drive(%@) was unplugged", notificationDriveURL.lastPathComponent]
                               notificationName:@"driveUnplugSuccess"
                                       iconData:nil
                                       priority:0
                                       isSticky:NO
                                   clickContext:nil];
    }
}

-(void)didMount:(NSNotification *)aNotification{
    NSURL *notificationDriveURL = [aNotification.userInfo valueForKey:NSWorkspaceVolumeURLKey];
    if(self.steamDriveIsConnected == YES){
        [self registerDrive:notificationDriveURL.path asSteamDrive:NO];
        return;
    }
    
    if(self.driveURL != nil)
        self.driveURL = nil;
    self.driveURL = notificationDriveURL;
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:growlNotificationsEnabledKey]){
        [GrowlApplicationBridge notifyWithTitle:@"Scanning Drive"
                                    description:[NSString stringWithFormat:@"Scanning %@", notificationDriveURL.path]
                               notificationName:@"driveScanBegin" 
                                       iconData:nil 
                                       priority:0 
                                       isSticky:NO 
                                   clickContext:nil];
    }
    
    if(![self scanDriveForSteamAppsFolder]){
        if([[NSUserDefaults standardUserDefaults] boolForKey:growlNotificationsEnabledKey]){
            [GrowlApplicationBridge notifyWithTitle:@"No SteamApps Folder Found"
                                        description:[NSString stringWithFormat:@"Nothing found on %@", notificationDriveURL.path]
                                   notificationName:@"driveScanFailure"
                                           iconData:nil
                                           priority:0
                                           isSticky:NO
                                       clickContext:nil];
        }
        [self registerDrive:notificationDriveURL.path asSteamDrive:NO];
        return;
    }
    
    NSFileManager *fManager = [[NSFileManager alloc] init];
    
    NSError *localFolderRename;
    NSString *newLocalPath = [[NSString alloc] initWithFormat:@"%@/SteamAppsLoc", [[[NSUserDefaults standardUserDefaults] valueForKey:steamAppsLocalPath] stringByDeletingLastPathComponent]];
    
    if(![fManager moveItemAtPath:[[NSUserDefaults standardUserDefaults] valueForKey:steamAppsLocalPath] toPath:newLocalPath error:&localFolderRename]){
        if([[NSUserDefaults standardUserDefaults] boolForKey:growlNotificationsEnabledKey]){
            [GrowlApplicationBridge notifyWithTitle:@"Error Renaming Local Steam Folder" 
                                        description:[localFolderRename localizedDescription]
                                   notificationName:@"driveSetupFailure" 
                                           iconData:nil 
                                           priority:0 
                                           isSticky:NO 
                                       clickContext:nil];
        }
        
        [self registerDrive:notificationDriveURL.path asSteamDrive:NO];
        return;
    }
    
    NSError *symbFolderRename;
    if(![fManager moveItemAtPath:[[NSUserDefaults standardUserDefaults] valueForKey:steamAppsSymbolicLinkPath ] toPath:[[NSUserDefaults standardUserDefaults] valueForKey:steamAppsLocalPath ] error:&symbFolderRename]){
        if([[NSUserDefaults standardUserDefaults] boolForKey:growlNotificationsEnabledKey]){
            [GrowlApplicationBridge notifyWithTitle:@"Error Renaming Symbolic Folder"
                                        description:[localFolderRename localizedDescription]
                                   notificationName:@"driveSetupFailure"
                                           iconData:nil
                                           priority:0
                                           isSticky:NO
                                       clickContext:nil];
        }
        
        [self registerDrive:notificationDriveURL.path asSteamDrive:NO];
        return;
    }
    
    [self registerDrive:notificationDriveURL.path asSteamDrive:YES];
    self.steamDriveIsConnected = YES;
    self.driveURL = nil;
    if([[NSUserDefaults standardUserDefaults] boolForKey:growlNotificationsEnabledKey]){
        [GrowlApplicationBridge notifyWithTitle:@"Successfully setup Steam Drive"
                                    description:[NSString stringWithFormat:@"%@ is your Steam Drive.", notificationDriveURL.lastPathComponent]
                               notificationName:@"driveSetupSuccess"
                                       iconData:nil
                                       priority:0
                                       isSticky:NO
                                   clickContext:nil];
    }
    
}

-(void)registerDrive:(NSString *)drive asSteamDrive:(BOOL)sDrive{
    if(self.connectedDrives == nil)
        self.connectedDrives = [[NSMutableDictionary alloc] init];
    
    [self.connectedDrives setValue:[NSNumber numberWithBool:sDrive] forKey:drive];
}

-(void)deRegisterDrive:(NSString *)drive{
    if(self.connectedDrives == nil)
        return;
    [self.connectedDrives removeObjectForKey:drive];
}

-(BOOL)scanDriveForSteamAppsFolder{
    NSFileManager *fManager = [[NSFileManager alloc] init];
    
    BOOL steamAppsFound = NO;
    
    for (NSString *filePath in [fManager enumeratorAtPath:self.driveURL.path]) {
        if ([filePath.lastPathComponent isEqualToString:@"SteamApps"]){
            steamAppsFound = YES;
            break;
        }
    }
    return steamAppsFound;
}
@end