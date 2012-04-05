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
static NSString * const growlNotificationsEnabledKey = @"growlNotificationsEnabled";

@implementation AppController

@synthesize remoteSteamAppsFolder = _remoteSteamAppsFolder;
@synthesize steamDriveIsConnected = _steamDriveIsConnected;
@synthesize steamAppsPath = _steamAppsPath;
@synthesize connectedDrives = _connectedDrives;

-(id)init{
    self = [super init];
    if(self){
        _steamDriveIsConnected = NO;
        NSArray *libarray = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        _steamAppsPath = [[NSString alloc] initWithFormat:@"%@/Application Support/Steam/SteamApps", [libarray objectAtIndex:0]];
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
    
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:growlNotificationsEnabledKey]){
        [GrowlApplicationBridge notifyWithTitle:@"Scanning Drive"
                                    description:[NSString stringWithFormat:@"Scanning %@", notificationDriveURL.path]
                               notificationName:@"driveScanBegin" 
                                       iconData:nil 
                                       priority:0 
                                       isSticky:NO 
                                   clickContext:nil];
    }
    
    if(![self scanForSteamAppsFolderOnDrive:notificationDriveURL]){
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

-(BOOL)scanForSteamAppsFolderOnDrive:(NSURL *)drive{
    NSFileManager *fManager = [[NSFileManager alloc] init];
    __block BOOL steamAppsFound = NO;
    
    // perform a shallow scan of the drive first since most people will store the SteamApps folder on the root of their drive. This is a lot faster than just doing the deep scan. 
    
    NSArray *shallowDirectoryContent = [fManager contentsOfDirectoryAtPath:drive.path error:nil];
    [shallowDirectoryContent enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if([obj isEqualToString:@"SteamApps"]){
            steamAppsFound = YES;
            *stop = YES;
        }
    }];
    
    if(steamAppsFound == YES)
        return steamAppsFound;
    else{
        for (NSString *filePath in [fManager enumeratorAtURL:drive includingPropertiesForKeys:nil options:(NSDirectoryEnumerationSkipsHiddenFiles | NSDirectoryEnumerationSkipsPackageDescendants) errorHandler:nil]) {
            if ([filePath.lastPathComponent isEqualToString:@"SteamApps"]){
                steamAppsFound = YES;
                break;
            }
        }    
        
        return steamAppsFound;
    }
}
@end