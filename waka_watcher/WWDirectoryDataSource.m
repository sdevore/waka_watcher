//
//  WWDirectoryDataSource.m
//  waka_watcher
//
//  Created by Samuel DeVore on 7/15/16.
//  Copyright © 2016 Samuel DeVore. All rights reserved.
//

#import "MTEThreadsafeArray.h"
#import "WWDirectoryDataSource.h"
#import "WWDirectoryItem.h"

@interface WWDirectoryDataSource ()

@end

@implementation WWDirectoryDataSource
- (instancetype)init {
    self = [super init];
    if (self) {
        _children = [[MTEThreadsafeArray alloc] init];
    }
    return self;
}
- (NSUInteger)countOfChildren {
    if (nil != self.children) {
        return [self.children count];
    } else {
        return 0;
    }
}

- (NSIndexSet *)addURLs:(NSArray *)URLs withDelegate:(id)delegate {
    NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
    for (NSURL *url in URLs) {
        WWDirectoryItem *item = [[WWDirectoryItem alloc] initWithUrl:url];
        item.delegate = delegate;
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            [item loadChildren];
        });
        [self.children addObject:item];
        NSArray *children = [self.children array];
        [set addIndex:[children indexOfObject:item]];
    }
    return [[NSIndexSet alloc] initWithIndexSet:set];
}
#pragma mark NSOutlineViewDatasource

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    if (nil == item) {
        return [self.children count];
    } else {
        if ([item isKindOfClass:[WWDirectoryDataSource class]]) {
            return [[(WWDirectoryDataSource *)item children] count];
        } else {
            NSAssert([item isKindOfClass:[WWDirectoryDataSource class]],
                     @"item should be a Datasource item.");
            return 0;
        }
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    if ([item isKindOfClass:[WWDirectoryItem class]]) {
        if ([(WWDirectoryItem *)item isDirectory]) {
            return YES;
        } else {
            return NO;
        }
    }
    return NO;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    if (nil == item) {
        if ([self.children count] > index) {
            return [self.children objectAtIndex:index];
        }
    } else {
        WWDirectoryItem *directoryItem = item;
        if ([directoryItem.children count] > index) {
            return [directoryItem.children objectAtIndex:index];
        }
    }
    return nil;
}
@end
