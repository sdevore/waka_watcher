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
        NSError *error;
        WWDirectoryItem *item = [[WWDirectoryItem alloc] initWithUrl:url];
        if (item.isDirectory) {
            NSURL *wakatimeProject;
            wakatimeProject = [item.url URLByAppendingPathComponent:@".wakatime-project"];
            if ([wakatimeProject checkResourceIsReachableAndReturnError:&error] == NO) {
                // no default project defining file
            } else {
                NSError *error = nil;
                NSStringEncoding encoding;
                NSString *wakatimeProjectContents =
                    [NSString stringWithContentsOfURL:wakatimeProject
                                         usedEncoding:&encoding
                                                error:&error];
                if (nil != wakatimeProjectContents) {
                    wakatimeProjectContents = [wakatimeProjectContents
                        stringByTrimmingCharactersInSet:[NSCharacterSet
                                                            whitespaceAndNewlineCharacterSet]];
                    [item setProject:wakatimeProjectContents];
                }
            }
        }
        item.delegate = delegate;
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            BOOL shouldLoad = true;
            if (nil != self.delegate &&
                [self.delegate respondsToSelector:@selector(directoryDataSource:shouldLoadItem:)]) {
                if (![self.delegate directoryDataSource:self shouldLoadItem:item]) {
                    return;
                }
            }
            if (nil != self.delegate &&
                [self.delegate respondsToSelector:@selector(directoryDataSource:willLoadItem:)]) {
                [self.delegate directoryDataSource:self willLoadItem:item];
            }
            if (shouldLoad) {
                [item loadChildren:YES async:YES];
                if (nil != self.delegate &&
                    [self.delegate
                        respondsToSelector:@selector(directoryDataSource:didLoadItem:)]) {
                    [self.delegate directoryDataSource:self didLoadItem:item];
                }
            }
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
