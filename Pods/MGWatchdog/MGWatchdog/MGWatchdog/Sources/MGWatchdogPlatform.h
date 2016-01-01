//
//  MGWatchdogPlatform.h
//  Pods
//
//  Created by Max Gordeev on 31/05/15.
//
//

#import <Foundation/Foundation.h>

@protocol MGWatchdogPlatform <NSObject>

@required

- (BOOL)isApplicationInActiveState;

@end
