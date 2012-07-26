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

- (void)notifyWithDictionary:(NSDictionary *)dictionary;

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
