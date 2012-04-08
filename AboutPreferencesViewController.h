//
//  AboutPreferencesViewController.h
//  SymSteam
//
//  Created by Alex Jackson on 08/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MASPreferencesViewController.h"

@interface AboutPreferencesViewController : NSViewController <MASPreferencesViewController>

@property (unsafe_unretained) IBOutlet NSTextView *aboutDescription;

-(IBAction)quitApplication:(id)sender;

@end
