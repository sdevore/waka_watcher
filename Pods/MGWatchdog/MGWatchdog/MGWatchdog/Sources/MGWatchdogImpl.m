//
//  MGWatchdogImpl.m
//  MGWatchdog
//
//  Created by Max Gordeev.
//

#import "MGWatchdogImpl.h"


@interface MGWatchdogImpl ()

@property(nonatomic, assign) NSTimeInterval delay;
@property(nonatomic, copy) void (^handler)(void);
@property(nonatomic, strong) NSObject *pingGuard;

#if OS_OBJECT_HAVE_OBJC_SUPPORT == 1
@property(nonatomic, strong) dispatch_queue_t watchdogQueue;
#else
@property(nonatomic, assign) dispatch_queue_t watchdogQueue;
#endif

@end


@implementation MGWatchdogImpl

- (instancetype)init
{
	self = [super init];
	if (self)
	{
		self.watchdogQueue = dispatch_queue_create(NULL, DISPATCH_QUEUE_SERIAL);
	}
	return self;
}

#pragma mark - API

- (void)startWithDelay:(NSTimeInterval)delay handler:(void (^)(void))handler
{
	NSParameterAssert(delay > 0);
	NSParameterAssert(handler);

	self.delay = delay;

	__weak __typeof__(self) weakSelf = self;
	dispatch_sync(self.watchdogQueue, ^{
		__strong __typeof__(weakSelf) strongSelf = weakSelf;
		if (!strongSelf)
		{
			return;
		}

		strongSelf.handler = handler;
	});
}

- (void)stop
{
	[self endPing];
}

- (void)beginPing
{
	__weak __typeof__(self) weakSelf = self;

	NSObject *pingGuard = [NSObject new];

	dispatch_async(self.watchdogQueue, ^{
		__strong __typeof__(weakSelf) strongSelf = weakSelf;
		if (!strongSelf)
		{
			return;
		}

		strongSelf.pingGuard = pingGuard;
	});

	__weak __typeof__(pingGuard) weakPingGuard = pingGuard;
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (self.delay * NSEC_PER_SEC)), self.watchdogQueue, ^{
		__strong __typeof__(weakPingGuard) strongPingGuard = weakPingGuard;
		if (!strongPingGuard)
		{
			return;
		}

		__strong __typeof__(weakSelf) strongSelf = weakSelf;
		if (!strongSelf)
		{
			return;
		}

		strongSelf.handler();
	});
}

- (void)endPing
{
	__weak __typeof__(self) weakSelf = self;
	dispatch_async(self.watchdogQueue, ^{
		__strong __typeof__(weakSelf) strongSelf = weakSelf;
		if (!strongSelf)
		{
			return;
		}

		strongSelf.pingGuard = nil;
	});
}

@end
