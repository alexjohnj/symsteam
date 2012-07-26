//
//  SCNotificationCenter.m
//  SymSteam
//
//  Created by Alex Jackson on 26/07/2012.
//
//

#import "SCNotificationCenter.h"

@implementation SCNotificationCenter

#pragma mark - Singleton Stuff

static SCNotificationCenter *sharedNotificationCenter = nil;

+ (SCNotificationCenter *)sharedCenter
{
    if (sharedNotificationCenter == nil) {
        sharedNotificationCenter = [[super allocWithZone:NULL] init];
    }
    return sharedNotificationCenter;
}

- (id)init{
    self = [super init];
    if(self){
        Class notificationCenterClass = NSClassFromString(@"NSUserNotificationCenter");
        if(!notificationCenterClass)
            _systemNotificationCenterAvailable = NO;
        else
            _systemNotificationCenterAvailable = YES;
    }
    return self;
}


# pragma mark - "Modern" Notification Display Methods

- (void)notifyWithDictionary:(NSDictionary *)dictionary{
    if(self.systemNotificationCenterAvailable)
        [self displayNotificationUsingNotificationCenterWithDetails:dictionary];
    else
        [self displayNotificationUsingGrowlWithDetails:dictionary];
}

- (void)displayNotificationUsingNotificationCenterWithDetails:(NSDictionary *)details{
    BOOL scheduledNotification = NO;
    
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    if(details[SCNotificationCenterNotificationTitle])
        notification.title = details[SCNotificationCenterNotificationTitle];
    
    if(details[SCNotificationCenterNotificationDescription])
        notification.informativeText = details[SCNotificationCenterNotificationDescription];
    
    if(details[SCNotificationCenterNotificationSubtitle])
        notification.subtitle = details[SCNotificationCenterNotificationSubtitle];
    
    if(details[SCNotificationCenterNotificationHasActionButton])
        notification.hasActionButton = [details[SCNotificationCenterNotificationHasActionButton] boolValue];
    
    if(details[SCNotificationCenterNotificationActionButtonTitle])
        notification.actionButtonTitle = details[SCNotificationCenterNotificationActionButtonTitle];
    
    if(details[SCNotificationCenterNotificationDeliveryDate]){
        notification.deliveryDate = details[SCNotificationCenterNotificationDeliveryDate];
        scheduledNotification = YES;
    }
    
    // Build the userInfo dictionary.
    NSMutableDictionary *userInfo;
    
    if(!details[SCNotificationCenterNotificationUserInfo]){
        userInfo = [[NSMutableDictionary alloc] init];
    }
    else{
        userInfo = [details[SCNotificationCenterNotificationUserInfo] mutableCopy];
    }
    
    if(details[SCNotificationCenterNotificationClickContext])
        userInfo[SCNotificationCenterNotificationClickContext] = details[SCNotificationCenterNotificationClickContext];
    
    if(details[SCNotificationCenterNotificationIdentifier])
        userInfo[SCNotificationCenterGrowlNotificationIdentifier] = details[SCNotificationCenterNotificationIdentifier];
    
    else if(details[SCNotificationCenterGrowlNotificationIdentifier])
        userInfo[SCNotificationCenterGrowlNotificationIdentifier] = details[SCNotificationCenterGrowlNotificationIdentifier];
    
    notification.userInfo = [userInfo copy];
    
    if(scheduledNotification)
        [[NSUserNotificationCenter defaultUserNotificationCenter] scheduleNotification:notification];
    else
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

- (void)displayNotificationUsingGrowlWithDetails:(NSDictionary *)details{
    if(!details[SCNotificationCenterNotificationClickContext] && details[SCNotificationCenterNotificationUserInfo]){
        NSMutableDictionary *newDetails = [details mutableCopy];
        [newDetails setValue:details[SCNotificationCenterNotificationUserInfo] forKey:SCNotificationCenterNotificationClickContext];
        [GrowlApplicationBridge notifyWithDictionary:newDetails];
    }
    else{
        [GrowlApplicationBridge notifyWithDictionary:details];
    }
}


# pragma mark - Legacy Notification Methods

- (void)notifyWithTitle:(NSString *)title
            description:(NSString *)description
       notificationName:(NSString *)notifName
               iconData:(NSData *)iconData
               priority:(signed int)priority
               isSticky:(BOOL)isSticky
           clickContext:(id)clickContext{
    NSMutableDictionary *notificationDetails = [[NSMutableDictionary alloc] init];
    if(title)
        notificationDetails[SCNotificationCenterNotificationTitle] = title;
    if(description)
        notificationDetails[SCNotificationCenterNotificationDescription] = description;
    if(notifName)
        notificationDetails[SCNotificationCenterNotificationName] = notifName;
    if(iconData)
        notificationDetails[SCNotificationCenterNotificationIcon] = iconData;
    
    notificationDetails[SCNotificationCenterNotificationPriority] = @(priority);
    notificationDetails[SCNotificationCenterNotificationSticky] = @(isSticky);
    if(clickContext)
        notificationDetails[SCNotificationCenterNotificationClickContext] = clickContext;
    
    [self notifyWithDictionary:[notificationDetails copy]];
    
}

- (void)notifyWithTitle:(NSString *)title
            description:(NSString *)description
       notificationName:(NSString *)notifName
               iconData:(NSData *)iconData
               priority:(signed int)priority
               isSticky:(BOOL)isSticky
           clickContext:(id)clickContext
             identifier:(NSString *)indentifier{
    
    NSMutableDictionary *notificationDetails = [[NSMutableDictionary alloc] init];
    if(title)
        notificationDetails[SCNotificationCenterNotificationTitle] = title;
    if(description)
        notificationDetails[SCNotificationCenterNotificationDescription] = description;
    if(notifName)
        notificationDetails[SCNotificationCenterNotificationName] = notifName;
    if(iconData)
        notificationDetails[SCNotificationCenterNotificationIcon] = iconData;
    
    notificationDetails[SCNotificationCenterNotificationPriority] = @(priority);
    notificationDetails[SCNotificationCenterNotificationSticky] = @(isSticky);
    if(clickContext)
        notificationDetails[SCNotificationCenterNotificationClickContext] = clickContext;
    if(indentifier)
        notificationDetails[SCNotificationCenterNotificationIdentifier] = indentifier;
    
    [self notifyWithDictionary:[notificationDetails copy]];
}

@end
