//
//  AppController.h
//  SymSteam
//
//  Created by Alex Jackson on 02/02/2012.


#import <Foundation/Foundation.h>
#import <Growl/Growl.h>
#import "SteamAppsController.h"

@interface AppController : NSObject

@property (strong) SteamAppsController *saController;

- (void)startWatchingDrives;
- (void)performInitialDriveScan;

@end
