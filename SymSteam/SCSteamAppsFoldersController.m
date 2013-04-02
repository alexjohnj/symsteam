//
//  SCSteamAppsFoldersController.m
//  SymSteam
//
//  Created by Alex Jackson on 27/08/2012.
//
//

#import "SCSteamAppsFoldersController.h"

static NSString * const steamDriveUUIDKey = @"steamDriveUUID";
static NSString * const growlNotificationsEnabledKey = @"growlNotificationsEnabled";
static NSString * const symbolicPathDestinationKey = @"symbolicPathDestination";

@implementation SCSteamAppsFoldersController

#pragma mark -

- (BOOL)externalSteamAppsFolderExists{
    return [[NSFileManager defaultManager] fileExistsAtPath:[[NSUserDefaults standardUserDefaults] stringForKey:symbolicPathDestinationKey]];
}

#pragma mark - Folder Updating Methods

- (BOOL)makeSymbolicSteamAppsPrimaryWithSuccessNotifications:(BOOL)showSuccessNotifications{
    NSString *applicationSupportPath = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES)[0];
    NSString *localSteamAppsPath = [[applicationSupportPath stringByAppendingPathComponent:@"Steam"] stringByAppendingPathComponent:@"SteamApps"];
    NSString *symbolicSteamAppsPath = [[applicationSupportPath stringByAppendingPathComponent:@"Steam"] stringByAppendingPathComponent:@"SteamAppsSymb"];
    NSString *newLocalSteamAppsPath = [[applicationSupportPath stringByAppendingPathComponent:@"Steam"] stringByAppendingPathComponent:@"SteamAppsLoc"];
    NSFileManager *fManager = [[NSFileManager alloc] init];
    BOOL success = YES;
    
    // rename the local SteamApps Folder to SteamAppsLoc:
    NSError *localSteamAppsFolderRename;
    success = [fManager moveItemAtPath:localSteamAppsPath toPath:newLocalSteamAppsPath error:&localSteamAppsFolderRename];
    
    if(!success){
        DDLogError(@"I was trying to rename the local SteamApps folder to SteamAppsLoc but couldn't rename [%@] to [%@] because: [%@]", localSteamAppsPath, newLocalSteamAppsPath, [localSteamAppsFolderRename localizedDescription]);
        if([[NSUserDefaults standardUserDefaults] boolForKey:growlNotificationsEnabledKey]){
            [SCNotificationCenter notifyWithDictionary:(@{
                                                        SCNotificationCenterNotificationTitle: NSLocalizedString(@"failedUpdatedSteamFoldersNotificationTitle", nil),
                                                        SCNotificationCenterNotificationDescription: NSLocalizedString(@"failedUpdatedSteamFoldersNotificationDescription", nil),
                                                        SCNotificationCenterNotificationName: NSLocalizedString(@"errorOccuredGrowlTitle", nil)})];
        }
        return NO;
    }
    
    // rename SteamAppsSymb (the symbolic link) to SteamApps
    NSError *symbolicSteamAppsFolderRename;
    success = [fManager moveItemAtPath:symbolicSteamAppsPath toPath:localSteamAppsPath error:&symbolicSteamAppsFolderRename];
    
    if(!success){
        DDLogError(@"I was trying to rename SteamAppsSymb to SteamApps but couldn't rename item [%@] to [%@] because [%@]", symbolicSteamAppsPath, localSteamAppsPath, [symbolicSteamAppsFolderRename localizedDescription]);
        if([[NSUserDefaults standardUserDefaults] boolForKey:growlNotificationsEnabledKey]){
            [SCNotificationCenter notifyWithDictionary:(@{
                                                        SCNotificationCenterNotificationTitle: NSLocalizedString(@"failedUpdatedSteamFoldersNotificationTitle", nil),
                                                        SCNotificationCenterNotificationDescription: NSLocalizedString(@"failedUpdatedSteamFoldersNotificationDescription", nil),
                                                        SCNotificationCenterNotificationName: NSLocalizedString(@"errorOccuredGrowlTitle", nil)})];
        }
        return NO;
    }
    
    // If we get to this point, everything went A-OK, so we can notify the user that the folders have changed and set steamDriveIsConnected to YES.
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:growlNotificationsEnabledKey] && showSuccessNotifications)
        [SCNotificationCenter notifyWithDictionary:(@{
                                                    SCNotificationCenterNotificationTitle : NSLocalizedString(@"updatedSteamFoldersNotificationTitle", nil),
                                                    SCNotificationCenterNotificationDescription : NSLocalizedString(@"updatedSteamFoldersNotificationDescriptionExternal", nil),
                                                    SCNotificationCenterNotificationName : NSLocalizedString(@"updatedSteamFoldersNotificationGrowlTitle", nil)})];
    [[SCSteamDiskManager steamDiskManager] setSteamDriveIsConnected:YES];
    return YES;
}

- (BOOL)makeLocalSteamAppsPrimaryWithSuccessNotifications:(BOOL)showSuccessNotifications{
    [[SCSteamDiskManager steamDiskManager] setSteamDriveIsConnected:NO]; // Update this here since the Steam drive will have been disconnected regardless of if this method completes successfully.
    
    NSString *applicationSupportPath = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES)[0];
    NSString *localSteamAppsPath = [[applicationSupportPath stringByAppendingPathComponent:@"Steam"] stringByAppendingPathComponent:@"SteamApps"];
    NSString *symbolicSteamAppsPath = [[applicationSupportPath stringByAppendingPathComponent:@"Steam"] stringByAppendingPathComponent:@"SteamAppsSymb"];
    
    NSFileManager *fManager = [[NSFileManager alloc] init];
    BOOL success = YES;
    
    // Attempt to rename SteamApps to SteamAppsSymb
    NSError *renameSymbolicError;
    success = [fManager moveItemAtPath:localSteamAppsPath toPath:symbolicSteamAppsPath error:&renameSymbolicError];
    if(!success){
        DDLogError(@"I was trying to rename SteamApps to SteamAppsSymb but couldn't rename [%@] to [%@] because [%@]", localSteamAppsPath, symbolicSteamAppsPath, [renameSymbolicError localizedDescription]);
        
        if([[NSUserDefaults standardUserDefaults] boolForKey:growlNotificationsEnabledKey]){
            [SCNotificationCenter notifyWithDictionary:(@{
                                                        SCNotificationCenterNotificationTitle: NSLocalizedString(@"failedUpdatedSteamFoldersNotificationTitle", nil),
                                                        SCNotificationCenterNotificationDescription: NSLocalizedString(@"failedUpdatedSteamFoldersNotificationDescription", nil),
                                                        SCNotificationCenterNotificationName: NSLocalizedString(@"errorOccuredGrowlTitle", nil)})];
        }
        return NO;
    }
    
    // Attempt to rename SteamAppsLoc to SteamApps
    NSError *renameLocalError;
    NSString *currentLocalSteamAppsFolderPath = [[localSteamAppsPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"SteamAppsLoc"];
    
    success = [fManager moveItemAtPath:currentLocalSteamAppsFolderPath toPath:localSteamAppsPath error:&renameLocalError];
    if(!success){
        DDLogError(@"I was trying to rename SteamAppsLoc to SteamApps but couldn't rename [%@] to [%@] because [%@]", currentLocalSteamAppsFolderPath,localSteamAppsPath, [renameLocalError localizedDescription]);
        if([[NSUserDefaults standardUserDefaults] boolForKey:growlNotificationsEnabledKey]){
            [SCNotificationCenter notifyWithDictionary:(@{
                                                        SCNotificationCenterNotificationTitle: NSLocalizedString(@"failedUpdatedSteamFoldersNotificationTitle", nil),
                                                        SCNotificationCenterNotificationDescription: NSLocalizedString(@"failedUpdatedSteamFoldersNotificationDescription", nil),
                                                        SCNotificationCenterNotificationName: NSLocalizedString(@"errorOccuredGrowlTitle", nil)})];
        }
        return NO;
    }
    
    // If we make it to this point then everything will have been succesful and we can notify the user (assuming they want us to).
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:growlNotificationsEnabledKey] && showSuccessNotifications)
        [SCNotificationCenter notifyWithDictionary:(@{
                                                    SCNotificationCenterNotificationTitle: NSLocalizedString(@"updatedSteamFoldersNotificationTitle", nil),
                                                    SCNotificationCenterNotificationDescription: NSLocalizedString(@"updatedSteamFoldersNotificationDescriptionInternal", nil),
                                                    SCNotificationCenterNotificationName: NSLocalizedString(@"updatedSteamFoldersNotificationGrowlTitle", nil)})];
    
    return YES;
}

- (BOOL)makeSymbolicSteamAppsPrimary{
    return [self makeSymbolicSteamAppsPrimaryWithSuccessNotifications:YES];
}

- (BOOL)makeLocalSteamAppsPrimary{
    return [self makeLocalSteamAppsPrimaryWithSuccessNotifications:YES];
}

#pragma mark - Folder Error Checking

/* WARNING!! MEGA METHOD BELOW */
/* TODO: Break mega method into smaller methods */

- (void)performInitialDriveScan{
    NSString *applicationSupportDirectory = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES)[0];
    NSString *symbolicSteamAppsFolderPath = [[applicationSupportDirectory stringByAppendingPathComponent:@"Steam"] stringByAppendingPathComponent:@"SteamAppsSymb"];
    NSString *localSteamAppsFolderPath = [[applicationSupportDirectory stringByAppendingPathComponent:@"Steam"] stringByAppendingPathComponent:@"SteamApps"];
    NSString *steamAppsLocPath = [[applicationSupportDirectory stringByAppendingPathComponent:@"Steam"] stringByAppendingPathComponent:@"SteamAppsLoc"];
    
    NSFileManager *fManager = [[NSFileManager alloc] init];
    
    BOOL symbolicSteamAppsFolderExists = NO;
    BOOL localSteamAppsFolderExists = [fManager fileExistsAtPath:localSteamAppsFolderPath];
    BOOL steamAppsLocFolderExists = [fManager fileExistsAtPath:steamAppsLocPath];
    
    NSDictionary *symbolicSteamAppsFolderAttributes = [fManager attributesOfItemAtPath:symbolicSteamAppsFolderPath error:nil];
    if(!symbolicSteamAppsFolderAttributes)
        symbolicSteamAppsFolderExists = NO; //we check the link exists using the attributes instead of fileExistsAtPath: since the afformentioned method will try to follow the symbolic link and return NO if the link isn't reachable, even if the actual symbolic link exists.
    else
        symbolicSteamAppsFolderExists = YES;
    
    if(localSteamAppsFolderExists && !steamAppsLocFolderExists && symbolicSteamAppsFolderExists){
        DDLogVerbose(@"SteamApps exists & SteamAppsSymb exists, suggesting everything is A-OK.");
        if([self externalSteamAppsFolderExists] && ![[SCSteamDiskManager steamDiskManager] steamDriveIsConnected]) //check the external SteamApps folder exists and a Steam Drive isn't registered as connected.
            [self makeSymbolicSteamAppsPrimary];
        return;
    }
    
    if(!localSteamAppsFolderExists && steamAppsLocFolderExists && symbolicSteamAppsFolderExists){
        NSError *renameSteamAppsLocToSteamApps;
        BOOL success = [fManager moveItemAtPath:steamAppsLocPath toPath:localSteamAppsFolderPath error:&renameSteamAppsLocToSteamApps];
        if(!success){
            DDLogError(@"I was trying to fix the SteamApps setup by renaming SteamAppsLoc to SteamApps while keeping SteamAppsSymb the same but couldn't move [%@] to [%@] because: [%@]", steamAppsLocPath, localSteamAppsFolderPath, [renameSteamAppsLocToSteamApps localizedDescription]);
            [self displayGenericErrorNotification];
        }
        else{ // if SymSteam was able to fix this configuration issue, check to see if a drive is connected and if it is, update the Steam Folders.
            if([self externalSteamAppsFolderExists] && ![[SCSteamDiskManager steamDiskManager] steamDriveIsConnected])
                [self makeSymbolicSteamAppsPrimary];
        }
        return;
    }
    
    else if(!localSteamAppsFolderExists && !steamAppsLocFolderExists && symbolicSteamAppsFolderExists){
        DDLogError(@"A symbolic link exists but neither a SteamApps folder nor a SteamAppsLoc folder exists! I can't do anything about this.");
        [self displayGenericErrorNotification];
        return;
    }
    
    else if(localSteamAppsFolderExists && !steamAppsLocFolderExists && !symbolicSteamAppsFolderExists){
        DDLogError(@"A SteamApps folder exists but there's no SteamAppsLoc or SteamAppsSymb folder. Setup probably needs to be carried out again.");
        [self displayGenericErrorNotification];
        return;
    }
    
    else if(localSteamAppsFolderExists && steamAppsLocFolderExists && symbolicSteamAppsFolderExists){
        DDLogError(@"A SteamApps, SteamAppsLoc & SteamAppsSymb folder exists. I can't take this! That's too many folders. I can't do anything with this setup. Get rid of either the SteamApps or SteamAppsLoc folder.");
        [self displayGenericErrorNotification];
        return;
    }
    
    else if(localSteamAppsFolderPath && steamAppsLocFolderExists && !symbolicSteamAppsFolderExists){
        NSDictionary *steamAppsFolderAttributes = [fManager attributesOfItemAtPath:localSteamAppsFolderPath error:nil];
        if([[steamAppsFolderAttributes fileType] isEqualToString:NSFileTypeSymbolicLink] && [self externalSteamAppsFolderExists] && ![[SCSteamDiskManager steamDiskManager] steamDriveIsConnected]){
            [[SCSteamDiskManager steamDiskManager] setSteamDriveIsConnected:YES];
            if([[NSUserDefaults standardUserDefaults] boolForKey:growlNotificationsEnabledKey])
                [SCNotificationCenter notifyWithDictionary:(@{
                                                            SCNotificationCenterNotificationTitle : NSLocalizedString(@"updatedSteamFoldersNotificationTitle", nil),
                                                            SCNotificationCenterNotificationDescription : NSLocalizedString(@"updatedSteamFoldersNotificationDescriptionExternal", nil),
                                                            SCNotificationCenterNotificationName : NSLocalizedString(@"updatedSteamFoldersNotificationGrowlTitle", nil)})];
        }
        
        else if([[steamAppsFolderAttributes fileType] isEqualToString:NSFileTypeSymbolicLink] && ![self externalSteamAppsFolderExists] && ![[SCSteamDiskManager steamDiskManager] steamDriveIsConnected])
            [self makeLocalSteamAppsPrimaryWithSuccessNotifications:NO];
        
        else{
            DDLogError(@"A SteamApps & SteamAppsLoc folder exists but a SteamAppsSymb folder doesn't. I checked to see if the SteamApps folder is a symbolic link and it wasn't, so SteamAppsSymb has gone missing and needs to be recreated and setup needs to be run again.");
            [self displayGenericErrorNotification];
        }
        return;
    }
}

- (void)displayGenericErrorNotification{
    if([[NSUserDefaults standardUserDefaults] boolForKey:growlNotificationsEnabledKey])
        [SCNotificationCenter notifyWithDictionary:(@{
                                                    SCNotificationCenterNotificationTitle: NSLocalizedString(@"failedUpdatedSteamFoldersNotificationTitle", nil),
                                                    SCNotificationCenterNotificationDescription: NSLocalizedString(@"failedUpdatedSteamFoldersNotificationDescription", nil),
                                                    SCNotificationCenterNotificationName: NSLocalizedString(@"errorOccuredGrowlTitle", nil)})];
}

@end
