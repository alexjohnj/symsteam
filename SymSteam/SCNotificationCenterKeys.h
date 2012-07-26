//
//  SCNotificationCenterKeys.h
//  SymSteam
//
//  Created by Alex Jackson on 26/07/2012.
//
//

#import <Foundation/Foundation.h>

extern NSString * const SCNotificationCenterNotificationName;
extern NSString * const SCNotificationCenterNotificationTitle;
extern NSString * const SCNotificationCenterNotificationDescription;
extern NSString * const SCNotificationCenterNotificationIcon;
extern NSString * const SCNotificationCenterNotificationAppIcon;
extern NSString * const SCNotificationCenterNotificationPriority;
extern NSString * const SCNotificationCenterNotificationSticky;
extern NSString * const SCNotificationCenterNotificationClickContext;
extern NSString * const SCNotificationCenterNotificationIdentifier;
extern NSString * const SCNotificationCenterGrowlNotificationIdentifier;
extern NSString * const SCNotificationCenterNotificationSubtitle;
extern NSString * const SCNotificationCenterNotificationHasActionButton;
extern NSString * const SCNotificationCenterNotificationActionButtonTitle;
extern NSString * const SCNotificationCenterNotificationDeliveryDate;
extern NSString * const SCNotificationCenterNotificationUserInfo;

/*  ***** KEYS FOR SCNotificationCenter DICTIONARY
 "NotificationName"
 ------------------
 A human readable name for the notification that must be declared in the Growl notification dictionary. Has no use with NSUserNotification. Required for Growl notifications.
 
 "NotificationTitle"
 -------------------
 The title of the notification. The same as Growl's "NotificationName" key and the same as NSUserNotification's title property.
 
 "NotificationDescription"
 -------------------------
 A description displayed with the notification. The same as Growl's "NotificationDescription" key and the same as NSUserNotification's informativeText property.
 
 "NotificationIcon"
 ------------------
 An NSData object displayed with a Growl notification. The same as Growl's "NotificationIcon" key. There's no equivalent for NSUserNotification and it will be ignored.
 
 "NotificationAppIcon"
 ---------------------
 Same as above (pretty much) see Growl docs for more information. The same as Growl's "NotificationAppIcon" key. Not available for NSUserNotification.
 
 "NotificationPriority"
 ----------------------
 An (NSNumber) integer between -2 & 2. The same as Growl's "NotificationPriority" key. No equivalent for NSUserNotification.
 
 "NotificationSticky"
 --------------------
 An (NSNumber) bool indicating if the notification should automatically disappear. The same as Growl's "NotificationSticky". No equivalent for NSUserNotification.
 
 "NotificationClickContext"
 --------------------------
 A plist-encodable object that is unique to a notification and is given back to you in a notification clicked delegate method. The same as Growl's "NotificationClickContext".
 
 For NSUserNotification's, the clickContext will be placed inside a userInfo dictionary under the key "NotificationClickContext". When using this with NSUserNotification, be sure that the clickContext is still plist encodable and that the object passed is less than 1KB in size.
 
 "NotificationIdentifier"
 ------------------------
 An identifier for the notification. Must be a string. The same as "GrowlNotificationIdentifier" for Growl. Will be placed in a dictionary under the key "GrowlNotificationIdentifier" for NSUserNotification and provided in the notification's userInfo property.
 
 "GrowlNotificationIdentifier"
 -----------------------------
 ^^ The same as above.
 
 "NotificationSubtitle"
 ----------------------
 A subtitle for the notification. No equivalent for Growl and so will do nothing. Used as an NSUserNotification's subtitle property.
 
 "NotificationHasActionButton"
 -----------------------------
 Boolean value. Provides an action button for the notification. No equivalent for Growl. NSUserNotification only.
 
 "NotificationActionButtonTitle"
 -------------------------------
 A title for an action button. No equivalent for Growl. NSUserNotification only.
 
 "NotificationDeliveryDate"
 -------------------------
 An NSDate that dictates when the notification should be displayed. No equivalent for Growl (yet). Sets the deliveryDate property for an NSUserNotification.
 
 "NotificationUserInfo"
 ----------------------
 An NSDictionary that contains only plist-encodable objects. The object will be made available when a notification is clicked. For NSUserNotifications, the notification's userInfo property will be set to this. For Growl notifications, the notifications clickContext will be set to this.
 */

@interface SCNotificationCenterKeys : NSObject

@end
