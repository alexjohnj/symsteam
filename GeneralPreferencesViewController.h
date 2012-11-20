//
//  GeneralPreferencesViewController.h
//  SymSteam
//
//  Created by Alex Jackson on 08/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MASPreferencesViewController.h"
#import "SCLoginController.h"
#import "SCNotificationCenter.h"
#import "SCSetupController.h"

@interface GeneralPreferencesViewController : NSViewController <MASPreferencesViewController>

@property (weak) IBOutlet NSButton *startAtLoginCheckbox;
@property (weak) IBOutlet NSPathControl *externalSteamAppsFolderPathControl;

@property (weak) IBOutlet NSMatrix *notificationOptions;
@property (weak) IBOutlet NSTextField *notificationsInformation;

- (IBAction)chooseExternalSteamAppsFolderLocation:(id)sender;
- (IBAction)changeNotificationOptions:(id)sender;
- (IBAction)toggleLaunchSymSteamAtLogin:(id)sender;

@end
