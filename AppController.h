//
//  AppController.h
//  SymSteam
//
//  Created by Alex Jackson on 02/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Growl/Growl.h>

@interface AppController : NSObject

@property (assign) BOOL steamDriveIsConnected;
@property (strong) NSMutableDictionary *connectedDrives;

-(void)startWatchingDrives;
-(void)didMount:(NSNotification *)aNotification;
-(void)didUnmount:(NSNotification *)aNotification;
-(void)registerDrive:(NSString *)drive asSteamDrive:(BOOL)sDrive;
-(void)deRegisterDrive:(NSString *)drive;
-(BOOL)scanForSteamAppsFolderOnDrive:(NSURL *)drive;

@end
