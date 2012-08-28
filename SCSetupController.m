//
//  SCSetupController.m
//  SymSteam
//
//  Created by Alex Jackson on 25/08/2012.
//
//

#import "SCSetupController.h"

@implementation SCSetupController

- (DADiskRef)createDADiskFromDrivePath:(NSURL *)drive{
    DASessionRef session = DASessionCreate(kCFAllocatorDefault);
    DADiskRef disk = DADiskCreateFromVolumePath(kCFAllocatorDefault, session, (__bridge CFURLRef)drive);
    CFRelease(session);
    return disk;
}

- (BOOL)driveFilesystemIsHFS:(DADiskRef)drive{
    CFDictionaryRef driveDetails = DADiskCopyDescription(drive);
    NSString *driveFileSystem = (__bridge NSString *)CFDictionaryGetValue(driveDetails, kDADiskDescriptionVolumeKindKey);
    CFRelease(driveDetails);
    
    if([driveFileSystem isEqualToString:@"hfs"])
        return YES;
    else
        return NO;
}

- (BOOL)folderIsOnExternalDrive:(NSURL *)pathToFolder{
    return (pathToFolder.pathComponents.count >= 3 && [pathToFolder.pathComponents[1] isEqualToString:@"Volumes"]);
}

- (NSString *)getDriveUUID:(DADiskRef)drive{
    CFDictionaryRef driveDetails = DADiskCopyDescription(drive);
    
    if(CFDictionaryGetValue(driveDetails, kDADiskDescriptionVolumeUUIDKey) == NULL){
        CFRelease(driveDetails);
        return nil;
    }
    else{
        NSString *uuid = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, CFDictionaryGetValue(driveDetails, kDADiskDescriptionVolumeUUIDKey));
        CFRelease(driveDetails);
        return uuid;
    }
}

- (BOOL)createSymbolicLinkToFolder:(NSURL *)folder{ // Creates a symbolic link at /Application Support/Steam/SteamAppsSymb
    NSFileManager *fManager = [[NSFileManager alloc] init];
    
    NSArray *directories = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDirectory, YES);
    NSString *symbolicLinkPath = [[directories[0] stringByAppendingPathComponent:@"Steam"]  stringByAppendingPathComponent:@"SteamAppsSymb"];
    
    if([fManager attributesOfItemAtPath:symbolicLinkPath error:nil] && [[fManager attributesOfItemAtPath:symbolicLinkPath error:nil] fileType] == NSFileTypeSymbolicLink){
        NSAlert *alert = [NSAlert alertWithMessageText:@"A Symbolic Link Already Exists!"
                                         defaultButton:@"Yes"
                                       alternateButton:@"No"
                                           otherButton:nil
                             informativeTextWithFormat:@"Can I delete it? I can't procede with setup while it's there."];
        if([alert runModal] == NSAlertDefaultReturn)
            [fManager removeItemAtPath:symbolicLinkPath error:nil];
        else{
            NSLog(@"There was a symbolic link already present at %@ and the user wouldn't let me remove it.", symbolicLinkPath);
            return NO;
        }
    }
    
    NSError *symbolicLinkCreationError;
    if([fManager createSymbolicLinkAtPath:symbolicLinkPath withDestinationPath:folder.path error:&symbolicLinkCreationError]){
        return YES;
    }
    else{
        NSLog(@"Unabled to create symbolic link to %@ because %@", folder.path, symbolicLinkCreationError.localizedDescription);
        return NO;
    }
}

- (void)saveSymbolicLinkDestinationToUserDefaults:(NSURL *)destination{
    [[NSUserDefaults standardUserDefaults] setValue:destination.path forKey:@"symbolicPathDestination"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)saveDriveUUIDToUserDefaults:(DADiskRef)drive{
    NSString *uuid = [self getDriveUUID:drive];
    if(uuid){
        [[NSUserDefaults standardUserDefaults] setValue:uuid forKey:@"steamDriveUUID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else{
        NSLog(@"Could not save the drive's UUID to the user defaults because the UUID returned by getDriveUUID: was nil");
    }
}

- (void)markSetupAsComplete{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"setupComplete"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
