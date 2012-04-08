//
//  AppDelegate.h
//  SymSteam
//
//  Created by Alex Jackson on 02/02/2012.


#import <Cocoa/Cocoa.h>
#import <Growl/Growl.h>

#import "AppController.h"
#import "SetupWindowController.h"

#import "MASPreferencesWindowController.h"
#import "AboutPreferencesViewController.h"
#import "GeneralPreferencesViewController.h"
#import "UpdatesPreferencesViewController.h"


@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (strong) AppController *aController;
@property (strong) SetupWindowController *setupController;
@property (strong) NSWindowController *preferencesWindowController;

@end