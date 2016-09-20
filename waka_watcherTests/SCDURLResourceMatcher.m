//
//  SCDURLResourceMatcher.m
//  waka_watcher
//
//  Created by Samuel DeVore on 8/15/16.
//  Copyright © 2016 Samuel DeVore. All rights reserved.
//

#import "SCDURLResourceMatcher.h"
#import <OCHamcrest/HCRequireNonNilObject.h>
#import <OCHamcrest/HCWrapInMatcher.h>

@interface SCDURLResourceMatcher ()
@property (nonatomic, copy, readonly) NSURL *url;
@property (nonatomic, readonly) id <HCMatcher> valueMatcher;
@end

@implementation SCDURLResourceMatcher


- (instancetype)initWithUrl:(NSURL *)url valueMatcher:(id <HCMatcher>)valueMatcher
{
    self = [super init];
    if (self)
    {
        _url = [url copy];
        _valueMatcher = valueMatcher;
    }
    return self;
}

- (BOOL)matches:(id)item
{
    return NO;
}

- (void)describeTo:(id <HCDescription>)description
{
}
@end


id sameResource(NSURL *url, id valueMatcher)
{
    HCRequireNonNilObject(url);
    HCRequireNonNilObject(valueMatcher);
    return [[SCDURLResourceMatcher alloc] initWithUrl:url valueMatcher:HCWrapInMatcher(valueMatcher)];
}