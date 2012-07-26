//
//  SCLoginController.h
//  SymSteam
//
//  Created by Alex Jackson on 26/07/2012.
//
//

#import <Foundation/Foundation.h>

@interface SCLoginController : NSObject

- (BOOL)checkSessionLoginItemsForApplication:(NSURL *)applicationURL;
- (void)removeApplicationFromLoginItems:(NSURL *)applicationURL;
- (void)addApplicationToLoginItems:(NSURL *)applicationURL;

@end
