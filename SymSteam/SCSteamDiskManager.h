//
//  SCSteamDiskWatcher.h
//  SymSteam
//
//  Created by Alex Jackson on 27/08/2012.
//
//

#import <Foundation/Foundation.h>
#import <DiskArbitration/DiskArbitration.h>

@interface SCSteamDiskManager : NSObject

@property (assign) BOOL steamDriveIsConnected;
@property (assign) BOOL isRegisteredForDACallbacks;
@property (assign) DASessionRef diskMonitoringSession;
@property (assign) DAApprovalSessionRef diskApprovalSession;

- (void)startWatchingForDrives;
- (void)stopWatchingForDrives;
- (BOOL)suspectDriveIsSteamDrive:(DADiskRef)suspectDrive;
+ (SCSteamDiskManager *)steamDiskManager;

// Disk Arbitration Callback Registration
void registerForDADiskCallbacks(void *context);
void unregisterForDADiskCallbacks(void *context);

// Disk Approval Callbacks
DADissenterRef diskWillMount(DADiskRef disk, void *context);
DADissenterRef diskWillUnmount(DADiskRef disk, void *context);

// Disk Visibility Callbacks
void diskDidDisappear(DADiskRef disk, void *context);

@end
