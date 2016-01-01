//
//  MGWatchdog.m
//  MGWatchdog
//
//  Created by Max Gordeev.
//

#import "MGWatchdogTargetSetup.h"
#import "MGWatchdog.h"
#import "MGMainRunloopObserver.h"
#import "MGWatchdogImpl.h"
#import "MGWatchdogPlatform.h"
#import "MGWatchdogPlatformIOS.h"
#import "MGWatchdogPlatformOSX.h"


@interface MGWatchdog ()

@property(nonatomic, assign) NSTimeInterval delay;
@property(nonatomic, copy) void (^handler)(void);
@property(nonatomic, assign) BOOL active;
@property(nonatomic, strong) MGWatchdogImpl *watchdog;
@property(nonatomic, strong) MGMainRunloopObserver *mainRunloopObserver;
@property(nonatomic, strong) id<MGWatchdogPlatform> platform;

#if OS_OBJECT_HAVE_OBJC_SUPPORT == 1
@property(nonatomic, strong) dispatch_queue_t syncQueue;
#else
@property(nonatomic, assign) dispatch_queue_t syncQueue;
#endif

@end


@implementation MGWatchdog

#pragma mark - API

+ (void)startWithDelay:(NSTimeInterval)delay handler:(void (^)(void))handler
{
	[[[self class] privateInstance] performStartWithDelay:delay handler:handler];
}

+ (void)stop
{
	[[[self class] privateInstance] performStop];
}

+ (void)skipCurrentLoop
{
	[[[self class] privateInstance] performSkipCurrentLoop];
}

#pragma mark - Implementation

- (void)performStartWithDelay:(NSTimeInterval)delay handler:(void (^)(void))handler
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    self.platform = [MGWatchdogPlatformIOS new];
#elif TARGET_OS_MAC
    self.platform = [MGWatchdogPlatformOSX new];
#endif
    
    if (![self.platform isApplicationInActiveState])
    {
        return;
    }

	self.delay = delay;
	self.handler = handler;

	[self setActive:true];

	[self.watchdog startWithDelay:self.delay handler:self.handler];
   
	__weak __typeof__(self) weakSelf = self;
	[self.mainRunloopObserver startWithBeginPingHandler:^{
		__strong __typeof__(weakSelf) strongSelf = weakSelf;
		if (!strongSelf)
		{
			return;
		}

		[strongSelf.watchdog beginPing];
	} endPingHandler:^{
		__strong __typeof__(weakSelf) strongSelf = weakSelf;
		if (!strongSelf)
		{
			return;
		}

		[strongSelf.watchdog endPing];
	}];
}

- (void)performStop
{
	if (![self.platform isApplicationInActiveState])
	{
		return;
	}

	[self.watchdog stop];
	[self.mainRunloopObserver stop];
}

- (void)performSkipCurrentLoop
{
	if ([self isActive] && [self.platform isApplicationInActiveState])
	{
		[self.watchdog stop];

		__weak __typeof__(self) weakSelf = self;
		dispatch_async(dispatch_get_main_queue(), ^{
			__strong __typeof__(weakSelf) strongSelf = weakSelf;
			if (!strongSelf)
			{
				return;
			}

			[strongSelf.watchdog startWithDelay:strongSelf.delay handler:strongSelf.handler];
		});
	}
}

+ (void)startFromPreviousConfiguration
{
    [[[self class] privateInstance] startFromPreviousConfiguration];
}

- (void)startFromPreviousConfiguration
{
    if ([self isActive])
    {
        NSParameterAssert(self.delay > 0);
        NSParameterAssert(self.handler);
        [self performStartWithDelay:self.delay handler:self.handler];
    }
}

- (BOOL)isActive
{
	__block bool result;
	__weak __typeof__(self) weakSelf = self;
	dispatch_sync(self.syncQueue, ^{
		__strong __typeof__(weakSelf) strongSelf = weakSelf;
		if (!strongSelf)
		{
			return;
		}

		result = strongSelf->_active;
	});

	return result;
}

- (void)setActive:(BOOL)active
{
	__weak __typeof__(self) weakSelf = self;
	dispatch_barrier_async(self.syncQueue, ^{
		__strong __typeof__(weakSelf) strongSelf = weakSelf;
		if (!strongSelf)
		{
			return;
		}

		if (active != strongSelf->_active)
		{
			strongSelf->_active = active;
		}
	});
}

#pragma mark - Lifecyrcle

+ (instancetype)privateInstance
{
	static MGWatchdog *instance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = [MGWatchdog new];
	});
	return instance;
}

- (instancetype)init
{
	self = [super init];
	if (self)
	{
		self.syncQueue = dispatch_queue_create(NULL, DISPATCH_QUEUE_CONCURRENT);
		self.active = false;
		self.watchdog = [MGWatchdogImpl new];
		self.mainRunloopObserver = [MGMainRunloopObserver new];
	}
	return self;
}

@end
