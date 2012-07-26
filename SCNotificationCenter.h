//
//  SCNotificationCenter.h
//  SymSteam
//
//  Created by Alex Jackson on 26/07/2012.
//
//

#import <Foundation/Foundation.h>
#import <Growl/Growl.h>
#import "SCNotificationCenterKeys.h"

@interface SCNotificationCenter : NSObject

+ (SCNotificationCenter *)sharedCenter;

// The keys for notification dictionaries can be found in SCNotificationCenterKeys.h.

- (void)notifyWithDictionary:(NSDictionary *)dictionary;

// Legacy Methods
// Avoid using these methods, they are here so that updating an app to use SCNotificationCenter would be easily done using a simple find and replace.
// Try to use the notifyWithDictionary: method since this will allow you to make use of interactive notifications in notifications center while maintaining compatibility with Growl and older versions of OS X.

- (void)notifyWithTitle:(NSString *)title
            description:(NSString *)description
       notificationName:(NSString *)notifName
               iconData:(NSData *)iconData
               priority:(signed int)priority
               isSticky:(BOOL)isSticky
           clickContext:(id)clickContext
             identifier:(NSString *)indentifier;

- (void)notifyWithTitle:(NSString *)title
            description:(NSString *)description
       notificationName:(NSString *)notifName
               iconData:(NSData *)iconData
               priority:(signed int)priority
               isSticky:(BOOL)isSticky
           clickContext:(id)clickContext;


@property (assign) BOOL systemNotificationCenterAvailable;
@property (weak) id notificationCenterDelegate;

@end
