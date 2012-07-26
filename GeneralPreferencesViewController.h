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

@interface GeneralPreferencesViewController : NSViewController <MASPreferencesViewController>

@property (weak) IBOutlet NSTextField *localPathTextField;
@property (weak) IBOutlet NSTextField *symbolicPathTextField;
@property (weak) IBOutlet NSButton *growlNotificationsCheckBox;
@property (weak) IBOutlet NSButton *startAtLoginCheckbox;

- (IBAction)chooseLocalSteamAppsPath:(id)sender;
- (IBAction)chooseSymbolicSteamAppsPath:(id)sender;
- (IBAction)toggleGrowlNotifications:(id)sender;
- (IBAction)toggleLaunchSymSteamAtLogin:(id)sender;

@end
