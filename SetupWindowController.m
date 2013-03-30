//
//  SetupWindowController.m
//  SymSteam
//
//  Created by Alex Jackson on 03/02/2012.

#import "SetupWindowController.h"
#import "AppDelegate.h"

@implementation SetupWindowController

static NSString * const setupComplete = @"setupComplete";
static NSString * const symbolicPathDestinationKey = @"symbolicPathDestination";
static NSString * const growlNotificationsEnabledKey = @"growlNotificationsEnabled";

#pragma mark - Window Lifecycle methods

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
}

///////////////////////////////////////

- (IBAction)chooseSymbolicLinkDestination:(id)sender{
    NSOpenPanel *oPanel = [[NSOpenPanel alloc] init];
    oPanel.canChooseFiles = NO;
    oPanel.canChooseDirectories = YES;
    oPanel.canCreateDirectories = YES;
    
    [oPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result){
        if(result == NSFileHandlingPanelOKButton){
            [oPanel orderOut:self];
            if([self checkSymbolicLinkDestinationProvided:oPanel.URL]){
                self.symbolicLinkDestination = oPanel.URL;
                [self.nextButton setEnabled:YES];
            }
        }
    }];
}

- (BOOL)checkSymbolicLinkDestinationProvided:(NSURL *)url{
    SCSetupController *setupController = [[SCSetupController alloc] init];
    
    // Check that the provided path is on an external drive
    
    if(![setupController folderIsOnExternalDrive:url]){
        NSAlert *invalidDestinationAlert = [NSAlert alertWithMessageText:@"Error"
                                                           defaultButton:@"OK"
                                                         alternateButton:nil
                                                             otherButton:nil
                                               informativeTextWithFormat:@"The folder you provided is not on an external drive."];
        [invalidDestinationAlert beginSheetModalForWindow:self.window modalDelegate:nil didEndSelector:nil contextInfo:NULL];
        return NO;
    }
    
    // Check that the drive has a UUID
    
    NSURL *driveURL = [NSURL fileURLWithPathComponents:@[url.pathComponents[0], url.pathComponents[1], url.pathComponents[2]]]; //Should produce /Volumes/DriveName
    DASessionRef session = DASessionCreate(kCFAllocatorDefault);
    DADiskRef drive = DADiskCreateFromVolumePath(kCFAllocatorDefault, session, (__bridge CFURLRef)driveURL);
    CFRelease(session);
    if(![setupController getDriveUUID:drive]){
        NSAlert *noUUIDFound = [NSAlert alertWithMessageText:@"Error"
                                               defaultButton:@"OK"
                                             alternateButton:nil
                                                 otherButton:nil
                                   informativeTextWithFormat:@"The drive which the SteamApps folder is on does not have a UUID. Please ensure that the drive is HFS formatted."];
        [noUUIDFound beginSheetModalForWindow:self.window modalDelegate:nil didEndSelector:nil contextInfo:NULL];
        CFRelease(drive);
        return NO;
    }
    
    CFRelease(drive);
    return YES;
}

- (IBAction)nextButtonPressed:(id)sender{
    SCSetupController *setupController = [[SCSetupController alloc] init];
    NSError __autoreleasing *symbolicLinkCreationError;
    if(![setupController createSymbolicLinkToFolder:self.symbolicLinkDestination error:&symbolicLinkCreationError]){
        NSAlert *alert = [NSAlert alertWithError:symbolicLinkCreationError];
        [alert beginSheetModalForWindow:self.window modalDelegate:nil didEndSelector:nil contextInfo:NULL];
    }
    DADiskRef disk = [setupController createDADiskFromDrivePath:[NSURL fileURLWithPathComponents:(@[self.symbolicLinkDestination.pathComponents[0],
                                                                                                  self.symbolicLinkDestination.pathComponents[1],
                                                                                                  self.symbolicLinkDestination.pathComponents[2]])]];
    [setupController saveSymbolicLinkDestinationToUserDefaults:self.symbolicLinkDestination];
    [setupController saveDriveUUIDToUserDefaults:disk];
    CFRelease(disk);
    NSAlert *successAlert = [NSAlert alertWithMessageText:@"Setup Complete."
                                            defaultButton:@"Done"
                                          alternateButton:nil
                                              otherButton:nil
                                informativeTextWithFormat:@"Setup has finished. In order to access SymSteam's preferences, hold down the option (⎇) key while launching SymSteam or click on SymSteam's icon once it has been launched."];
    [successAlert beginSheetModalForWindow:self.window modalDelegate:self didEndSelector:@selector(alertDidEnd:resultCode:contextInfo:) contextInfo:@"setupSuccessAlert"];
}

- (IBAction)quitSetup:(id)sender {
    [[NSApplication sharedApplication] terminate:self];
}

- (void)showStartAtLoginSheet{
    NSAlert *alert = [NSAlert alertWithMessageText:@"Launch SymSteam on login?"
                                     defaultButton:@"OK"
                                   alternateButton:@"No thanks"
                                       otherButton:nil
                         informativeTextWithFormat:@"Do you want SymSteam to automatically launch when you login? It is strongly recommended that you do."];
    [alert beginSheetModalForWindow:self.window
                      modalDelegate:self
                     didEndSelector:@selector(alertDidEnd:resultCode:contextInfo:)
                        contextInfo:@"startOnLoginAlert"];
}

- (void)alertDidEnd:(NSAlert *)alert resultCode:(NSInteger)resultCode contextInfo:(void *)contextInfo{
    NSString *contextInfoString = (__bridge NSString *)contextInfo;
    
    if([contextInfoString isEqualToString:@"setupSuccessAlert"]){
        [[NSUserDefaults standardUserDefaults] setValue:@YES forKey:@"setupComplete"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [alert.window orderOut:self];
        [self showStartAtLoginSheet];
    }
    
    if([contextInfoString isEqualToString:@"startOnLoginAlert"]){
        if(resultCode == NSAlertDefaultReturn){
            SCLoginController *loginController = [[SCLoginController alloc] init];
            NSURL *bundleURL = [[NSBundle mainBundle] bundleURL];
            [loginController addApplicationToLoginItems:bundleURL];
        }
        [self close];
        [[SCSteamDiskManager steamDiskManager] startWatchingForDrives];
    }
    
}
@end