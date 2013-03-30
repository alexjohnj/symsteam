//
//  UpdatesPreferencesViewController.m
//  SymSteam
//
//  Created by Alex Jackson on 08/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UpdatesPreferencesViewController.h"

@interface UpdatesPreferencesViewController ()

@end

@implementation UpdatesPreferencesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(NSString *)identifier{
    return @"Update Prefs";
}

-(NSString *)toolbarItemLabel{
    return NSLocalizedString(@"updatePreferencePaneTitle", nil);
}

-(NSImage *)toolbarItemImage{
    return [NSImage imageNamed:NSImageNameNetwork];
}

@end
