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
        NSError *attachedError = [self createErrorFromDictionary:notificationUserInfo[@"errorDictionary"]];
        [self displayErrorToUser:attachedError];
    }
}

- (void)growlNotificationWasClicked:(id)clickContext {
    if([clickContext isKindOfClass:[NSDictionary class]]) {
        if([clickContext[@"notificationIdentifier"] isEqualToString:@"errorNotification"]) {
            NSError *attachedError = [self createErrorFromDictionary:clickContext[@"errorDictionary"]];
            [self displayErrorToUser:attachedError];
        }
    }
}

#pragma mark - Private Methods

- (void)displayErrorToUser:(NSError *) error{
    NSAlert *alert = [[NSAlert alloc] init];
    alert.alertStyle = NSCriticalAlertStyle;
    NSButton *moreInfoButton = nil;
    
    if (error.localizedDescription)
        alert.messageText = error.localizedDescription;
    
    if (error.localizedRecoverySuggestion)
        alert.informativeText = error.localizedRecoverySuggestion;
    
    [alert addButtonWithTitle:NSLocalizedString(@"OK", nil)];
    
    if (error.localizedFailureReason) {
        moreInfoButton = [alert addButtonWithTitle:NSLocalizedString(@"More Information", nil)];
    }

    NSInteger result = [alert runModal];
    if (moreInfoButton && result == moreInfoButton.tag) {
        NSAlert *moreInfoAlert = [NSAlert alertWithMessageText:error.localizedDescription
                                                 defaultButton:NSLocalizedString(@"OK", nil)
                                               alternateButton:nil otherButton:nil
                                     informativeTextWithFormat:@"%@", error.localizedFailureReason];
        [moreInfoAlert runModal];
    }
}

- (NSError *)createErrorFromDictionary:(NSDictionary *)dict {
    NSError *error = [[NSError alloc] initWithDomain:dict[@"domain"] code:dict[@"code"] userInfo:dict[@"userInfo"]];
    return error;
}

@end
