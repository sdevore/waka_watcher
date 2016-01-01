//
//  MGWatchdogPlatformOSX.m
//  Pods
//
//  Created by Max Gordeev.
//

#import "MGWatchdogPlatformOSX.h"

#if TARGET_OS_MAC

@implementation MGWatchdogPlatformOSX

- (BOOL)isApplicationInActiveState
{
    return YES;
}

@end

#endif