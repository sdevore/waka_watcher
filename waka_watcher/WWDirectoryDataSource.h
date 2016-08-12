//
//  WWDirectoryDataSource.h
//  waka_watcher
//
//  Created by Samuel DeVore on 7/15/16.
//  Copyright © 2016 Samuel DeVore. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class MTEThreadsafeArray;
@class WWDirectoryDataSource;
@class WWDirectoryItem;

@protocol WWDirectoryDataSourceProtocol <NSOutlineViewDataSource>

@optional

#pragma mark - children changes
- (BOOL)directoryDataSource:(nullable WWDirectoryDataSource *)source
        addedItemsAtIndexes:(nonnull NSIndexSet *)indexSet;
- (BOOL)directoryDataSource:(nullable WWDirectoryDataSource *)source
      removedItemsAtIndexes:(nonnull NSIndexSet *)indexSet;
- (BOOL)directoryDataSource:(nullable WWDirectoryDataSource *)source
            moveItemAtIndex:(NSInteger)fromIndex
      toDirectoryDataSource:(nullable WWDirectoryDataSource *)destination
                    toIndex:(NSInteger)toIndex;

#pragma mark - loading
- (BOOL)directoryDataSource:(nullable WWDirectoryDataSource *)source
             shouldLoadItem:(nullable WWDirectoryItem *)item;
- (BOOL)directoryDataSource:(nullable WWDirectoryDataSource *)source
               willLoadItem:(nullable WWDirectoryItem *)item;
- (BOOL)directoryDataSource:(nullable WWDirectoryDataSource *)source
                didLoadItem:(nullable WWDirectoryItem *)item;

#pragma mark - updating contents
@end

@interface WWDirectoryDataSource : NSObject <NSOutlineViewDataSource>
@property (nullable) MTEThreadsafeArray *children;
@property (weak) id<WWDirectoryDataSourceProtocol> _Nullable delegate;
- (nullable NSIndexSet *)addURLs:(nullable NSArray *)URLs withDelegate:(nullable id)delegate;
@end
