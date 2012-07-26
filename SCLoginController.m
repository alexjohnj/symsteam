//
//  SCLoginController.m
//  SymSteam
//
//  Created by Alex Jackson on 26/07/2012.
//
//

#import "SCLoginController.h"

@implementation SCLoginController

- (BOOL)checkSessionLoginItemsForApplication:(NSURL *)applicationURL{
    CFURLRef appURL = (__bridge CFURLRef)applicationURL;
    UInt32 copySeed;
    
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    CFArrayRef loginItemsCopySnapshot = LSSharedFileListCopySnapshot(loginItems, &copySeed);
    NSArray *loginItemsArray = (__bridge NSArray *)loginItemsCopySnapshot;
    CFRelease(loginItemsCopySnapshot);
    
    for(id loginItem in loginItemsArray){
        LSSharedFileListItemRef currentItem = (__bridge LSSharedFileListItemRef)(loginItem);
        if(LSSharedFileListItemResolve(currentItem, 0, &appURL, NULL) == noErr){
            NSString *currentPath = [(__bridge NSURL *)appURL path];
            if([currentPath isEqualToString:applicationURL.path]){
                CFRelease(appURL);
                return YES;
            }
        }
    }
    
    CFRelease(appURL);
    return NO;
}

- (void)removeApplicationFromLoginItems:(NSURL *)applicationURL{
    CFURLRef appURL = (__bridge CFURLRef)applicationURL;
    UInt32 copySeed;
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    
    CFArrayRef loginItemsCopySnapshot = LSSharedFileListCopySnapshot(loginItems, &copySeed);
    NSArray *loginItemsArray = (__bridge NSArray *)loginItemsCopySnapshot;
    CFRelease(loginItemsCopySnapshot);
    
    for(id loginItem in loginItemsArray){
        LSSharedFileListItemRef currentItem = (__bridge LSSharedFileListItemRef)(loginItem);
        if(LSSharedFileListItemResolve(currentItem, 0, &appURL, NULL) == noErr){
            NSString *currentPath = [(__bridge NSURL *)appURL path];
            if([currentPath isEqualToString:applicationURL.path]){
                LSSharedFileListItemRemove(loginItems, currentItem);
            }
        }
    }
    CFRelease(appURL);
}

- (void)addApplicationToLoginItems:(NSURL *)applicationURL{
    CFURLRef appURL = (__bridge CFURLRef)applicationURL;
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    LSSharedFileListInsertItemURL(loginItems,
                                  kLSSharedFileListItemLast,
                                  NULL,
                                  NULL,
                                  appURL,
                                  NULL,
                                  NULL);
    CFRelease(appURL);
}

@end
