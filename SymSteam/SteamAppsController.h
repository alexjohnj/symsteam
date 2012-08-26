//
//  SteamAppsController.h
//  SymSteam
//
//  Created by Alex Jackson on 05/04/2012.


#import <Foundation/Foundation.h>
#import <Growl/Growl.h>
#import <DiskArbitration/DiskArbitration.h>
#import "SCNotificationCenter.h"

@interface SteamAppsController : NSObject

@property (assign) BOOL steamDriveIsConnected;

DADissenterRef diskWillMount(DADiskRef disk, void *context);
void diskDidDisappear(DADiskRef disk, void *context);
DADissenterRef diskWillUnmount(DADiskRef disk, void *context);
void registerForDADiskCallbacks(void *context);

- (BOOL)makeSymbolicSteamAppsPrimary;
- (BOOL)makeLocalSteamAppsPrimary;
- (BOOL)suspectDriveIsSteamDrive:(DADiskRef)suspectDrive;
- (BOOL)externalSteamAppsFolderExists;
- (void)startWatchingForDrives;

@end
