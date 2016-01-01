//
//  MGMainRunloopObserver.m
//  MGWatchdog
//
//  Created by Max Gordeev.
//

#import "MGMainRunloopObserver.h"


@interface MGMainRunloopObserver ()

//@property(nonatomic, assign) BOOL beginState;
@property(nonatomic, assign) CFRunLoopObserverRef runLoopObserver;
@property(nonatomic, copy) void (^beginPingHandler)(void);
@property(nonatomic, copy) void (^endPingHandler)(void);

#if OS_OBJECT_HAVE_OBJC_SUPPORT == 1
@property(nonatomic, strong) dispatch_queue_t syncQueue;
#else
@property(nonatomic, assign) dispatch_queue_t syncQueue;
#endif

@end


@implementation MGMainRunloopObserver

- (instancetype)init
{
	self = [super init];
	if (self)
	{
		self.syncQueue = dispatch_queue_create(NULL, DISPATCH_QUEUE_CONCURRENT);
	}
	return self;
}

- (void)startWithBeginPingHandler:(void (^)(void))beginPingHandler endPingHandler:(void (^)(void))endPingHandler
{
	NSParameterAssert(beginPingHandler);
	NSParameterAssert(endPingHandler);

	__weak __typeof__(self) weakSelf = self;
	dispatch_sync(self.syncQueue, ^{
		__strong __typeof__(weakSelf) strongSelf = weakSelf;
		if (!strongSelf)
		{
			return;
		}

		if (strongSelf.runLoopObserver == NULL)
		{
            void (^runLoopObserverHandler)(CFRunLoopObserverRef observer, CFRunLoopActivity activity) = ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
                switch (activity)
                {
                    case kCFRunLoopBeforeTimers:
                    case kCFRunLoopBeforeSources:
                    case kCFRunLoopBeforeWaiting:
                    case kCFRunLoopAfterWaiting:
                        break;
                        
                    default:
                        return;
                }
                
				__strong __typeof__(weakSelf) strongSelf = weakSelf;
				if (!strongSelf)
				{
                    return;
                }
                
                dispatch_async(strongSelf.syncQueue, ^{
                    __strong __typeof__(weakSelf) strongSelf = weakSelf;
                    if (!strongSelf)
                    {
                        return;
                    }
                    
                    __typeof__(strongSelf.beginPingHandler) const beginPingHandler = strongSelf.beginPingHandler;
                    __typeof__(strongSelf.endPingHandler) const endPingHandler = strongSelf.endPingHandler;
                    
                    switch (activity)
                    {
                        case kCFRunLoopBeforeTimers:
                        {
//                            if (strongSelf.beginState)
//                            {
                                endPingHandler();
//                            }
                            
                            beginPingHandler();
                            
//                            strongSelf.beginState = true;
                            break;
                        }
                            
                        case kCFRunLoopBeforeSources:
                        {
//                            if (strongSelf.beginState)
//                            {
                                endPingHandler();
//                            }
                            
                            beginPingHandler();
                            
//                            strongSelf.beginState = true;
                            break;
                        }
                            
                        case kCFRunLoopBeforeWaiting:
                        {
//                            if (strongSelf.beginState)
//                            {
//                                strongSelf.beginState = false;
                                endPingHandler();
//                            }
                            break;
                        }
                            
                        case kCFRunLoopAfterWaiting:
                        {
//                            if (strongSelf.beginState)
//                            {
                                endPingHandler();
//                            }
                            
                            beginPingHandler();
                            
//                            strongSelf.beginState = true;
                            break;
                        }
                            
                        default:
                            break;
                    }
                });
            };

			static CFOptionFlags const runloopModes = kCFRunLoopAllActivities;
			CFRunLoopObserverRef runLoopObserver = CFRunLoopObserverCreateWithHandler(NULL, runloopModes, YES, 0, runLoopObserverHandler);

			if (runLoopObserver != NULL)
			{
				strongSelf.beginPingHandler = beginPingHandler;
				strongSelf.endPingHandler = endPingHandler;
				strongSelf.runLoopObserver = runLoopObserver;
				CFRunLoopAddObserver(CFRunLoopGetMain(), runLoopObserver, kCFRunLoopCommonModes);
			}
		}
	});
}

- (void)stop
{
	__weak __typeof__(self) weakSelf = self;
	dispatch_barrier_sync(self.syncQueue, ^{
		__strong __typeof__(weakSelf) strongSelf = weakSelf;
		if (!strongSelf)
		{
			return;
		}

		strongSelf.beginPingHandler = nil;
		strongSelf.endPingHandler = nil;

		if (strongSelf.runLoopObserver)
		{
			CFRunLoopRemoveObserver(CFRunLoopGetMain(), strongSelf.runLoopObserver, kCFRunLoopCommonModes);
			CFRelease(strongSelf->_runLoopObserver);
			strongSelf.runLoopObserver = nil;
		}
	});
}

@end
