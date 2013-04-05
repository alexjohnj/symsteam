//
//  SCNotificationCenter+ErrorNotification.m
//  SymSteam
//
//  Created by Alex Jackson on 04/04/2013.
//
//

#import "SCNotificationCenter+ErrorNotification.h"

@implementation SCNotificationCenter (ErrorNotification)

- (void)notifyWithError:(NSError *)error {
    // Recreate the error as a dictionary so that it can be passed with the notification's userInfo dictionary
    NSDictionary *errorDictionary = @{
                                      @"code" : [NSNumber numberWithInteger:error.code],
                                      @"domain" : error.domain,
                                      @"userInfo" : error.userInfo
                                      };
    
    // Construct the notification as a dictionary
    NSDictionary *notificationDictionary = @{
                                       SCNotificationCenterNotificationName : NSLocalizedString(@"errorOccuredGrowlTitle", nil),
                                       SCNotificationCenterNotificationTitle : NSLocalizedString(@"Something's Gone Wrong!", nil),
                                       SCNotificationCenterNotificationDescription : NSLocalizedString(@"Click for more information", nil),
                                       SCNotificationCenterNotificationUserInfo : @ {
                                           @"notificationIdentifier" : @"errorNotification", // Could be used in the future to distinguish between notifications
                                           @"errorDictionary" : errorDictionary
                                        }
                                       };
    [self notifyWithDictionary:notificationDictionary];
}

@end
