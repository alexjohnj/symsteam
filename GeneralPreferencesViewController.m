//
//  GeneralPreferencesViewController.m
//  SymSteam
//
//  Created by Alex Jackson on 08/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GeneralPreferencesViewController.h"
#import "AppDelegate.h"

static NSString * const steamAppsLocalPathKey = @"steamAppsLocalPath";
static NSString * const steamAppsSymbolicLinkPathKey = @"steamAppsSymbolicLinkPath";
static NSString * const symbolicPathDestinationKey = @"symbolicPathDestination";

@interface GeneralPreferencesViewController ()

@end

@implementation GeneralPreferencesViewController

@synthesize localPathTextField = _localPathTextField, symbolicPathTextField = _symbolicPathTextField, growlNotificationsCheckBox = _growlNotificationsCheckBox;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (IBAction)chooseLocalSteamAppsPath:(id)sender{
    NSOpenPanel *oPanel = [[NSOpenPanel alloc] init];
    oPanel.canChooseFiles = NO;
    oPanel.canChooseDirectories = YES;
    oPanel.canCreateDirectories = YES;
    
    AppDelegate *appDelegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    
    [oPanel beginSheetModalForWindow:appDelegate.preferencesWindowController.window completionHandler:^(NSInteger result) {
        if(result == NSFileHandlingPanelCancelButton) 
            return;
        
        else if(result == NSFileHandlingPanelOKButton){
            if([oPanel.URL.lastPathComponent isEqualToString:@"SteamApps"])
                [[NSUserDefaults standardUserDefaults] setValue:oPanel.URL.path forKey:steamAppsLocalPathKey];
            else {
                NSURL *newPath = [[NSURL alloc] initFileURLWithPath:[oPanel.URL.path stringByDeletingLastPathComponent]];
                newPath = [newPath URLByAppendingPathComponent:@"SteamApps" isDirectory:YES];
                
                NSFileManager *fManager = [[NSFileManager alloc] init];
                NSError *renameError;
                if(![fManager moveItemAtURL:oPanel.URL toURL:newPath error:&renameError]){
                    NSAlert *renameFailAlert = [NSAlert alertWithMessageText:@"Error Renaming SteamApps Folder"
                                                               defaultButton:@"OK"
                                                             alternateButton:nil
                                                                 otherButton:nil
                                                   informativeTextWithFormat:[renameError localizedDescription]];
                    [renameFailAlert runModal];
                    return;
                }
                [[NSUserDefaults standardUserDefaults] setValue:newPath.path forKey:steamAppsLocalPathKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
    }];
    
}

- (IBAction)chooseSymbolicSteamAppsPath:(id)sender{
    NSOpenPanel *oPanel = [[NSOpenPanel alloc] init];
    oPanel.canChooseDirectories = YES;
    oPanel.canCreateDirectories = YES;
    
    AppDelegate *appDelegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    
    [oPanel beginSheetModalForWindow:appDelegate.preferencesWindowController.window completionHandler:^(NSInteger result) {
        if(result == NSFileHandlingPanelCancelButton)
            return;
        
        else if(result == NSFileHandlingPanelOKButton){
            NSFileManager *fManager = [[NSFileManager alloc] init];
            
            if([oPanel.URL.lastPathComponent isEqualToString:@"SteamAppsSymb"]){
                [[NSUserDefaults standardUserDefaults] setValue:oPanel.URL.path forKey:steamAppsSymbolicLinkPathKey];
                
                NSString *symbolicPath = [fManager destinationOfSymbolicLinkAtPath:oPanel.URL.path error:nil];  
                [[NSUserDefaults standardUserDefaults] setValue:symbolicPath forKey:symbolicPathDestinationKey];
            }
            
            else{
                NSURL *newPath = [[NSURL alloc] initFileURLWithPath:[oPanel.URL.path stringByDeletingLastPathComponent]];
                newPath = [newPath URLByAppendingPathComponent:@"SteamAppsSymb" isDirectory:YES];
                
                NSError *renameError;
                if (![fManager moveItemAtURL:oPanel.URL toURL:newPath error:&renameError]) {
                    NSAlert *renameFailAlert = [NSAlert alertWithMessageText:@"Error Renaming Symbolic SteamApps Folder"
                                                               defaultButton:@"OK"
                                                             alternateButton:nil
                                                                 otherButton:nil
                                                   informativeTextWithFormat:[renameError localizedDescription]];
                    [renameFailAlert runModal];
                    return;
                }
                [[NSUserDefaults standardUserDefaults] setValue:newPath.path forKey:steamAppsSymbolicLinkPathKey];
                
                NSString *symbolicPath = [fManager destinationOfSymbolicLinkAtPath:newPath.path error:nil];
                [[NSUserDefaults standardUserDefaults] setValue:symbolicPath forKey:symbolicPathDestinationKey];
            }
            [[NSUserDefaults standardUserDefaults] synchronize];  
        }
    }];
}

- (IBAction)toggleGrowlNotifications:(id)sender{
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Setters for MASPreferencesWindow

-(NSString *)identifier{
    return @"view1";
}

-(NSString *)toolbarItemLabel{
    return NSLocalizedString(@"General", @"Toolbar label for the general preference tab");
}

-(NSImage *)toolbarItemImage{
    return [NSImage imageNamed:NSImageNamePreferencesGeneral];
}

@end
