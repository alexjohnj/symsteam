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
    NSLog(@"Drive unmounted");
    NSFileManager *fmanager = [[NSFileManager alloc] init];
    
    BOOL steamDrive = NO;
    
    if(self.connectedDrives == nil)
        self.connectedDrives = [[NSMutableDictionary alloc] init];
    
    for (NSString *driveKey in self.connectedDrives) { //check to see if the drive is in our dictionary of connected drives. 
        if ([driveKey isEqualToString:[[aNotification.userInfo valueForKey:NSWorkspaceVolumeURLKey]path]]) { 
            steamDrive = [[self.connectedDrives valueForKey:driveKey] boolValue]; //if so, set the value of steam drive to the value of the drive (yes or no)
        }
    }
    
    if(!steamDrive){ // if it isn't a steam drive, we can just ignore it. 
        if([self.connectedDrives objectForKey:[[aNotification.userInfo valueForKey:NSWorkspaceVolumeURLKey] path]] == nil){
            return;
        }
        else{
        [self.connectedDrives removeObjectForKey:[[aNotification.userInfo valueForKey:NSWorkspaceVolumeURLKey]path]]; //get rid of the drive from the dictionary
        return;
        }
    }
    
    NSError *moveSymError;
    if(![fmanager moveItemAtPath:steamAppsPath toPath:[[NSUserDefaults standardUserDefaults]valueForKey:steamAppsSymbolicLinkPath] error:&moveSymError]){ //renaming the SteamApps folder tot he symbolic link
        NSLog(@"42 - Error moving sym file from %@ to %@ with error %@", steamAppsPath, [[NSUserDefaults standardUserDefaults] valueForKey:steamAppsSymbolicLinkPath], [moveSymError localizedDescription]);
        return;
    }
    
    NSError *moveLocalError;
    if(![fmanager moveItemAtPath:[[NSUserDefaults standardUserDefaults] valueForKey:steamAppsLocalPath] toPath:steamAppsPath error:&moveLocalError]){ //rename the local folder to SteamApps
        NSLog(@"48 - Error moving item at path %@ to path %@ with error %@", [[NSUserDefaults standardUserDefaults] valueForKey:steamAppsPath], steamAppsPath, [moveLocalError localizedDescription]);
        return;
    }
    
    if(self.steamDriveIsConnected == YES)
        self.steamDriveIsConnected = NO;
    [self.connectedDrives removeObjectForKey:[[aNotification.userInfo valueForKey:NSWorkspaceVolumeURLKey]path]]; //remove the drive from our list of drives
}

-(void)didMount:(NSNotification *)aNotification{
    NSLog(@"Drive mounted");
    NSLog(@"%@", [[aNotification.userInfo valueForKey:NSWorkspaceVolumeURLKey] path]);
    
    if(self.connectedDrives == nil)
        self.connectedDrives = [[NSMutableDictionary alloc] init];
    
    [self.connectedDrives setObject:[NSNumber numberWithBool:NO] forKey:[[aNotification.userInfo valueForKey:NSWorkspaceVolumeURLKey]path]]; //add the newly connected drive to our list of drives. We assume it isn't a steam drive
    
    if(self.steamDriveIsConnected == YES){
        return; //since we can only handle having one drive connected, we'll automatically quit this method if one is already connected. 
    }
    
    if(self.driveURL != nil)
        self.driveURL = nil;
    
    self.driveURL = [aNotification.userInfo valueForKey:NSWorkspaceVolumeURLKey];
    
    if(![self scanDriveForSteamAppsFolder]){ //scan for our SteamApps folder
        NSLog(@"No steam apps folder found");
        self.driveURL = nil;
        return;
    }
    
    NSFileManager *fManager = [[NSFileManager alloc] init];
    
    if([fManager fileExistsAtPath:[[NSUserDefaults standardUserDefaults] valueForKey:steamAppsSymbolicLinkPath]] == NO && [fManager fileExistsAtPath:[[NSUserDefaults standardUserDefaults] valueForKey:steamAppsLocalPath]]){ //we check to see if the symbolic link exists. If it doesn't and the local folder does, we can assume that the symbolic link is already called SteamApps.
        self.steamDriveIsConnected = YES;
        [self.connectedDrives setObject:[NSNumber numberWithBool:YES] forKey:[[aNotification.userInfo valueForKey:NSWorkspaceVolumeURLKey]path]];
        self.driveURL = nil;
        return;
    }
    
    else{
        if([fManager fileExistsAtPath:self.steamAppsPath] && [fManager fileExistsAtPath:[[NSUserDefaults standardUserDefaults] valueForKey:steamAppsLocalPath]] == NO){ //check that our steam apps file exists and our local folder doesn't exist
            NSError *moveLocalError;
            if(![fManager moveItemAtPath:self.steamAppsPath toPath:[[NSUserDefaults standardUserDefaults] valueForKey:steamAppsLocalPath] error:&moveLocalError]){ //rename current steam apps to steam local, 
                NSLog(@"80 - Error moving item at path %@ to path %@ with error %@", self.steamAppsPath, [[NSUserDefaults standardUserDefaults] valueForKey:steamAppsLocalPath], [moveLocalError localizedDescription]);
                
                self.steamDriveIsConnected = NO;
                return;
            }
        }
        
        NSError *moveSymError;
        if(![fManager moveItemAtPath:[[NSUserDefaults standardUserDefaults] valueForKey:steamAppsSymbolicLinkPath] toPath:self.steamAppsPath error:&moveSymError]){ //rename symbolic link to SteamApps
            NSLog(@"85 - Error moving item at path %@ to path %@ with error %@", [[NSUserDefaults standardUserDefaults] valueForKey:steamAppsSymbolicLinkPath], self.steamAppsPath, [moveSymError localizedDescription]);
            self.steamDriveIsConnected = NO;
            return;
        }
        
        self.steamDriveIsConnected = YES; // if everything works, we can tell the application that everything has been set up properly. 
        [self.connectedDrives setObject:[NSNumber numberWithBool:YES] forKey:[[aNotification.userInfo valueForKey:NSWorkspaceVolumeURLKey]path]];
        self.driveURL = nil;
    }
    
    NSLog(@"Setup completed succesfully.");
}

-(BOOL)scanDriveForSteamAppsFolder{
    NSFileManager *fManager = [[NSFileManager alloc] init];
    
    NSString *filePath;
    
    for (filePath in [fManager enumeratorAtPath:self.driveURL.path]) {
        if ([filePath.lastPathComponent isEqualToString:@"SteamApps"]){
            NSLog(@"Found it");
            return YES;
        }
    }
    return NO;
}
@end