//
//  AppController.m
//  SymSteam
//
//  Created by Alex Jackson on 02/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppController.h"

@implementation AppController
@synthesize saController = _saController;

-(id)init{
    self = [super init];
    if(self){
        _saController = [[SteamAppsController alloc] init];
    }
    return self;
}

-(void)startWatchingDrives{
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
    NSNotificationCenter *center = [workspace notificationCenter];
    [center addObserver:self.saController selector:@selector(didMountDrive:) name:NSWorkspaceDidMountNotification object:nil];
    [center addObserver:self.saController selector:@selector(didUnMountDrive:) name:NSWorkspaceDidUnmountNotification object:nil];
}

@end
