//
//  waka_watcher_heartbeat.h
//  waka_watcher_heartbeat
//
//  Created by Samuel DeVore on 7/1/16.
//  Copyright © 2016 Samuel DeVore. All rights reserved.
//

#import "waka_watcher_heartbeatProtocol.h"
#import <CocoaLumberjack/CocoaLumberjack.h>

// Log levels: off, error, warn, info, verbose
#import "XCDLumberjackNSLogger.h"
#import <Foundation/Foundation.h>
#ifdef DEBUG
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;
#else
static const DDLogLevel ddLogLevel = DDLogLevelWarning;
#endif
// This object implements the protocol which we have defined. It provides the
// actual behavior for the service. It is 'exported' by the service to make it
// available to the process hosting the service over an NSXPCConnection.
@interface waka_watcher_heartbeat : NSObject <waka_watcher_heartbeatProtocol>
@end
