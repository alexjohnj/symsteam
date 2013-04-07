//
//  SCSteamAppsFoldersController.m
//  SymSteam
//
//  Created by Alex Jackson on 27/08/2012.
//
//

#import "SCSteamAppsFoldersController.h"

@implementation SCSteamAppsFoldersController

#pragma mark -

- (BOOL)externalSteamAppsFolderExists {
    return [[NSFileManager defaultManager] fileExistsAtPath:[[NSUserDefaults standardUserDefaults] stringForKey:SCSteamAppsSymbolicLinkDestinationKey]];
}

#pragma mark - Folder Updating Methods

- (BOOL)makeSymbolicSteamAppsPrimaryWithSuccessNotifications:(BOOL)showSuccessNotifications {
    NSString *applicationSupportPath = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES)[0];
    NSString *localSteamAppsPath = [[applicationSupportPath stringByAppendingPathComponent:@"Steam"] stringByAppendingPathComponent:@"SteamApps"];
    NSString *symbolicSteamAppsPath = [[applicationSupportPath stringByAppendingPathComponent:@"Steam"] stringByAppendingPathComponent:@"SteamAppsSymb"];
    NSString *newLocalSteamAppsPath = [[applicationSupportPath stringByAppendingPathComponent:@"Steam"] stringByAppendingPathComponent:@"SteamAppsLoc"];
    NSFileManager *fManager = [[NSFileManager alloc] init];
    BOOL success = YES;
    
    // rename the local SteamApps Folder to SteamAppsLoc:
    __autoreleasing NSError *localSteamAppsFolderRenameError;
    success = [fManager moveItemAtPath:localSteamAppsPath toPath:newLocalSteamAppsPath error:&localSteamAppsFolderRenameError];
    
    if (!success) {
        NSDictionary *errorUserInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"SCError3000Description", nil),
                                        NSLocalizedFailureReasonErrorKey: localSteamAppsFolderRenameError.localizedDescription,
                                        };
        NSError *folderChangeFailureError = [[NSError alloc] initWithDomain:SCSymSteamErrorDomain code:SCFailedToMakeSymbolicLinkPrimaryError userInfo:errorUserInfo];
        
        DDLogError(@"%@", folderChangeFailureError);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:SCNotificationsEnabledKey]) {
            [[SCNotificationCenter sharedCenter] notifyWithError:folderChangeFailureError];
        }
        return NO;
    }
    
    // rename SteamAppsSymb (the symbolic link) to SteamApps
    __autoreleasing NSError *symbolicSteamAppsFolderRenameError;
    success = [fManager moveItemAtPath:symbolicSteamAppsPath toPath:localSteamAppsPath error:&symbolicSteamAppsFolderRenameError];
    
    if (!success) {
        NSDictionary *errorUserInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"SCError3000Description", nil),
                                        NSLocalizedFailureReasonErrorKey: symbolicSteamAppsFolderRenameError.localizedDescription,
                                        };
        NSError *folderChangeFailureError = [[NSError alloc] initWithDomain:SCSymSteamErrorDomain code:SCFailedToMakeSymbolicLinkPrimaryError userInfo:errorUserInfo];
        
        DDLogError(@"%@", folderChangeFailureError);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:SCNotificationsEnabledKey]) {
            [[SCNotificationCenter sharedCenter] notifyWithError:folderChangeFailureError];
        }
        return NO;
    }
    
    // If we get to this point, everything went A-OK, so we can notify the user that the folders have changed and set steamDriveIsConnected to YES.
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:SCNotificationsEnabledKey] && showSuccessNotifications) {
        [SCNotificationCenter notifyWithDictionary:(@{
                                                    SCNotificationCenterNotificationTitle : NSLocalizedString(@"updatedSteamFoldersNotificationTitle", nil),
                                                    SCNotificationCenterNotificationDescription : NSLocalizedString(@"updatedSteamFoldersNotificationDescriptionExternal", nil),
                                                    SCNotificationCenterNotificationName : NSLocalizedString(@"updatedSteamFoldersNotificationGrowlTitle", nil)
                                                    })];
    }
    [[SCSteamDiskManager steamDiskManager] setSteamDriveIsConnected:YES];
    return YES;
}

- (BOOL)makeLocalSteamAppsPrimaryWithSuccessNotifications:(BOOL)showSuccessNotifications {
    [[SCSteamDiskManager steamDiskManager] setSteamDriveIsConnected:NO]; // Update this here since the Steam drive will have been disconnected regardless of if this method completes successfully.
    
    NSString *applicationSupportPath = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES)[0];
    NSString *localSteamAppsPath = [[applicationSupportPath stringByAppendingPathComponent:@"Steam"] stringByAppendingPathComponent:@"SteamApps"];
    NSString *symbolicSteamAppsPath = [[applicationSupportPath stringByAppendingPathComponent:@"Steam"] stringByAppendingPathComponent:@"SteamAppsSymb"];
    
    NSFileManager *fManager = [[NSFileManager alloc] init];
    BOOL success = YES;
    
    // Attempt to rename SteamApps to SteamAppsSymb
    __autoreleasing NSError *renameSymbolicError;
    success = [fManager moveItemAtPath:localSteamAppsPath toPath:symbolicSteamAppsPath error:&renameSymbolicError];
    
    if (!success) {
        NSDictionary *errorUserInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"SCError3001Description", nil),
                                        NSLocalizedFailureReasonErrorKey: renameSymbolicError.localizedDescription,
                                        };
        NSError *folderChangeError = [[NSError alloc] initWithDomain:SCSymSteamErrorDomain code:SCFailedToMakeLocalSteamAppsPrimaryError userInfo:errorUserInfo];
        
        DDLogError(@"%@", folderChangeError);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:SCNotificationsEnabledKey]) {
            [[SCNotificationCenter sharedCenter] notifyWithError:folderChangeError];
        }
        return NO;
    }
    
    // Attempt to rename SteamAppsLoc to SteamApps
    __autoreleasing NSError *renameLocalError;
    NSString *currentLocalSteamAppsFolderPath = [[localSteamAppsPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"SteamAppsLoc"];
    success = [fManager moveItemAtPath:currentLocalSteamAppsFolderPath toPath:localSteamAppsPath error:&renameLocalError];
    
    if (!success) {
        NSDictionary *errorUserInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"SCError3001Description", nil),
                                        NSLocalizedFailureReasonErrorKey: renameLocalError.localizedDescription,
                                        };
        NSError *folderChangeError = [[NSError alloc] initWithDomain:SCSymSteamErrorDomain code:SCFailedToMakeLocalSteamAppsPrimaryError userInfo:errorUserInfo];
        
        DDLogError(@"%@", folderChangeError);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:SCNotificationsEnabledKey]) {
            [[SCNotificationCenter sharedCenter] notifyWithError:folderChangeError];
        }
        return NO;
    }
    
    // If we make it to this point then everything will have been succesful and we can notify the user (assuming they want us to).
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:SCNotificationsEnabledKey] && showSuccessNotifications) {
        [SCNotificationCenter notifyWithDictionary:(@{
                                                    SCNotificationCenterNotificationTitle: NSLocalizedString(@"updatedSteamFoldersNotificationTitle", nil),
                                                    SCNotificationCenterNotificationDescription: NSLocalizedString(@"updatedSteamFoldersNotificationDescriptionInternal", nil),
                                                    SCNotificationCenterNotificationName: NSLocalizedString(@"updatedSteamFoldersNotificationGrowlTitle", nil)
                                                    })];
    }
    
    return YES;
}

- (BOOL)makeSymbolicSteamAppsPrimary {
    return [self makeSymbolicSteamAppsPrimaryWithSuccessNotifications:YES];
}

- (BOOL)makeLocalSteamAppsPrimary {
    return [self makeLocalSteamAppsPrimaryWithSuccessNotifications:YES];
}

#pragma mark - Folder Error Checking

/* WARNING!! MEGA METHOD BELOW */
/* TODO: Break mega method into smaller methods */

- (void)performInitialDriveScan {
    NSString *applicationSupportDirectory = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES)[0];
    NSString *symbolicSteamAppsFolderPath = [[applicationSupportDirectory stringByAppendingPathComponent:@"Steam"] stringByAppendingPathComponent:@"SteamAppsSymb"];
    NSString *localSteamAppsFolderPath = [[applicationSupportDirectory stringByAppendingPathComponent:@"Steam"] stringByAppendingPathComponent:@"SteamApps"];
    NSString *steamAppsLocPath = [[applicationSupportDirectory stringByAppendingPathComponent:@"Steam"] stringByAppendingPathComponent:@"SteamAppsLoc"];
    
    NSFileManager *fManager = [[NSFileManager alloc] init];
    
    BOOL symbolicSteamAppsFolderExists = NO;
    BOOL localSteamAppsFolderExists = [fManager fileExistsAtPath:localSteamAppsFolderPath];
    BOOL steamAppsLocFolderExists = [fManager fileExistsAtPath:steamAppsLocPath];
    
    NSDictionary *symbolicSteamAppsFolderAttributes = [fManager attributesOfItemAtPath:symbolicSteamAppsFolderPath error:nil];
    if (!symbolicSteamAppsFolderAttributes) {
        symbolicSteamAppsFolderExists = NO; //we check the link exists using the attributes instead of fileExistsAtPath: since the afformentioned method will try to follow the symbolic link and return NO if the link isn't reachable, even if the actual symbolic link exists.
    } else {
        symbolicSteamAppsFolderExists = YES;
    }
    
    if (localSteamAppsFolderExists && !steamAppsLocFolderExists && symbolicSteamAppsFolderExists) {
        DDLogVerbose(@"SteamApps exists & SteamAppsSymb exists, suggesting everything is A-OK.");
        if([self externalSteamAppsFolderExists] && ![[SCSteamDiskManager steamDiskManager] steamDriveIsConnected]) //check the external SteamApps folder exists and a Steam Drive isn't registered as connected.
            [self makeSymbolicSteamAppsPrimary];
        return;
    }
    
    if (!localSteamAppsFolderExists && steamAppsLocFolderExists && symbolicSteamAppsFolderExists) {
        __autoreleasing NSError *renameSteamAppsLocError;
        BOOL success = [fManager moveItemAtPath:steamAppsLocPath toPath:localSteamAppsFolderPath error:&renameSteamAppsLocError];
        if(!success){
            NSDictionary *errorNotificationUserInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"SCError2000Description", nil),
                                                        NSLocalizedFailureReasonErrorKey: renameSteamAppsLocError.localizedDescription,
                                                        };
            NSError *launchError = [[NSError alloc] initWithDomain:SCSymSteamErrorDomain code:SCSteamAppsFolderMissingError userInfo:errorNotificationUserInfo];
            
            DDLogError(@"%@", launchError);
            if ([[NSUserDefaults standardUserDefaults] boolForKey:SCNotificationsEnabledKey]) {
                [[SCNotificationCenter sharedCenter] notifyWithError:launchError];
            }
        } else { // if SymSteam was able to fix this configuration issue, check to see if a drive is connected and if it is, update the Steam Folders.
            if ([self externalSteamAppsFolderExists] && ![[SCSteamDiskManager steamDiskManager] steamDriveIsConnected])
                [self makeSymbolicSteamAppsPrimary];
        }
        return;
    }
    
    else if (!localSteamAppsFolderExists && !steamAppsLocFolderExists && symbolicSteamAppsFolderExists) {
        NSDictionary *errorUserInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"SCError2001Description", nil),
                                        NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"SCError2001FailureReason", nil),
                                        NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"SCError2001RecoverySuggestion", nil)
                                        };
        NSError *missingLocalSteamAppsError = [[NSError alloc] initWithDomain:SCSymSteamErrorDomain code:SCLocalSteamAppsFolderMissingError userInfo:errorUserInfo];
        
        DDLogError(@"%@", missingLocalSteamAppsError);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:SCNotificationsEnabledKey]) {
            [[SCNotificationCenter sharedCenter] notifyWithError:missingLocalSteamAppsError];
        }
        return;
    }
    
    else if (localSteamAppsFolderExists && !steamAppsLocFolderExists && !symbolicSteamAppsFolderExists) {
        NSDictionary *errorUserInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"SCError2002Description", nil),
                                        NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"SCError2002FailureReason", nil),
                                        NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"SCError2002RecoverySuggestion", nil)
                                        };
        NSError *missingSymbolicLinkError = [[NSError alloc] initWithDomain:SCSymSteamErrorDomain code:SCSymbolicLinkMissingError userInfo:errorUserInfo];
        
        DDLogError(@"%@", missingSymbolicLinkError);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:SCNotificationsEnabledKey]) {
            [[SCNotificationCenter sharedCenter] notifyWithError:missingSymbolicLinkError];
        }
        return;
    }
    
    else if (localSteamAppsFolderExists && steamAppsLocFolderExists && symbolicSteamAppsFolderExists) {
        NSDictionary *errorUserInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"SCError2003Description", nil),
                                        NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"SCError2003FailureReason", nil),
                                        NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"SCError2003RecoverySuggestion", nil)
                                        };
        NSError *tooManyFoldersError = [[NSError alloc] initWithDomain:SCSymSteamErrorDomain code:SCTooManyFoldersError userInfo:errorUserInfo];
        
        DDLogError(@"%@", tooManyFoldersError);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:SCNotificationsEnabledKey]) {
            [[SCNotificationCenter sharedCenter] notifyWithError:tooManyFoldersError];
        }
        return;
    }
    
    else if (localSteamAppsFolderPath && steamAppsLocFolderExists && !symbolicSteamAppsFolderExists) {
        NSDictionary *steamAppsFolderAttributes = [fManager attributesOfItemAtPath:localSteamAppsFolderPath error:nil];
        if ([[steamAppsFolderAttributes fileType] isEqualToString:NSFileTypeSymbolicLink] && [self externalSteamAppsFolderExists] && ![[SCSteamDiskManager steamDiskManager] steamDriveIsConnected]) {
            [[SCSteamDiskManager steamDiskManager] setSteamDriveIsConnected:YES];
            if ([[NSUserDefaults standardUserDefaults] boolForKey:SCNotificationsEnabledKey]) {
                [SCNotificationCenter notifyWithDictionary:@{
                                                            SCNotificationCenterNotificationTitle : NSLocalizedString(@"updatedSteamFoldersNotificationTitle", nil),
                                                            SCNotificationCenterNotificationDescription : NSLocalizedString(@"updatedSteamFoldersNotificationDescriptionExternal", nil),
                                                            SCNotificationCenterNotificationName : NSLocalizedString(@"updatedSteamFoldersNotificationGrowlTitle", nil)
                                                            }];
            }
        }
        else if ([[steamAppsFolderAttributes fileType] isEqualToString:NSFileTypeSymbolicLink] && ![self externalSteamAppsFolderExists] && ![[SCSteamDiskManager steamDiskManager] steamDriveIsConnected]) {
            [self makeLocalSteamAppsPrimaryWithSuccessNotifications:NO];
        } else {
            NSDictionary *errorUserInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"SCError2002Description", nil),
                                            NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"SCError2002FailureReason", nil),
                                            NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"SCError2002RecoverySuggestion", nil)
                                            };
            NSError *missingSymbolicLinkError = [NSError errorWithDomain:SCSymSteamErrorDomain code:SCSymbolicLinkMissingError userInfo:errorUserInfo];
            
            DDLogError(@"%@", missingSymbolicLinkError);
            if ([[NSUserDefaults standardUserDefaults] boolForKey:SCNotificationsEnabledKey]) {
                [[SCNotificationCenter sharedCenter] notifyWithError:missingSymbolicLinkError];
            }
        }
        return;
    }
}

@end
