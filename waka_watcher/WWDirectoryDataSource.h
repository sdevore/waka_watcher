//
//  WWDirectoryDataSource.h
//  waka_watcher
//
//  Created by Samuel DeVore on 7/15/16.
//  Copyright © 2016 Samuel DeVore. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class MTEThreadsafeArray;

@interface WWDirectoryDataSource : NSObject <NSOutlineViewDataSource>
@property (nullable) MTEThreadsafeArray *children;

- (nullable NSIndexSet *)addURLs:(nullable NSArray *)URLs withDelegate:(nullable id)delegate;
@end
