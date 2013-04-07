//
//  SCSymSteamConstants.m
//  SymSteam
//
//  Created by Alex Jackson on 05/04/2013.
//
//

#import "SCSymSteamConstants.h"

#pragma mark - User Defaults Keys

NSString *const SCSetupCompleteKey = @"setupComplete";
NSString *const SCNotificationsEnabledKey = @"growlNotificationsEnabled";
NSString *const SCSteamAppsSymbolicLinkLocationKey = @"steamAppsSymbolicLinkPath";
NSString *const SCSteamAppsSymbolicLinkDestinationKey = @"symbolicPathDestination";
NSString *const SCSteamAppsLocalLocationKey = @"steamAppsLocalPath";
NSString *const SCSteamDriveUUIDKey = @"steamDriveUUID";

#pragma mark - Error Codes

NSString *const SCSymSteamErrorDomain = @"com.simplecode.symsteam";

// Startup Errors

NSInteger const SCSteamAppsFolderMissingError = 2000;
NSInteger const SCLocalSteamAppsFolderMissingError = 2001;
NSInteger const SCSymbolicLinkMissingError = 2002;
NSInteger const SCTooManyFoldersError = 2003;

// Drive Connection Errors

NSInteger const SCFailedToMakeSymbolicLinkPrimaryError = 3000;
NSInteger const SCFailedToMakeLocalSteamAppsPrimaryError = 3001;
