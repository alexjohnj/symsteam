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
    CFURLRef appURL = (__bridge_retained CFURLRef)applicationURL;
    UInt32 copySeed;
    
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    CFArrayRef loginItemsCopySnapshot = LSSharedFileListCopySnapshot(loginItems, &copySeed);
    NSArray *loginItemsArray = (__bridge_transfer NSArray *)loginItemsCopySnapshot;
    
    for(id loginItem in loginItemsArray){
        LSSharedFileListItemRef currentItem = (__bridge_retained LSSharedFileListItemRef)(loginItem);
        if(LSSharedFileListItemResolve(currentItem, 0, &appURL, NULL) == noErr){
            NSString *currentPath = [(__bridge NSURL *)appURL path];
            if([currentPath isEqualToString:applicationURL.path]){
                CFRelease(loginItems);
                CFRelease(appURL);
                CFRelease(currentItem);
                return YES;
            }
        }
        CFRelease(currentItem);
    }
    CFRelease(appURL);
    CFRelease(loginItems);
    return NO;
}

- (void)removeApplicationFromLoginItems:(NSURL *)applicationURL{
    CFURLRef appURL = (__bridge_retained CFURLRef)applicationURL;
    UInt32 copySeed;
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    
    CFArrayRef loginItemsCopySnapshot = LSSharedFileListCopySnapshot(loginItems, &copySeed);
    NSArray *loginItemsArray = (__bridge_transfer NSArray *)loginItemsCopySnapshot;
    
    for(id loginItem in loginItemsArray){
        LSSharedFileListItemRef currentItem = (__bridge_retained LSSharedFileListItemRef)(loginItem);
        if(LSSharedFileListItemResolve(currentItem, 0, &appURL, NULL) == noErr){
            NSString *currentPath = [(__bridge NSURL *)appURL path];
            if([currentPath isEqualToString:applicationURL.path]){
                LSSharedFileListItemRemove(loginItems, currentItem);
            }
        }
        CFRelease(currentItem);
    }
    CFRelease(loginItems);
    CFRelease(appURL);
}

- (void)addApplicationToLoginItems:(NSURL *)applicationURL{
    if(applicationURL == nil){
        DDLogCError(@"SCLoginController: The provided application URL was nil, so I couldn't add anything to the login items list");
        return;
    }
    CFURLRef appURL = (__bridge_retained CFURLRef)applicationURL;
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    if(loginItems == NULL)
        return;
    LSSharedFileListInsertItemURL(loginItems,
                                  kLSSharedFileListItemLast,
                                  NULL,
                                  NULL,
                                  appURL,
                                  NULL,
                                  NULL);
    CFRelease(loginItems);
    CFRelease(appURL);
}

@end
