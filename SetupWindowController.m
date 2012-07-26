//
//  SetupWindowController.m
//  SymSteam
//
//  Created by Alex Jackson on 03/02/2012.

#import "SetupWindowController.h"
#import "AppDelegate.h"

@implementation SetupWindowController

static NSString * const steamAppsSymbolicLinkPathKey = @"steamAppsSymbolicLinkPath";
static NSString * const steamAppsLocalPathKey = @"steamAppsLocalPath";
static NSString * const setupComplete = @"setupComplete";
static NSString * const symbolicPathDestinationKey = @"symbolicPathDestination";
static NSString * const growlNotificationsEnabledKey = @"growlNotificationsEnabled";

#pragma mark - Window Lifecycle methods

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        _symLinkPathProvided = NO;
        _nonSymLinkPathProvided = NO;
        _formComplete = NO;
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    NSLog(@"Loaded");
}

#pragma mark - UI Code

- (IBAction)choosePathToSymLink:(id)sender{
    NSOpenPanel *oPanel = [[NSOpenPanel alloc] init];
    oPanel.canChooseDirectories = YES;
    oPanel.allowsMultipleSelection = NO;
    oPanel.resolvesAliases = NO;
    
    NSArray *libArray = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    
    //TODO: simplify to @"%@", [(libArray[0]) stringByAppendingLastPathComponent:@"Steam"];
    NSURL *directoryURLConstruct = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Steam", libArray[0]]];
    oPanel.directoryURL = directoryURLConstruct;
    
    [oPanel beginSheetModalForWindow:self.window
                   completionHandler:^(NSInteger result) {
                       switch (result) {
                           case NSFileHandlingPanelOKButton:
                               self.pathToSymLinkField.stringValue = oPanel.URL.path;
                               self.symLinkPathProvided = YES;
                               [self checkPathsProvided];
                               break;
                               
                           default:
                               if(self.symLinkPathProvided == YES)
                                   self.symLinkPathProvided = NO;
                               [self checkPathsProvided];
                               break;
                       }
                   }];
}

- (IBAction)choosePathToNonSymLink:(id)sender{
    NSOpenPanel *oPanel = [[NSOpenPanel alloc] init];
    oPanel.canChooseDirectories = YES;
    oPanel.allowsMultipleSelection = NO;
    
    NSArray *libArray = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    
    //TODO: simplify to @"%@", [(libArray[0]) stringByAppendingLastPathComponent:@"Steam"];
    NSURL *directoryURLConstruct = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Steam", libArray[0]]];
    oPanel.directoryURL = directoryURLConstruct;
    
    [oPanel beginSheetModalForWindow:self.window
                   completionHandler:^(NSInteger result) {
                       switch (result) {
                           case NSFileHandlingPanelOKButton:
                               self.pathToNonSymLinkField.stringValue = oPanel.URL.path;
                               self.nonSymLinkPathProvided = YES;
                               [self checkPathsProvided];
                               break;
                               
                           default:
                               if(self.nonSymLinkPathProvided = YES)
                                   self.nonSymLinkPathProvided = NO;
                               [self checkPathsProvided];
                               break;
                       }
                   }];
}

- (IBAction)doneButtonPressed:(id)sender{
    NSString *providedLocalPath = [[NSString alloc] initWithString:self.pathToNonSymLinkField.stringValue];
    NSString *providedLocalSymbolicPath = [[NSString alloc] initWithString:self.pathToSymLinkField.stringValue];
    NSFileManager *fManager = [[NSFileManager alloc] init];
    
    NSDictionary *symbolicLinkAttributes = [fManager attributesOfItemAtPath:providedLocalSymbolicPath error:nil];
    if (![[symbolicLinkAttributes fileType] isEqualToString:NSFileTypeSymbolicLink]) {
        NSAlert *symbolicLinkNotSymbolicLinkAlert = [[NSAlert alloc] init];
        [symbolicLinkNotSymbolicLinkAlert setMessageText:@"Invalid Symbolic Link."];
        [symbolicLinkNotSymbolicLinkAlert setInformativeText:@"The symbolic link you provided to your SteamApps folder isn't actually a symbolic link!"];
        [symbolicLinkNotSymbolicLinkAlert addButtonWithTitle:@"OK"];
        [symbolicLinkNotSymbolicLinkAlert beginSheetModalForWindow:self.window
                                                     modalDelegate:nil
                                                    didEndSelector:NULL
                                                       contextInfo:NULL];
        return;
    }
    
    NSString *steamAppsLocalPath = [[NSString alloc] init];
    NSString *steamAppsSymbolicLinkPath = [[NSString alloc] init];
    
    if(![providedLocalPath.lastPathComponent isEqualToString:@"SteamApps"]){
        NSError *moveLocalFolderError;
        
        NSURL *newLocalPath = [[NSURL alloc] initFileURLWithPath:providedLocalPath isDirectory:YES];
        newLocalPath = [newLocalPath URLByDeletingLastPathComponent];
        newLocalPath = [newLocalPath URLByAppendingPathComponent:@"SteamApps" isDirectory:YES];
        
        if(![fManager moveItemAtPath:providedLocalPath toPath:newLocalPath.path error:&moveLocalFolderError]){
            NSAlert *alert = [NSAlert alertWithMessageText:@"Error Renaming SteamApps Folder"
                                             defaultButton:@"OK"
                                           alternateButton:nil
                                               otherButton:nil
                                 informativeTextWithFormat:@"%@", moveLocalFolderError.localizedDescription];
            [alert beginSheetModalForWindow:self.window
                              modalDelegate:nil
                             didEndSelector:NULL
                                contextInfo:NULL];
            return;
        }
        steamAppsLocalPath = newLocalPath.path;
    }
    
    else{
        steamAppsLocalPath = providedLocalPath;
    }
    
    if(![providedLocalSymbolicPath.lastPathComponent isEqualToString:@"SteamAppsSymb"]){
        NSURL *newSymbPath = [[NSURL alloc] initFileURLWithPath:providedLocalSymbolicPath isDirectory:YES];
        newSymbPath = [newSymbPath URLByDeletingLastPathComponent];
        newSymbPath = [newSymbPath URLByAppendingPathComponent:@"SteamAppsSymb"];
        
        NSError *renameSymbolicFolderError;
        if (![fManager moveItemAtPath:providedLocalSymbolicPath toPath:newSymbPath.path error:&renameSymbolicFolderError]) {
            NSAlert *alert = [NSAlert alertWithMessageText:@"Error Renaming SteamApps Symbolic Folder"
                                             defaultButton:@"OK"
                                           alternateButton:nil
                                               otherButton:nil
                                 informativeTextWithFormat:@"%@", renameSymbolicFolderError.localizedDescription];
            
            [alert beginSheetModalForWindow:self.window
                              modalDelegate:nil
                             didEndSelector:NULL
                                contextInfo:NULL];
            return;
        }
        steamAppsSymbolicLinkPath = newSymbPath.path;
    }
    else{
        steamAppsSymbolicLinkPath = providedLocalSymbolicPath;
    }
    
    NSString *symbolicPathDestination = [fManager destinationOfSymbolicLinkAtPath:steamAppsSymbolicLinkPath error:nil];
    
    [[NSUserDefaults standardUserDefaults] setValue:steamAppsLocalPath forKey:steamAppsLocalPathKey];
    [[NSUserDefaults standardUserDefaults] setValue:steamAppsSymbolicLinkPath forKey:steamAppsSymbolicLinkPathKey];
    [[NSUserDefaults standardUserDefaults] setValue:symbolicPathDestination forKey:symbolicPathDestinationKey];
    [[NSUserDefaults standardUserDefaults] setValue:@YES forKey:setupComplete];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSAlert *successAlert = [NSAlert alertWithMessageText:@"Setup Complete."
                                            defaultButton:@"Done"
                                          alternateButton:nil
                                              otherButton:nil
                                informativeTextWithFormat:@"Setup has finished. In order to access SymSteam's preferences, hold down the option (⎇) key while launching SymSteam or click on SymSteam's icon once it has been launched."];
    [successAlert beginSheetModalForWindow:self.window
                             modalDelegate:self
                            didEndSelector:@selector(alertDidEnd:resultCode:contextInfo:)
                               contextInfo:@"setupSuccessAlert"];
}

- (IBAction)createSymbolicLink:(id)sender {
    if(!self.symbolicLinkGuideSheet)
        self.symbolicLinkGuideSheet = [[SymbolicLinkGuideController alloc] initWithWindowNibName:@"SymbolicLinkGuideSheet"];
    [NSApp beginSheet:self.symbolicLinkGuideSheet.window
       modalForWindow:self.window
        modalDelegate:self
       didEndSelector:NULL
          contextInfo:NULL];
}

- (IBAction)quitSetup:(id)sender {
    [[NSApplication sharedApplication] terminate:self];
}

- (void)checkPathsProvided{
    if(self.symLinkPathProvided == YES && self.nonSymLinkPathProvided == YES)
        self.formComplete = YES;
    
    else
        self.formComplete = NO;
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
        AppDelegate *appDelegate = (AppDelegate *)[NSApp delegate];
        [appDelegate.aController performInitialDriveScan];
        [appDelegate.aController startWatchingDrives];
    }
    
}
@end