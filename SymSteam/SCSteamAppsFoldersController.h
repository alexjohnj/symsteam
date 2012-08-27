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

- (BOOL)makeSymbolicSteamAppsPrimary;
- (BOOL)makeLocalSteamAppsPrimary;
- (BOOL)externalSteamAppsFolderExists;
- (void)performInitialDriveScan;

@end
