//
//  SteamAppsController.h
//  SymSteam
//
//  Created by Alex Jackson on 05/04/2012.


#import <Foundation/Foundation.h>
#import <Growl/Growl.h>
#import "SCNotificationCenter.h"

@interface SteamAppsController : NSObject

@property (assign) BOOL steamDriveIsConnected;

- (void)didMountDrive:(NSNotification *)aNotification;
- (void)didUnMountDrive:(NSNotification *)aNotification;

- (BOOL)makeSymbolicSteamAppsPrimary;
- (BOOL)makeLocalSteamAppsPrimary;
- (BOOL)connectedDriveIsSteamDrive:(NSURL *)connectedDrive;
- (BOOL)externalSteamAppsFolderExists;

@end
