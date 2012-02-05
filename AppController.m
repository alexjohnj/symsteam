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

@synthesize driveURL, remoteSteamAppsFolder, steamDriveIsConnected, steamAppsPath;

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
    NSFileManager *fmanager = [[NSFileManager alloc] init];
    if(self.steamDriveIsConnected == NO || [fmanager fileExistsAtPath:[[NSUserDefaults standardUserDefaults] valueForKey:steamAppsSymbolicLinkPath]])
        return;
    else{
        NSError *moveSymError;
        if(![fmanager moveItemAtPath:steamAppsPath toPath:[[NSUserDefaults standardUserDefaults]valueForKey:steamAppsSymbolicLinkPath] error:&moveSymError]){
            NSLog(@"42 - Error moving sym file from %@ to %@ with error %@", steamAppsPath, [[NSUserDefaults standardUserDefaults] valueForKey:steamAppsSymbolicLinkPath], [moveSymError localizedDescription]);
            return;
        }
        
        NSError *moveLocalError;
        if(![fmanager moveItemAtPath:[[NSUserDefaults standardUserDefaults] valueForKey:steamAppsLocalPath] toPath:steamAppsPath error:&moveLocalError]){
            NSLog(@"48 - Error moving item at path %@ to path %@ with error %@", [[NSUserDefaults standardUserDefaults] valueForKey:steamAppsPath], steamAppsPath, [moveLocalError localizedDescription]);
            return;
        }
        
        if(self.steamDriveIsConnected == YES)
            self.steamDriveIsConnected = NO;
    }
}

-(void)didMount:(NSNotification *)aNotification{
    if(self.steamDriveIsConnected == YES){
        return;
    }
    
    if(self.driveURL != nil)
        self.driveURL = nil;
    
    self.driveURL = [aNotification.userInfo valueForKey:@"NSWorkspaceVolumeURLKey"];
    
    if(![self scanDriveForSteamAppsFolder]){
        NSLog(@"No steam apps folder found");
        return;
    }
    
    NSFileManager *fManager = [[NSFileManager alloc] init];
    if(![fManager fileExistsAtPath:[[NSUserDefaults standardUserDefaults] valueForKey:steamAppsSymbolicLinkPath]] && [fManager fileExistsAtPath:[[NSUserDefaults standardUserDefaults] valueForKey:steamAppsLocalPath]]){
        self.steamDriveIsConnected = YES;
        return;
    }
    else{
        if([fManager fileExistsAtPath:self.steamAppsPath]){
            NSError *moveLocalError;
            if(![fManager moveItemAtPath:self.steamAppsPath toPath:[[NSUserDefaults standardUserDefaults] valueForKey:steamAppsLocalPath] error:&moveLocalError]){
                NSLog(@"80 - Error moving item at path %@ to path %@ with error %@", self.steamAppsPath, [[NSUserDefaults standardUserDefaults] valueForKey:steamAppsLocalPath], [moveLocalError localizedDescription]);
                return;
            }
        }
        NSError *moveSymError;
        if(![fManager moveItemAtPath:[[NSUserDefaults standardUserDefaults] valueForKey:steamAppsSymbolicLinkPath] toPath:self.steamAppsPath error:&moveSymError]){
            NSLog(@"85 - Error moving item at path %@ to path %@ with error %@", [[NSUserDefaults standardUserDefaults] valueForKey:steamAppsSymbolicLinkPath], self.steamAppsPath, [moveSymError localizedDescription]);
            return;
        }
        self.steamDriveIsConnected = YES;  
    }
}

-(BOOL)scanDriveForSteamAppsFolder{
    NSFileManager *fManager = [[NSFileManager alloc] init];
    
    NSString *filePath;
    
    for (filePath in [fManager enumeratorAtPath:self.driveURL.path]) {
        if ([filePath.lastPathComponent isEqualToString:@"SteamApps"]) {
            self.remoteSteamAppsFolder = [self.driveURL.path stringByAppendingPathComponent:filePath];
            NSLog(@"Found a steam apps folder at %@", self.remoteSteamAppsFolder);
            return YES;
        }
    }
    return NO;
}

@end