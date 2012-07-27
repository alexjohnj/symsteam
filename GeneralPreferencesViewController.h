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

@interface GeneralPreferencesViewController : NSViewController <MASPreferencesViewController>

@property (weak) IBOutlet NSTextField *localPathTextField;
@property (weak) IBOutlet NSTextField *symbolicPathTextField;
@property (weak) IBOutlet NSButton *startAtLoginCheckbox;

@property (weak) IBOutlet NSButton *notificationsCheckBox;
@property (weak) IBOutlet NSTextField *notificationsInformation;

- (IBAction)chooseLocalSteamAppsPath:(id)sender;
- (IBAction)chooseSymbolicSteamAppsPath:(id)sender;
- (IBAction)toggleGrowlNotifications:(id)sender;
- (IBAction)toggleLaunchSymSteamAtLogin:(id)sender;

@end
