//
//  WWChangesDataSourace.h
//  waka_watcher
//
//  Created by Samuel DeVore on 9/7/16.
//  Copyright © 2016 Samuel DeVore. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class MTEThreadsafeArray;

@protocol WWChangesDataSourceProtocol <NSTableViewDataSource>

@end

@interface WWChangesGroup : NSObject <NSCopying>
@property (nullable) NSImage *icon;
@property (nullable) NSString *string;
@property (assign) NSInteger count;
@end

@interface WWChangesDataSource : NSObject <WWChangesDataSourceProtocol>
@property (weak) id<WWChangesDataSourceProtocol> _Nullable delegate;

- (BOOL)isGroup:(NSInteger)row;
- (nullable id)changeAtIndex:(NSInteger)row;
- (void)addedItems:(nonnull NSArray *)added;
- (void)modifiedItems:(nonnull NSArray *)modified;
- (void)deletedItems:(nonnull NSArray *)deleted;

- (nullable NSDictionary *)getChanges:(BOOL)shouldFlush;

@end
