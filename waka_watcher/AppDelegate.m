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

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
// Insert code here to initialize your application
#ifndef DEBUG
  PFMoveToApplicationsFolderIfNecessary();
#endif
  [DevMateKit sendTrackingReport:nil delegate:nil];
  [DevMateKit setupIssuesController:nil reportingUnhandledIssues:YES];
  [[SUUpdater sharedUpdater] setDelegate:self];
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

@end
