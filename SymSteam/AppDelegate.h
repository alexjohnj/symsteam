//
//  AppDelegate.h
//  SymSteam
//
//  Created by Alex Jackson on 02/02/2012.


#import <Cocoa/Cocoa.h>
#import <Growl/Growl.h>

#import "SCSteamDiskManager.h"
#import "SCSteamAppsFoldersController.h"
#import "SetupWindowController.h"
#import "SCUserNotificationCenterDelegate.h"
#import "SCNotificationCenter.h"

#import "MASPreferencesWindowController.h"
#import "AboutPreferencesViewController.h"
#import "GeneralPreferencesViewController.h"
#import "UpdatesPreferencesViewController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (strong) SetupWindowController *setupController;
@property (strong) MASPreferencesWindowController *preferencesWindowController;
@property (strong) SCUserNotificationCenterDelegate *notificationCenterDelegate;

- (MASPreferencesWindowController *)preparePreferencesWindow;

@end