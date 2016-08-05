//
//  AppDelegate.m
//  waka_watcher
//
//  Created by Samuel DeVore on 1/1/16.
//  Copyright © 2016 Samuel DeVore. All rights reserved.
//

#import "AppDelegate.h"
#import "PFMoveApplication.h"

@interface AppDelegate ()
- (void)setupLogging;
- (void)setupDevkit;
- (void)setupSparkle;
- (void)loadUserDefaults;
@end

@implementation AppDelegate

+ (void)initialize {
    NSNumber *logLevel = [[NSUserDefaults standardUserDefaults] objectForKey:@"prefsLogLevel"];
    if (logLevel) {
        ddLogLevel = (DDLogLevel)[logLevel intValue];
    }
}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
// Insert code here to initialize your application
#ifndef DEBUG
    PFMoveToApplicationsFolderIfNecessary();
#endif
    [self setupDevkit];
    [self loadUserDefaults];
    [self setupLogging];
    [self setupSparkle];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}
- (IBAction)showFeedbackDialog:(id)sender {
    [DevMateKit showFeedbackDialog:nil inMode:DMFeedbackIndependentMode];
}

- (BOOL)updaterShouldCheckForBetaUpdates:(SUUpdater *)updater {
    return YES;
}

- (BOOL)isUpdaterInTestMode:(DM_SUUpdater *)updater {
    return YES;
}

#pragma mark initializeStates

- (void)setupDevkit {
    [DevMateKit sendTrackingReport:nil delegate:nil];
    [DevMateKit setupIssuesController:nil reportingUnhandledIssues:YES];
}

- (void)setupSparkle {
    [[SUUpdater sharedUpdater] setDelegate:self];
}
- (void)setupLogging {
    [DDLog addLogger:[DDTTYLogger sharedInstance]]; // TTY = Xcode console
    [DDLog addLogger:[DDASLLogger sharedInstance]]; // ASL = Apple System Logs
    XCDLumberjackNSLogger *logger = [XCDLumberjackNSLogger new];
    [DDLog addLogger:logger
           withLevel:DDLogLevelAll]; // normally DDLogLevelWarning | DDLogLevelErrorn
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    [[DDTTYLogger sharedInstance] setForegroundColor:[NSColor greenColor]
                                     backgroundColor:nil
                                             forFlag:DDLogFlagDebug];
    [[DDTTYLogger sharedInstance] setForegroundColor:[NSColor blueColor]
                                     backgroundColor:nil
                                             forFlag:DDLogFlagInfo];
    DDLogVerbose(@"Verbose");
    DDLogDebug(@"Debug");
    DDLogInfo(@"Info");
    DDLogWarn(@"Warn");
    DDLogError(@"Error");
}

- (void)loadUserDefaults {
    NSURL *defaultPrefsFile =
        [[NSBundle mainBundle] URLForResource:@"UserDefaults" withExtension:@"plist"];
    NSDictionary *defaultPrefs = [NSDictionary dictionaryWithContentsOfURL:defaultPrefsFile];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultPrefs];
}

@end
