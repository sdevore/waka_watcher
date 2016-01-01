//
//  MGWatchdogPlatformIOS.m
//  Pods
//
//  Created by Max Gordeev.
//

#import "MGWatchdogPlatformIOS.h"

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

@import UIKit;

#import "MGWatchdog.h"


@interface MGWatchdog (Configuration)

+ (void)startFromPreviousConfiguration;

@end


@implementation MGWatchdogPlatformIOS

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        NSNotificationCenter *manager = [NSNotificationCenter defaultCenter];
        [manager addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [manager addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
        [manager addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [manager addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
        [manager addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIApplicationDelegate

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [MGWatchdog startFromPreviousConfiguration];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [MGWatchdog stop];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [MGWatchdog stop];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    [MGWatchdog stop];
}

- (void)keyboardDidShow:(NSNotification *)notification
{
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        if (!strongSelf)
        {
            return;
        }
        
        [MGWatchdog startFromPreviousConfiguration];
    });
}

- (BOOL)isApplicationInActiveState
{
    return [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive;
}

@end

#endif
