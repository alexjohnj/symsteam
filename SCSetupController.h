//
//  SCSetupController.h
//  SymSteam
//
//  Created by Alex Jackson on 25/08/2012.
//
//

#import <Foundation/Foundation.h>

@interface SCSetupController : NSObject

- (DADiskRef)createDADiskFromDrivePath:(NSURL *)drive CF_RETURNS_RETAINED;
- (BOOL)driveFilesystemIsHFS:(DADiskRef)drive;
- (NSString *)getDriveUUID:(DADiskRef)drive;
- (BOOL)createSymbolicLinkToFolder:(NSURL *)folder;
- (BOOL)folderIsOnExternalDrive:(NSURL *)pathToFolder;

//////////////////////////////////////////////////////////////////////

- (void)saveSymbolicLinkDestinationToUserDefaults:(NSURL *)destination;
- (void)saveDriveUUIDToUserDefaults:(DADiskRef)drive;
- (void)markSetupAsComplete;

@end
