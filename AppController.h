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
- (void)displayGenericErrorNotification; // Displays the default error message "Something's gone wrong! Check the console". I'll be getting rid of this at some stage and adding detailed errors.

@end
