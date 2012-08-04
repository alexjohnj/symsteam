//
//  SCUserNotificationCenterDelegate.m
//  SymSteam
//
//  Created by Alex Jackson on 04/08/2012.
//
//

#import "SCUserNotificationCenterDelegate.h"

@implementation SCUserNotificationCenterDelegate

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification{
    return YES;
}

@end
