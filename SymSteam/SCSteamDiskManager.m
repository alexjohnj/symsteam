//
//  SCSteamDiskWatcher.m
//  SymSteam
//
//  Created by Alex Jackson on 27/08/2012.
//
//

#import "SCSteamDiskManager.h"
#import "SCSteamAppsFoldersController.h"

static NSString * const steamDriveUUIDKey = @"steamDriveUUID";
static NSString * const growlNotificationsEnabledKey = @"growlNotificationsEnabled";
static NSString * const symbolicPathDestinationKey = @"symbolicPathDestination";

#pragma mark - Disk Mount Approval Callbacks

DADissenterRef diskWillMount(DADiskRef disk, void *context){
    if(context == NULL){
        NSLog(@"A drive wanted to mount but the context was NULL, it can't be.");
        return NULL;
    } if(disk == NULL){
        NSLog(@"A drive wanted to mount and the providied drive was NULL for some reason.");
        return NULL;
    }
    
    SCSteamDiskManager *driveManager = (__bridge SCSteamDiskManager *)context;
    if(driveManager.steamDriveIsConnected)
        return NULL;
    if([driveManager suspectDriveIsSteamDrive:disk]){
        SCSteamAppsFoldersController *folderController = [[SCSteamAppsFoldersController alloc] init];
        [folderController makeSymbolicSteamAppsPrimary];
    }
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
    
    SCSteamDiskManager *driveManager = (__bridge SCSteamDiskManager *)context;
    if(!driveManager.steamDriveIsConnected)
        return NULL;
    if([driveManager suspectDriveIsSteamDrive:disk]){
        SCSteamAppsFoldersController *folderController = [[SCSteamAppsFoldersController alloc] init];
        [folderController makeLocalSteamAppsPrimary];
    }
    return NULL;
}

#pragma mark - Disk Visibility Callbacks

void diskDidDisappear(DADiskRef disk, void *context){
    if(context == NULL){
        NSLog(@"The context was NULL, it can't be.");
        return;
    } if(disk == NULL){
        NSLog(@"The provided DADiskref was NULL");
        return;
    }
    SCSteamDiskManager *diskManager = (__bridge SCSteamDiskManager *)context;
    if(diskManager.steamDriveIsConnected && [diskManager suspectDriveIsSteamDrive:disk]){
        SCSteamAppsFoldersController *folderController = [[SCSteamAppsFoldersController alloc] init];
        [folderController makeLocalSteamAppsPrimary];
    }
}

#pragma mark - Disk Observation Functions

void registerForDADiskCallbacks(void *context){
    SCSteamDiskManager *diskManager = (__bridge SCSteamDiskManager *)context;
    if(diskManager.isRegisteredForDACallbacks)
        return;
    if(diskManager.diskMonitoringSession == NULL)
        diskManager.diskMonitoringSession = DASessionCreate(kCFAllocatorDefault);
    if(diskManager.diskApprovalSession == NULL)
        diskManager.diskApprovalSession = DAApprovalSessionCreate(kCFAllocatorDefault);
    
    DARegisterDiskMountApprovalCallback(diskManager.diskApprovalSession, NULL, diskWillMount, context);
    DARegisterDiskDisappearedCallback(diskManager.diskMonitoringSession, NULL, diskDidDisappear, context);
    DARegisterDiskUnmountApprovalCallback(diskManager.diskMonitoringSession, NULL, diskWillUnmount, context);
    DASessionScheduleWithRunLoop(diskManager.diskMonitoringSession, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    DAApprovalSessionScheduleWithRunLoop(diskManager.diskApprovalSession, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    diskManager.isRegisteredForDACallbacks = YES;
}

void unregisterForDADiskCallbacks(void *context){
    SCSteamDiskManager *diskManager = (__bridge SCSteamDiskManager *)context;
    if(!diskManager.isRegisteredForDACallbacks)
        return;
    if(diskManager.diskMonitoringSession != NULL){
        DAUnregisterCallback(diskManager.diskMonitoringSession, diskDidDisappear, NULL);
    }
    if(diskManager.diskApprovalSession != NULL){
        DAUnregisterApprovalCallback(diskManager.diskApprovalSession, diskWillMount, NULL);
        DAUnregisterApprovalCallback(diskManager.diskApprovalSession, diskWillUnmount, NULL);
    }
    diskManager.isRegisteredForDACallbacks = NO;
}

#pragma mark -

@implementation SCSteamDiskManager

#pragma mark - Object Lifecycle Stuff

- (id)init{
    self = [super init];
    if(self){
        _steamDriveIsConnected = NO;
    }
    return self;
}

# pragma mark - Singleton Stuff

+ (SCSteamDiskManager *)steamDiskManager
{
    static dispatch_once_t pred;
    __strong static SCSteamDiskManager *diskManager = nil;
    
    dispatch_once(&pred, ^{
        diskManager = [[self alloc] init];
    });
    
    return diskManager;
}

#pragma mark - Disk Observation Methods

- (void)startWatchingForDrives{
    SCSteamAppsFoldersController *folderController = [[SCSteamAppsFoldersController alloc] init];
    [folderController performInitialDriveScan];
    registerForDADiskCallbacks((__bridge void*)self);
}

- (void)stopWatchingForDrives{
    if(self.steamDriveIsConnected){
        SCSteamAppsFoldersController *folderController = [[SCSteamAppsFoldersController alloc] init];
        [folderController makeLocalSteamAppsPrimary];
    }
    unregisterForDADiskCallbacks((__bridge void*)self);
}

#pragma mark - Disk Identification Methods

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

@end
