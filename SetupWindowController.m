//
//  SetupWindowController.m
//  SymSteam
//
//  Created by Alex Jackson on 03/02/2012.

#import "SetupWindowController.h"
#import "AppDelegate.h"

@implementation SetupWindowController
@synthesize quitSetupButton = _quitSetupButton;
@synthesize pathToSymLinkField = _pathToSymLinkField, pathToNonSymLinkField = _pathToNonSymLinkField, continueButton = _continueButton, createSymbolicLinkButton = _createSymbolicLinkButton;
@synthesize symLinkPathProvided = _symLinkPathProvided, nonSymLinkPathProvided = _nonSymLinkPathProvided, formComplete = _formComplete;
@synthesize symbolicLinkGuideSheet = _symbolicLinkGuideSheet;

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
    NSURL *directoryURLConstruct = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Steam", [libArray objectAtIndex:0]]];
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
    NSURL *directoryURLConstruct = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Steam", [libArray objectAtIndex:0]]];
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
    
    NSString *steamAppsLocalPath = [[NSString alloc] init];
    NSString *steamAppsSymbolicLinkPath = [[NSString alloc] init];
    
    if(![providedLocalPath.lastPathComponent isEqualToString:@"SteamApps"]){
        NSError *moveLocalFolderError;
        
        NSURL *newLocalPath = [[NSURL alloc] initFileURLWithPath:providedLocalPath isDirectory:YES];
        newLocalPath = [newLocalPath URLByDeletingLastPathComponent];
        newLocalPath = [newLocalPath URLByAppendingPathComponent:@"SteamApps" isDirectory:YES];
        
        if(![fManager moveItemAtPath:providedLocalPath toPath:newLocalPath.path error:&moveLocalFolderError]){
            NSAlert *alert = [NSAlert alertWithMessageText:@"Error Renaming SteamApps Folder" 
                                             defaultButton:@"Choose New Path" 
                                           alternateButton:@"Quit" 
                                               otherButton:nil 
                                 informativeTextWithFormat:[moveLocalFolderError localizedDescription]];
            NSInteger result = [alert runModal];
            if(result == NSAlertDefaultReturn)
                return;
            if(result == NSAlertAlternateReturn)
                [[NSApplication sharedApplication] terminate:self];
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
                                             defaultButton:@"Choose New Path" 
                                           alternateButton:@"Quit" 
                                               otherButton:nil 
                                 informativeTextWithFormat:[renameSymbolicFolderError localizedDescription]];
            
            NSInteger result = [alert runModal];
            if(result == NSAlertDefaultReturn)
                return;
            if(result == NSAlertAlternateReturn)
                [[NSApplication sharedApplication] terminate:self];
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
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:setupComplete];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSAlert *successAlert = [NSAlert alertWithMessageText:@"Success!" 
                                            defaultButton:@"OK" 
                                          alternateButton:nil 
                                              otherButton:nil 
                                informativeTextWithFormat:@"Successfully setup SymSteam"];
    [successAlert beginSheetModalForWindow:self.window modalDelegate:self didEndSelector:@selector(sheetDidEnd:resultCode:contextInfo:) contextInfo:@"setupSuccessAlert"];
}

- (IBAction)createSymbolicLink:(id)sender {
    if(!_symbolicLinkGuideSheet)
        _symbolicLinkGuideSheet = [[SymbolicLinkGuideController alloc] initWithWindowNibName:@"SymbolicLinkGuideSheet"];
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

- (void)sheetDidEnd:(NSWindow *)sheet resultCode:(NSInteger)resultCode contextInfo:(void *)contextInfo{
    NSString *contextInfoString = (__bridge NSString *)contextInfo;
    
    if([contextInfoString isEqualToString:@"setupSuccessAlert"]){
        [self close];
        AppDelegate *appDelegate = (AppDelegate *)[NSApp delegate];
        [appDelegate.aController performInitialDriveScan];
        [appDelegate.aController startWatchingDrives];
    }
}
@end