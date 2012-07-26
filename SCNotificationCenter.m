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

/* KEYS FOR DICTIONARY
 "NotificationName"
 ------------------
 A human readable name for the notification that must be declared in the Growl notification dictionary. Has no use with NSUserNotification.
 
 "NotificationTitle"
 -------------------
 The title of the notification. The same as Growl's "NotificationName" key and the same as NSUserNotification's title property.
 
 "NotificationDescription"
 -------------------------
 A description displayed with the notification. The same as Growl's "NotificationDescription" key and the same as NSUserNotification's informativeText property.
 
 "NotificationIcon"
 ------------------
 An NSData object displayed with a Growl notification. The same as Growl's "NotificationIcon" key. There's no equivelent for NSUserNotification and it will be ignored.
 
 "NotificationAppIcon"
 ---------------------
 Same as above (pretty much) see Growl docs for more information. The same as Growl's "NotificationAppIcon" key. Not available for NSUserNotification.
 
 "NotificationPriority"
 ----------------------
 An (NSNumber) integer between -2 & 2. The same as Growl's "NotificationPriority" key. No equivelent for NSUserNotification.
 
 "NotificationSticky"
 --------------------
 An (NSNumber) bool indicating if the notification should automatically disappear. The same as Growl's "NotificationSticky". No equivelent for NSUserNotification.
 
 "NotificationClickContext"
 --------------------------
 A plist-encodable object that is unique to a notification and is provided in a notification clicked delegate method. The same as Growl's "NotificationClickContext". Will be placed inside a dictionary under the key "NotificationClickContext" for NSUserNotification and applied to the notification's userInfo property. The object must be small (>1KB) and its type must be specified or else notifications will not work with NSUserNotification but will work with Growl.
 
 "NotificationIdentifier"
 ------------------------
 An identifier for the notification. Must be a string. The same as "GrowlNotificationIdentifier" for Growl. Will be placed in a dictionary under the key "GrowlNotificationIdentifier" for NSUserNotification and provided in the notification's userInfo property.
 
 "GrowlNotificationIdentifier"
 -----------------------------
 ^^ The same as above.
 
 "NotificationSubtitle"
 ----------------------
 A subtitle for the notification. No equvielent for Growl and so will do nothing. Used as an NSUserNotification's subtitle property.
 
 "NotificationHasActionButton"
 -----------------------------
 Boolean value. Provides an action button for the notification. No equivalent for Growl. NSUserNotification only.
 
 "NotificationActionButtonTitle"
 -------------------------------
 A title for an action button. No equivelent for Growl. NSUserNotification only.
 
 "NotificationDeliveryDate"
 -------------------------
 An NSDate that dictates when the notification should be displayed. No equivelent for Growl (yet). Sets the deliveryDate property for an NSUserNotification.
 
 */



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
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
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
    [GrowlApplicationBridge notifyWithDictionary:details];
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
