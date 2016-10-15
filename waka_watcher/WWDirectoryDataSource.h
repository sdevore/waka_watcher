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
- (void)directoryDataSource:(nullable WWDirectoryDataSource *)source
                 addedItems:(nonnull NSArray *)items
                  atIndexes:(nonnull NSIndexSet *)indexSet;
- (void)directoryDataSource:(nullable WWDirectoryDataSource *)source
              modifiedItems:(nonnull NSArray *)items
                  atIndexes:(nonnull NSIndexSet *)indexSet;
- (void)directoryDataSource:(nullable WWDirectoryDataSource *)source
               removedItems:(nonnull NSArray *)items
                  atIndexes:(nonnull NSIndexSet *)indexSet;
- (void)directoryDataSource:(nullable WWDirectoryDataSource *)source
                   moveItem:(nonnull WWDirectoryItem *)item
                    atIndex:(NSInteger)fromIndex
                     toItem:(nullable WWDirectoryItem *)destination
                    toIndex:(NSInteger)toIndex;

#pragma mark - loading
- (BOOL)directoryDataSource:(nullable WWDirectoryDataSource *)source
             shouldLoadItem:(nullable WWDirectoryItem *)item;
- (void)directoryDataSource:(nullable WWDirectoryDataSource *)source
               willLoadItem:(nullable WWDirectoryItem *)item;
- (void)directoryDataSource:(nullable WWDirectoryDataSource *)source
                didLoadItem:(nullable WWDirectoryItem *)item;

#pragma mark - updating contents

- (void)updatedDirectoryItem:(nullable WWDirectoryItem *)item addedChildren:(nonnull NSArray *)children;

- (void)updatedDirectoryItem:(nullable WWDirectoryItem *)item modifiedChildren:(nonnull NSArray *)children;

- (void)updatedDirectoryItem:(nullable WWDirectoryItem *)item deletedChildren:(nonnull NSArray *)children;
@end

@interface WWDirectoryDataSource : NSObject <NSOutlineViewDataSource>
@property (nullable) MTEThreadsafeArray *children;
@property (weak) id<WWDirectoryDataSourceProtocol> _Nullable delegate;


- (nullable NSIndexSet *)addURLs:(nullable NSArray *)URLs withDelegate:(nullable id)delegate;

- (void)setWatching:(BOOL)shouldWatch;
- (NSInteger)watching;
@end
