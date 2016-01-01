//
//  MGWatchdogPlatformOSX.h
//  Pods
//
//  Created by Max Gordeev.
//

#include <TargetConditionals.h>

#if TARGET_OS_MAC

@import Foundation;
#import "MGWatchdogPlatform.h"

@interface MGWatchdogPlatformOSX : NSObject <MGWatchdogPlatform>

@end

#endif