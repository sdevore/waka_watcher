//
//  MGWatchdogImpl.h
//  MGWatchdog
//
//  Created by Max Gordeev.
//

@import Foundation;

@interface MGWatchdogImpl : NSObject

- (void)startWithDelay:(NSTimeInterval)delay handler:(void (^)(void))handler;

- (void)stop;

- (void)beginPing;

- (void)endPing;

@end
