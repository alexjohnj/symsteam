//
//  AppDelegate.h
//  SymSteam
//
//  Created by Alex Jackson on 02/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppController.h"
#import "SetupWindowController.h"
#import "PreferencesController.h"
#import <Growl/Growl.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (strong) AppController *aController;
@property (strong) SetupWindowController *setupController;
@property (strong) PreferencesController *prefController;

-(void)testGrowlNotifications;

@end
