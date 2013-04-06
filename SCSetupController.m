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

- (BOOL)verifyProvidedFolderIsUsable:(NSURL *)folder{
    if(![self folderIsOnExternalDrive:folder]){
        NSAlert *invalidDestinationAlert = [NSAlert alertWithMessageText:NSLocalizedString(@"Error", nil)
                                                           defaultButton:NSLocalizedString(@"OK", nil)
                                                         alternateButton:nil
                                                             otherButton:nil
                                               informativeTextWithFormat:NSLocalizedString(@"The folder you provided is not on an external drive.", nil)];
        if([NSApp mainWindow])
            [invalidDestinationAlert beginSheetModalForWindow:[NSApp mainWindow] modalDelegate:nil didEndSelector:nil contextInfo:NULL];
        else
            [invalidDestinationAlert runModal];
        return NO;
    }
    
    DADiskRef drive = [self createDADiskFromDrivePath:[self getDrivePathFromFolderPath:folder]];
    if([self getDriveUUID:drive] == NULL){
        NSAlert *noUUIDFound = [NSAlert alertWithMessageText:NSLocalizedString(@"Error", nil)
                                               defaultButton:NSLocalizedString(@"OK", nil)
                                             alternateButton:nil
                                                 otherButton:nil
                                   informativeTextWithFormat:NSLocalizedString(@"No UUID Message", nil)];
        if([NSApp mainWindow])
            [noUUIDFound beginSheetModalForWindow:[NSApp mainWindow] modalDelegate:nil didEndSelector:nil contextInfo:NULL];
        else
            [noUUIDFound runModal];
        CFRelease(drive);
        return NO;
    }
    CFRelease(drive);
    return YES;
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

- (NSURL *)getDrivePathFromFolderPath:(NSURL *)folderPath{
    if(folderPath == nil){
        DDLogError(@"getDrivePathFromFolderPath: The provided folderPath was nil");
        return nil;
    }
    if(folderPath.pathComponents.count < 3){
        DDLogError(@"getDrivePathFromFolderPath: The provided folderPath was too short to create a drive path");
        return nil;
    }
    return [NSURL fileURLWithPathComponents:(@[folderPath.pathComponents[0], folderPath.pathComponents[1], folderPath.pathComponents[2]])];
}

- (BOOL)createSymbolicLinkToFolder:(NSURL *)folder error:(NSError *__autoreleasing*)error{ // Creates a symbolic link at /Application Support/Steam/SteamAppsSymb
    NSFileManager *fManager = [[NSFileManager alloc] init];
    NSError __autoreleasing *symbolicLinkCreationError;
    
    NSArray *directories = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDirectory, YES);
    NSString *symbolicLinkPath;
    if(![[SCSteamDiskManager steamDiskManager] steamDriveIsConnected])
        symbolicLinkPath = [[directories[0] stringByAppendingPathComponent:@"Steam"]  stringByAppendingPathComponent:@"SteamAppsSymb"];
    else
        symbolicLinkPath = [[directories[0] stringByAppendingPathComponent:@"Steam"]  stringByAppendingPathComponent:@"SteamApps"];
    
    if([fManager attributesOfItemAtPath:symbolicLinkPath error:nil] && [[fManager attributesOfItemAtPath:symbolicLinkPath error:nil] fileType] == NSFileTypeSymbolicLink){
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Symbolic Link Exists Message", nil)
                                         defaultButton:NSLocalizedString(@"OK", nil)
                                       alternateButton:NSLocalizedString(@"No", nil)
                                           otherButton:nil
                             informativeTextWithFormat:NSLocalizedString(@"Symbolic Link Delete Confirmation", nil)];
        if([alert runModal] == NSAlertDefaultReturn) {
            if(![fManager removeItemAtPath:symbolicLinkPath error:&symbolicLinkCreationError]){
                if(error)
                    *error = symbolicLinkCreationError;
                return NO;
            }
        }
        else{
            NSString *errorDescription = NSLocalizedString(@"Symbolic Link Delete Failed Message", nil);
            NSString *errorRecoveryString = NSLocalizedString(@"Symbolic Link Delete Failed Fix", nil);
            
            if(error){
                symbolicLinkCreationError = [[NSError alloc] initWithDomain:@"com.simplecode.symsteam"
                                                                   code:1
                                                               userInfo:@{NSLocalizedDescriptionKey: errorDescription, NSLocalizedRecoverySuggestionErrorKey: errorRecoveryString}];
                *error = symbolicLinkCreationError;
            }
            return NO;
        }
    }
    
    if([fManager createSymbolicLinkAtPath:symbolicLinkPath withDestinationPath:folder.path error:&symbolicLinkCreationError]){
        return YES;
    }
    else{
        DDLogError(@"Unabled to create symbolic link to %@ because %@", folder.path, symbolicLinkCreationError.localizedDescription);
        if(error)
            *error = symbolicLinkCreationError;
        return NO;
    }
}

- (void)saveSymbolicLinkDestinationToUserDefaults:(NSURL *)destination{
    [[NSUserDefaults standardUserDefaults] setValue:destination.path forKey:SCSteamAppsSymbolicLinkDestinationKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)saveDriveUUIDToUserDefaults:(DADiskRef)drive{
    NSString *uuid = [self getDriveUUID:drive];
    if(uuid){
        [[NSUserDefaults standardUserDefaults] setValue:uuid forKey:SCSteamDriveUUIDKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else{
        DDLogError(@"Could not save the drive's UUID to the user defaults because the UUID returned by getDriveUUID: was nil");
    }
}

- (void)markSetupAsComplete{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SCSetupCompleteKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
