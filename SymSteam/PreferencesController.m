//
//  PreferencesController.m
//  SymSteam
//
//  Created by Alex Jackson on 15/02/2012.


#import "PreferencesController.h"

@implementation PreferencesController

static NSString * const steamAppsLocalPathKey = @"steamAppsLocalPath";
static NSString * const steamAppsSymbolicLinkPathKey = @"steamAppsSymbolicLinkPath";
static NSString * const symbolicPathDestinationKey = @"symbolicPathDestination";

@synthesize localPathTextField, symbolicPathTextField, growlNotificationsCheckBox;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

-(IBAction)toggleGrowlNotifications:(id)sender{
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(IBAction)chooseLocalSteamAppsPath:(id)sender{
    NSOpenPanel *oPanel = [[NSOpenPanel alloc] init];
    oPanel.canChooseFiles = NO;
    oPanel.canChooseDirectories = YES;
    oPanel.canCreateDirectories = YES;
        
    [oPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
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

-(IBAction)chooseSymbolicSteamAppsPath:(id)sender{
    NSOpenPanel *oPanel = [[NSOpenPanel alloc] init];
    oPanel.canChooseDirectories = YES;
    oPanel.canCreateDirectories = YES;
    
    [oPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
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
                newPath = [newPath URLByAppendingPathComponent:@"SteamAppSymb" isDirectory:YES];
                
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

-(IBAction)quitApplication:(id)sender{
    [[NSApplication sharedApplication] terminate:self];
}

-(IBAction)aboutApplication:(id)sender{
    [[NSApplication sharedApplication] orderFrontStandardAboutPanel:self];
}

@end