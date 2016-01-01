//
//  MGMainRunloopObserver.h
//  MGWatchdog
//
//  Created by Max Gordeev.
//

@import Foundation;

@interface MGMainRunloopObserver : NSObject

- (void)startWithBeginPingHandler:(void (^)(void))beginPingHandler endPingHandler:(void (^)(void))endPingHandler;

- (void)stop;

@end
