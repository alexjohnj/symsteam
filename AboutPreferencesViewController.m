//
//  AboutPreferencesViewController.m
//  SymSteam
//
//  Created by Alex Jackson on 08/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AboutPreferencesViewController.h"

@interface AboutPreferencesViewController ()

@end

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
    [[NSApplication sharedApplication] terminate:self];
}

-(void)viewWillAppear{
    NSData *creditsRTF = [[NSData alloc] initWithContentsOfURL:[[NSBundle mainBundle]URLForResource:@"Credits" withExtension:@"rtf"]];
    NSAttributedString *credits = [[NSAttributedString alloc] initWithRTF:creditsRTF documentAttributes:NULL];
    self.aboutDescription.textStorage.attributedString = credits;
    
    self.versionLabel.stringValue = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

#pragma mark - MASPreferences Window Setters

-(NSString *)identifier{
    return @"Info Prefs";
}

-(NSString *)toolbarItemLabel{
    return NSLocalizedString(@"About", @"About label for preferences toolbar");
}

-(NSImage *)toolbarItemImage{
    return [NSImage imageNamed:NSImageNameInfo];
}

@end
