//
//  waka_watcher_heartbeat.m
//  waka_watcher_heartbeat
//
//  Created by Samuel DeVore on 7/1/16.
//  Copyright © 2016 Samuel DeVore. All rights reserved.
//

#import "waka_watcher_heartbeat.h"

static NSString *VERSION = @"2.0.9";
static NSString *XCODE_VERSION = nil;
static NSString *XCODE_BUILD = nil;
static NSString *WAKATIME_CLI = @"Library/Application "
                                @"Support/Developer/Shared/Xcode/Plug-ins/"
                                @"WakaTime.xcplugin/Contents/Resources/"
                                @"wakatime-master/wakatime/cli.py";
static NSString *CONFIG_FILE = @".wakatime.cfg";

@implementation waka_watcher_heartbeat

// This implements the example protocol. Replace the body of this class with the
// implementation of this service's protocol.
- (void)upperCaseString:(NSString *)aString
              withReply:(void (^)(NSString *))reply {
  NSString *response = [aString uppercaseString];
  reply(response);
}

- (void)sendHeartbeat:(NSURL *)aURL withReply:(void (^)(NSString *))reply {
  NSTask *task = [[NSTask alloc] init];
  [task setLaunchPath:@"/usr/bin/python"];
  NSBundle *xpcBundle = [NSBundle mainBundle];
  NSURL *bundleURL = [xpcBundle URLForResource:@"cli"
                                 withExtension:@"py"
                                  subdirectory:@"wakatime"];

  DDLogVerbose(@"path: %@", bundleURL);
  NSMutableArray *arguments = [NSMutableArray array];
  [arguments addObject:[NSHomeDirectory()
                           stringByAppendingPathComponent:WAKATIME_CLI]];
  [arguments addObject:@"--file"];
  [arguments addObject:aURL.absoluteString];
  [arguments addObject:@"--plugin"];
  [arguments
      addObject:[NSString stringWithFormat:@"xcode/%@-%@ xcode-wakatime/%@",
                                           XCODE_VERSION, XCODE_BUILD,
                                           VERSION]];

  [arguments addObject:@"--write"];
  [task setArguments:arguments];
  [task launch];
}

@end
