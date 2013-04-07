//
//  SCSymSteamConstants.h
//  SymSteam
//
//  Created by Alex Jackson on 05/04/2013.
//
//

#import <Foundation/Foundation.h>

#pragma mark - User Defaults Keys

extern NSString *const SCSetupCompleteKey;
extern NSString *const SCNotificationsEnabledKey;
extern NSString *const SCSteamAppsSymbolicLinkLocationKey;
extern NSString *const SCSteamAppsSymbolicLinkDestinationKey;
extern NSString *const SCSteamAppsLocalLocationKey;
extern NSString *const SCSteamDriveUUIDKey;

#pragma mark - Error Codes

extern NSString *const SCSymSteamErrorDomain;

// Startup Errors

extern NSInteger const SCSteamAppsFolderMissingError;
extern NSInteger const SCLocalSteamAppsFolderMissingError;
extern NSInteger const SCSymbolicLinkMissingError;
extern NSInteger const SCTooManyFoldersError;

// Drive Connection Errors

extern NSInteger const SCFailedToMakeSymbolicLinkPrimaryError;
extern NSInteger const SCFailedToMakeLocalSteamAppsPrimaryError;
