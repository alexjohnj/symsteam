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

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {
    NSDictionary *notificationUserInfo = notification.userInfo;
    if ([notificationUserInfo[@"notificationIdentifier"] isEqualToString:@"errorNotification"]) {
        NSDictionary *errorDictionary = notificationUserInfo[@"errorDictionary"];
        NSError *attachedError = [[NSError alloc] initWithDomain:errorDictionary[@"domain"]
                                                    code:[errorDictionary[@"code"] integerValue]
                                                userInfo:errorDictionary[@"userInfo"]];
        [[NSAlert alertWithError:attachedError] runModal];
    }
}

- (void)growlNotificationWasClicked:(id)clickContext {
    if([clickContext isKindOfClass:[NSDictionary class]]) {
        if([clickContext[@"notificationIdentifier"] isEqualToString:@"errorNotification"]) {
            NSDictionary *errorDictionary = clickContext[@"errorDictionary"];
            NSError *attachedError = [[NSError alloc] initWithDomain:errorDictionary[@"domain"]
                                                        code:[errorDictionary[@"code"] integerValue]
                                                    userInfo:errorDictionary[@"userInfo"]];
            [[NSAlert alertWithError:attachedError] runModal];
        }
    }
}

@end
