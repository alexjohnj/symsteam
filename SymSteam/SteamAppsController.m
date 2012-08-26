//
//  SteamAppsController.m
//  SymSteam
//
//  Created by Alex Jackson on 05/04/2012.


#import "SteamAppsController.h"

static NSString * const steamDriveUUIDKey = @"steamDriveUUID";
static NSString * const growlNotificationsEnabledKey = @"growlNotificationsEnabled";
static NSString * const symbolicPathDestinationKey = @"symbolicPathDestination";
static NSString * const setupComplete = @"setupComplete";

DADissenterRef diskWillMount(DADiskRef disk, void *context){
    if(context == NULL){
        NSLog(@"A drive wanted to mount but the context was NULL, it can't be.");
        return NULL;
    } if(disk == NULL){
        NSLog(@"A drive wanted to mount and the providied drive was NULL for some reason.");
        return NULL;
    }
    
    SteamAppsController *controller = (__bridge SteamAppsController *)context;
    if(controller.steamDriveIsConnected)
        return NULL;
    if([controller suspectDriveIsSteamDrive:disk])
        [controller makeSymbolicSteamAppsPrimary];
    return NULL;
}

DADissenterRef diskWillUnmount(DADiskRef disk, void *context){
    if(context == NULL){
        NSLog(@"The context was NULL, it can't be.");
        return NULL;
    } if(disk == NULL){
        NSLog(@"The disk provided was NULL");
        return NULL;
    }
    
    SteamAppsController *controller = (__bridge SteamAppsController *)context;
    if(!controller.steamDriveIsConnected)
        return NULL;
    if([controller suspectDriveIsSteamDrive:disk])
        [controller makeLocalSteamAppsPrimary];
    return NULL;
}

void diskDidDisappear(DADiskRef disk, void *context){
    if(context == NULL){
        NSLog(@"The context was NULL, it can't be.");
        return;
    } if(disk == NULL){
        NSLog(@"The provided DADiskref was NULL");
        return;
    }
    SteamAppsController *controller = (__bridge SteamAppsController *)context;
    if(controller.steamDriveIsConnected && [controller suspectDriveIsSteamDrive:disk])
        [controller makeLocalSteamAppsPrimary];
}

void registerForDADiskCallbacks(void *context){
    dispatch_queue_t daQueue = dispatch_queue_create("com.simplecode", NULL);
    DASessionRef session = DASessionCreate(kCFAllocatorDefault);
    DAApprovalSessionRef approvalSession = DAApprovalSessionCreate(kCFAllocatorDefault);
    
    DARegisterDiskMountApprovalCallback(approvalSession, NULL, diskWillMount, context);
    DARegisterDiskDisappearedCallback(session, NULL, diskDidDisappear, context);
    DARegisterDiskUnmountApprovalCallback(approvalSession, NULL, diskWillUnmount, context);
    DASessionSetDispatchQueue(session, daQueue);
    DAApprovalSessionScheduleWithRunLoop(approvalSession, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    
    if(session != NULL)
        CFRelease(session);
    if(approvalSession != NULL)
        CFRelease(approvalSession);
    if(daQueue != NULL)
        dispatch_release(daQueue);
}

@implementation SteamAppsController

- (id)init{
    self = [super init];
    if(self){
        _steamDriveIsConnected = NO;
    }
    return self;
}

- (void)startWatchingForDrives{
    registerForDADiskCallbacks((__bridge void*)self);
}

- (BOOL)suspectDriveIsSteamDrive:(DADiskRef)suspectDrive{
    if(suspectDrive == NULL)
        return NO;
    CFDictionaryRef driveDetails = DADiskCopyDescription(suspectDrive);
    if(driveDetails == NULL){
        NSLog(@"The drive details provided from the suspect drive where NULL");
        return NO;
    } if(CFDictionaryGetValue(driveDetails, kDADiskDescriptionVolumeUUIDKey) == NULL){
        CFRelease(driveDetails);
        return NO; // No need to log anything here, some drives won't have a UUID.
    }
    
    CFUUIDRef cfUUID = CFRetain(CFDictionaryGetValue(driveDetails, kDADiskDescriptionVolumeUUIDKey));
    CFRelease(driveDetails);
    CFStringRef cfSuspectDriveUUID = CFUUIDCreateString(kCFAllocatorDefault, cfUUID);
    CFRelease(cfUUID);
    NSString *suspectDriveUUID = (__bridge_transfer NSString *)cfSuspectDriveUUID;
    NSString *steamDriveUUID = [[NSUserDefaults standardUserDefaults] stringForKey:steamDriveUUIDKey];
    if([steamDriveUUID isEqualToString:suspectDriveUUID])
        return YES;
    else
        return NO;
}

- (BOOL)externalSteamAppsFolderExists{
    return [[NSFileManager defaultManager] fileExistsAtPath:[[NSUserDefaults standardUserDefaults] stringForKey:symbolicPathDestinationKey]];
}

- (BOOL)makeSymbolicSteamAppsPrimary{
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
        NSLog(@"I was trying to rename the local SteamApps folder to SteamAppsLoc but couldn't rename [%@] to [%@] because: [%@]", localSteamAppsPath, newLocalSteamAppsPath, [localSteamAppsFolderRename localizedDescription]);
        if([[NSUserDefaults standardUserDefaults] boolForKey:growlNotificationsEnabledKey]){
            [SCNotificationCenter notifyWithDictionary:(@{
                                                        SCNotificationCenterNotificationTitle: @"Something's Gone Wrong!",
                                                        SCNotificationCenterNotificationDescription: @"Check the console for details.",
                                                        SCNotificationCenterNotificationName: @"An Error Occurred"})];
        }
        return NO;
    }
    
    // rename SteamAppsSymb (the symbolic link) to SteamApps
    NSError *symbolicSteamAppsFolderRename;
    success = [fManager moveItemAtPath:symbolicSteamAppsPath toPath:localSteamAppsPath error:&symbolicSteamAppsFolderRename];
    
    if(!success){
        NSLog(@"I was trying to rename SteamAppsSymb to SteamApps but couldn't rename item [%@] to [%@] because [%@]", symbolicSteamAppsPath, localSteamAppsPath, [symbolicSteamAppsFolderRename localizedDescription]);
        if([[NSUserDefaults standardUserDefaults] boolForKey:growlNotificationsEnabledKey]){
            [SCNotificationCenter notifyWithDictionary:(@{
                                                        SCNotificationCenterNotificationTitle: @"Something's Gone Wrong!",
                                                        SCNotificationCenterNotificationDescription: @"Check the console for details.",
                                                        SCNotificationCenterNotificationName: @"An Error Occurred"})];
        }
        return NO;
    }
    
    // If we get to this point, everything went A-OK, so we can notify the user that the folders have changed and set steamDriveIsConnected to YES.
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:growlNotificationsEnabledKey])
        [SCNotificationCenter notifyWithDictionary:(@{
                                                    SCNotificationCenterNotificationTitle : @"Updated Steam Folders",
                                                    SCNotificationCenterNotificationDescription : @"You're now playing games off of your external drive.",
                                                    SCNotificationCenterNotificationName : @"Changed SteamApps Folders"})];
    self.steamDriveIsConnected = YES;
    return YES;
}

- (BOOL)makeLocalSteamAppsPrimary{
    self.steamDriveIsConnected = NO; // Update this here since the Steam drive will have been disconnected regardless of if this method completes successfully.
    
    NSString *applicationSupportPath = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES)[0];
    NSString *localSteamAppsPath = [[applicationSupportPath stringByAppendingPathComponent:@"Steam"] stringByAppendingPathComponent:@"SteamApps"];
    NSString *symbolicSteamAppsPath = [[applicationSupportPath stringByAppendingPathComponent:@"Steam"] stringByAppendingPathComponent:@"SteamAppsSymb"];
    
    NSFileManager *fManager = [[NSFileManager alloc] init];
    BOOL success = YES;
    
    // Attempt to rename SteamApps to SteamAppsSymb
    NSError *renameSymbolicError;
    success = [fManager moveItemAtPath:localSteamAppsPath toPath:symbolicSteamAppsPath error:&renameSymbolicError];
    if(!success){
        NSLog(@"I was trying to rename SteamApps to SteamAppsSymb but couldn't rename [%@] to [%@] because [%@]", localSteamAppsPath, symbolicSteamAppsPath, [renameSymbolicError localizedDescription]);
        
        if([[NSUserDefaults standardUserDefaults] boolForKey:growlNotificationsEnabledKey]){
            [SCNotificationCenter notifyWithDictionary:(@{
                                                        SCNotificationCenterNotificationTitle: @"Something's Gone Wrong!",
                                                        SCNotificationCenterNotificationDescription: @"Check the console for details.",
                                                        SCNotificationCenterNotificationName: @"An Error Occurred"})];
        }
        return NO;
    }
    
    // Attempt to rename SteamAppsLoc to SteamApps
    NSError *renameLocalError;
    NSString *currentLocalSteamAppsFolderPath = [[localSteamAppsPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"SteamAppsLoc"];
    
    success = [fManager moveItemAtPath:currentLocalSteamAppsFolderPath toPath:localSteamAppsPath error:&renameLocalError];
    if(!success){
        NSLog(@"I was trying to rename SteamAppsLoc to SteamApps but couldn't rename [%@] to [%@] because [%@]", currentLocalSteamAppsFolderPath,localSteamAppsPath, [renameLocalError localizedDescription]);
        if([[NSUserDefaults standardUserDefaults] boolForKey:growlNotificationsEnabledKey]){
            [SCNotificationCenter notifyWithDictionary:(@{
                                                        SCNotificationCenterNotificationTitle: @"Something's Gone Wrong!",
                                                        SCNotificationCenterNotificationDescription: @"Check the console for details.",
                                                        SCNotificationCenterNotificationName: @"An Error Occurred"})];
        }
        return NO;
    }
    
    // If we make it to this point then everything will have been succesful and we can notify the user (assuming they want us to).
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:growlNotificationsEnabledKey])
        [SCNotificationCenter notifyWithDictionary:(@{
                                                    SCNotificationCenterNotificationTitle: @"Updated Steam Folders",
                                                    SCNotificationCenterNotificationDescription: @"You're now playing games off of your internal drive.",
                                                    SCNotificationCenterNotificationName: @"Changed SteamApps Folders"})];
    
    return YES;
}

@end
