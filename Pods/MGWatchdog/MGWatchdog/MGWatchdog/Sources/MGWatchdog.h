//
//  MGWatchdog.h
//  MGWatchdog
//
//  Created by Max Gordeev.
//

#import <Foundation/Foundation.h>


@protocol MGIWatchdog <NSObject>

@required

/**
 @param delay Delay in seconds
 @param handler Invokes after catching UI freeze
 */
+ (void)startWithDelay:(NSTimeInterval)delay handler:(void (^)(void))handler;

/**
 Stop observing UI events.
 */
+ (void)stop;

/**
 Skip all UI freezed till the end of current UI loop.
 */
+ (void)skipCurrentLoop;

@end


@interface MGWatchdog : NSObject <MGIWatchdog>
@end
