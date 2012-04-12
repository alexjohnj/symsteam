//
//  SymbolicLinkGuideController.m
//  SymSteam
//
//  Created by Alex Jackson on 07/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SymbolicLinkGuideController.h"

@implementation SymbolicLinkGuideController

@synthesize steamAppsLocation = _steamAppsLocation;
@synthesize createSymbolicLinkButton = _createButton;

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
- (IBAction)locateSteamAppsFolder:(id)sender {
    NSOpenPanel *oPanel = [[NSOpenPanel alloc] init];
    oPanel.canChooseFiles = NO;
    oPanel.canChooseDirectories = YES;
    
    [oPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        switch (result) {
            case NSFileHandlingPanelOKButton:
                self.steamAppsLocation = oPanel.URL;
                [self.createSymbolicLinkButton setEnabled:YES];
                break;
        }
    }];
    
}
- (IBAction)createSymbolicLink:(id)sender {
    SymbolicLinkCreator *symCreator = [[SymbolicLinkCreator alloc] initWithSymbolicLinkDestination:self.steamAppsLocation];
    NSError *symbolicLinkCreationError;
    
    if([symCreator createSymbolicLink:&symbolicLinkCreationError]){
        NSAlert *alert = [NSAlert alertWithMessageText:@"Success!"
                                         defaultButton:@"OK"
                                       alternateButton:nil
                                           otherButton:nil
                             informativeTextWithFormat:[NSString stringWithFormat:@"Successfully made a symbolic link to %@.", self.steamAppsLocation.path]];
        [alert beginSheetModalForWindow:self.window 
                          modalDelegate:self 
                         didEndSelector:@selector(sheetDidEnd:resultCode:contextInfo:) 
                            contextInfo:@"successSymbolicCreateSheet"];
    }
    
    else {
        NSAlert *alert = [NSAlert alertWithMessageText:@"There was a problem creating the symbolic link"
                                         defaultButton:@"OK"
                                       alternateButton:nil
                                           otherButton:nil
                             informativeTextWithFormat:[symbolicLinkCreationError localizedDescription]];
        [alert beginSheetModalForWindow:self.window 
                          modalDelegate:self 
                         didEndSelector:NULL 
                            contextInfo:NULL];
    }
    
}

- (void)sheetDidEnd:(NSWindow *)sheet resultCode:(NSInteger)resultCode contextInfo:(void *)contextInfo {
	NSString *contextInfoString = (__bridge NSString *)contextInfo;
    if([contextInfoString isEqualToString:@"successSymbolicCreateSheet"]){
        [NSApp endSheet:self.window];
        [self.window orderOut:self];
    }
}

- (IBAction)dismissSheet:(id)sender {
    [NSApp endSheet:self.window];
    [self.window orderOut:self];
}

@end
