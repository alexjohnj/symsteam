//
//  SCNotificationCenter+ErrorNotification.h
//  SymSteam
//
//  Created by Alex Jackson on 04/04/2013.
//
//

#import "SCNotificationCenter.h"

@interface SCNotificationCenter (ErrorNotification)

- (void)notifyWithError:(NSError *)error;

@end
