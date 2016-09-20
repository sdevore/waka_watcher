//
//  SCDURLResourceMatcher.h
//  waka_watcher
//
//  Created by Samuel DeVore on 8/15/16.
//  Copyright © 2016 Samuel DeVore. All rights reserved.
//

#import <OCHamcrest/HCDiagnosingMatcher.h>

@interface SCDURLResourceMatcher : HCDiagnosingMatcher



- (instancetype)initWithUrl:(NSURL *)url valueMatcher:(id <HCMatcher>)valueMatcher;

@end


FOUNDATION_EXPORT id sameResource(NSURL *url, id valueMatcher);