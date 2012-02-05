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

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (strong) AppController *aController;
@property (strong) SetupWindowController *setupController;

@end
