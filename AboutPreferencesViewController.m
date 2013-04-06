//
//  AboutPreferencesViewController.m
//  SymSteam
//
//  Created by Alex Jackson on 08/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AboutPreferencesViewController.h"

@implementation AboutPreferencesViewController
@synthesize aboutDescription = _aboutDescription;
@synthesize versionLabel = _versionLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(IBAction)quitApplication:(id)sender{
    if([NSEvent modifierFlags] == NSAlternateKeyMask){
        AppDelegate *appDelegate = (AppDelegate *)[NSApp delegate];
        
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Reset SymSteam", nil)
                                         defaultButton:NSLocalizedString(@"OK", nil)
                                       alternateButton:NSLocalizedString(@"Cancel", nil)
                                           otherButton:nil
                             informativeTextWithFormat:NSLocalizedString(@"Reset SymSteam Confirmation", nil)];
        
        [alert beginSheetModalForWindow:appDelegate.preferencesWindowController.window 
                          modalDelegate:self
                         didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
                            contextInfo:@"resetConfirmSheet"];
    }
    
    else{
        [[NSApplication sharedApplication] terminate:self];
    }
}

-(void)viewWillAppear{
    NSData *creditsRTF = [[NSData alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"Credits" withExtension:@"rtf"]];
    NSAttributedString *credits = [[NSAttributedString alloc] initWithRTF:creditsRTF documentAttributes:NULL];
    self.aboutDescription.textStorage.attributedString = credits;
    
    self.versionLabel.stringValue = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

#pragma mark - Completion Handlers

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo{
    AppDelegate *appDelegate = (AppDelegate *)[NSApp delegate];
    NSString *contextInfoString = (__bridge NSString *)contextInfo;
    
    if([contextInfoString isEqualToString:@"resetConfirmSheet"]){
        if(returnCode == NSAlertDefaultReturn){
            NSDictionary *defaults = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
            for(NSString *key in defaults){
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
            }
            [[NSUserDefaults standardUserDefaults] synchronize];
            [alert.window orderOut:self];
            
            NSAlert *doneAlert = [[NSAlert alloc] init];
            [doneAlert setMessageText:NSLocalizedString(@"Done", nil)];
            [doneAlert addButtonWithTitle:NSLocalizedString(@"Quit", nil)];
            [doneAlert setInformativeText:NSLocalizedString(@"SymSteam Reset Success", nil)];
            [doneAlert beginSheetModalForWindow:appDelegate.preferencesWindowController.window
                                  modalDelegate:self
                                 didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
                                    contextInfo:@"resetCompleteSheet"];
        }
    }

    if([contextInfoString isEqualToString:@"resetCompleteSheet"]){
        [appDelegate.preferencesWindowController.window orderOut:alert];
        [NSApp terminate:self];
    }
}

#pragma mark - MASPreferences Window Setters

-(NSString *)identifier{
    return @"Info Prefs";
}

-(NSString *)toolbarItemLabel{
    return NSLocalizedString(@"About Preference Pane Title", @"About label for preferences toolbar");
}

-(NSImage *)toolbarItemImage{
    return [NSImage imageNamed:NSImageNameInfo];
}

@end
