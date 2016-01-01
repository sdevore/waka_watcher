//
//  MGWatchdogPlatformIOS.h
//  Pods
//
//  Created by Max Gordeev on 31/05/15.
//
//

#include <TargetConditionals.h>

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

@import Foundation;
#import "MGWatchdogPlatform.h"

@interface MGWatchdogPlatformIOS : NSObject <MGWatchdogPlatform>

@end

#endif