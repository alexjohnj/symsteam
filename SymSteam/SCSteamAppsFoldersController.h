//
//  SCSteamAppsFoldersController.h
//  SymSteam
//
//  Created by Alex Jackson on 27/08/2012.
//
//

#import <Foundation/Foundation.h>
#import "SCNotificationCenter.h"
#import "SCSteamDiskManager.h"

@interface SCSteamAppsFoldersController : NSObject

- (BOOL)makeSymbolicSteamAppsPrimaryWithSuccessNotifications:(BOOL)showSuccessNotifications; // still respects the user's notification settings.
- (BOOL)makeLocalSteamAppsPrimaryWithSuccessNotifications:(BOOL)showSuccessNotifications;
- (BOOL)makeSymbolicSteamAppsPrimary;
- (BOOL)makeLocalSteamAppsPrimary;

- (BOOL)externalSteamAppsFolderExists;
- (void)performInitialDriveScan;

@end
