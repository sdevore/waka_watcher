//
//  WWDirectoryItem.m
//  waka_watcher
//
//  Created by Samuel DeVore on 7/19/16.
//  Copyright © 2016 Samuel DeVore. All rights reserved.
//

#import "MTEThreadsafeArray.h"
#import "WWDirectoryItem.h"

NSString *const kAddDictionaryKey = @"add";
NSString *const kModifiedDictionaryKey = @"modified";
NSString *const kDeleteDictionaryKey = @"delete";

@implementation WWDirectoryItem

- (instancetype)initWithUrl:(NSURL *)url
                   inParent:(WWDirectoryItem *)parent
                withProject:(nullable NSString *)projectName {
    self = [super init];
    if (self) {
        if (nil != url) {
            _url = [url copy];
            _path = [[url path] copy];
            _parent = parent;
            NSNumber *isDirectory;
            NSError *error;
            _shouldWatch = NO;
            BOOL success =
                [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:&error];
            if (success && [isDirectory boolValue]) {
                _isDirectory = YES;
            } else {
                if (!success) {
                    NSLog(@"Error reading %@ isDirectory: %@", self.url,
                          error.localizedDescription);
                }
                _isDirectory = NO;
            }
            NSDate *fileDate;

            if ([self.url getResourceValue:&fileDate
                                    forKey:NSURLContentModificationDateKey
                                     error:&error]) {
                _modified = [fileDate copy];
            }
            error = nil;
            if ([self.url getResourceValue:&fileDate forKey:NSURLCreationDateKey error:&error]) {
                _created = [fileDate copy];
            }
        }
        _project = projectName;
    }
    return self;
}

- (instancetype)initWithUrl:(NSURL *)url inParent:(WWDirectoryItem *)parent {
    return [self initWithUrl:url inParent:parent withProject:nil];
}

- (instancetype)initWithUrl:(NSURL *)url {
    return [self initWithUrl:url inParent:nil withProject:nil];
}

- (id)copyWithZone:(NSZone *)zone {
    WWDirectoryItem *copy = [[WWDirectoryItem alloc] initWithUrl:self.url
                                                        inParent:self.parent
                                                     withProject:self.project];
    copy.delegate = self.delegate;
    if (self.url == nil) {
        copy.path = _path;
        copy.lastChange = _lastChange;
        copy.created = _created;
        copy.modified = _modified;
        copy.icon = _icon;
        copy.isDirectory = _isDirectory;
        copy.project = _project;
    }
    return copy;
}

- (NSString *)description {
    return self.path;
}

- (NSString *)fileName {
    if (nil != self.url) {
        return [self.url lastPathComponent];
    } else {
        return @"";
    }
}

- (NSImage *)icon {
    if (nil != self.url) {
        @synchronized(self) {
            if (_icon == nil) {
                NSImage *fileIcon;
                NSError *error;
                [self.url getResourceValue:&fileIcon forKey:NSURLCustomIconKey error:&error];
                if (!error) {
                    if (nil != _icon) {
                        _icon = [fileIcon copy];
                    } else {
                        [self.url getResourceValue:&fileIcon
                                            forKey:NSURLEffectiveIconKey
                                             error:&error];
                        if (!error) {
                            if (nil != _icon) {
                                _icon = [fileIcon copy];
                            } else {
                                NSWorkspace *ws = [NSWorkspace sharedWorkspace];
                                _icon = [ws iconForFile:[self.url path]];
                                if (nil != _icon) {
                                    _icon = [fileIcon copy];
                                }
                            }
                        }
                    }
                }
            }
        }
        return _icon;
    } else {
        return nil;
    }
}

- (void)setShouldWatch:(BOOL)shouldWatch {
    if (_shouldWatch == shouldWatch) {
        return;
    }
    _shouldWatch = shouldWatch;
    if (shouldWatch) {
        if (nil == self.changeWatcher) {
            __weak typeof(self) weakSelf = self;
            
            self.changeWatcher = [[CDEvents alloc]
                initWithURLs:[NSArray arrayWithObject:self.url]
                       block:^(CDEvents *watcher, CDEvent *event) {
                           DDLogInfo(@"[Block] URLWatcher: %@\nEvent: %@", watcher, event);
                           if (nil != weakSelf) {
                               [weakSelf updateChildren:NO async:NO];
                           }
                       }];
            DDLogInfo(@"-[CDEventsTestAppController run]:\n%@\n------\n%@", self.changeWatcher,
                      [self.changeWatcher streamDescription]);
        }
    } else {
        self.changeWatcher = nil;
    }
}

- (void)update {
}

- (void)loadChildren:(BOOL)deep async:(BOOL)async {
    if (!self.isDirectory) {
        return;
    }
    if (nil != self.delegate &&
        [self.delegate respondsToSelector:@selector(directoryDataSource:shouldLoadItem:)]) {
        if (![self.delegate directoryDataSource:self.parent shouldLoadItem:self]) {
            return;
        }
    }
    self.isLoading = YES;
    if (nil != self.delegate &&
        [self.delegate respondsToSelector:@selector(directoryDataSource:willLoadItem:)]) {
        [self.delegate directoryDataSource:self.parent willLoadItem:self];
    }
    NSError *error = nil;
    NSArray *properties = [NSArray
        arrayWithObjects:NSURLLocalizedNameKey, NSURLCreationDateKey,
                         NSURLLocalizedTypeDescriptionKey, NSURLContentModificationDateKey,
                         NSURLCustomIconKey, NSURLEffectiveIconKey, NSURLIsDirectoryKey, nil];

    NSArray *array = [[NSFileManager defaultManager]
          contentsOfDirectoryAtURL:self.url
        includingPropertiesForKeys:properties
                           options:(NSDirectoryEnumerationSkipsHiddenFiles)
                             error:&error];
    if (array == nil) {
        // Handle the error
    }
    for (NSURL *url in array) {
        WWDirectoryItem *item =
            [[WWDirectoryItem alloc] initWithUrl:url inParent:self withProject:self.project];
        item.delegate = self.delegate;
        [self.children addObject:item];
        if (nil != self.delegate &&
            [self.delegate
                respondsToSelector:@selector(directoryDataSource:addedItems:atIndexes:)]) {
        }
        if (item.isDirectory && deep) {
            if (async) {
                dispatch_queue_t queue =
                    dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                dispatch_async(queue, ^{
                    [item loadChildren:deep async:YES];
                });
            } else {
                [item loadChildren:deep async:NO];
            }
        }
    }
    self.isLoading = NO;
    if (nil != self.delegate &&
        [self.delegate respondsToSelector:@selector(directoryDataSource:didLoadItem:)]) {
        [self.delegate directoryDataSource:self.parent didLoadItem:self];
    }
    if (nil != self.delegate &&
        [self respondsToSelector:@selector(directoryDataSource:addedItems:atIndexes:)]) {
        NSArray *children = [self.children array];
        NSIndexSet *indexSet =
            [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, children.count - 1)];
        [self.delegate directoryDataSource:self addedItems:children atIndexes:indexSet];
    }
}

- (void)updateChildren:(BOOL)deep async:(BOOL)async {
    NSMutableArray *add = [NSMutableArray array];
    NSMutableArray *modified = [NSMutableArray array];
    NSMutableArray *deletes = [NSMutableArray array];
    NSError *error;
    // find changed and new items in the directory
    NSArray *properties = [NSArray
        arrayWithObjects:NSURLLocalizedNameKey, NSURLCreationDateKey,
                         NSURLLocalizedTypeDescriptionKey, NSURLContentModificationDateKey,
                         NSURLCustomIconKey, NSURLEffectiveIconKey, NSURLIsDirectoryKey, nil];

    NSArray *currentContents = [[NSFileManager defaultManager]
          contentsOfDirectoryAtURL:self.url
        includingPropertiesForKeys:properties
                           options:(NSDirectoryEnumerationSkipsHiddenFiles)
                             error:&error];
    NSArray *childrenArray = [self.children array];
    for (NSURL *url in currentContents) {
        BOOL isFound = false;
        BOOL isModfied = false;
        for (WWDirectoryItem *item in childrenArray) {
            if ([item.url isEqualTo:url]) {
                isFound = true;
                NSDate *fileDate;
                NSError *error;
                ;
                [self.url getResourceValue:&fileDate
                                    forKey:NSURLContentModificationDateKey
                                     error:&error];
                if (!error) {
                    if (![fileDate isEqualToDate:item.modified]) {
                        isModfied = true;
                        [item update];
                        [modified addObject:item];
                    }
                }
                if (deep && item.isDirectory) {
                    if (async) {
                        dispatch_queue_t queue =
                            dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                        dispatch_async(queue, ^{
                            [item loadChildren:deep async:YES];
                        });
                    } else {
                        [item loadChildren:deep async:NO];
                    }
                }
                break;
            }
        }
        if (!isFound) {
            WWDirectoryItem *addItem =
                [[WWDirectoryItem alloc] initWithUrl:url inParent:self withProject:self.project];
            [add addObject:addItem];
        }
    }
    if (nil != modified && 0 < modified.count) {
        if (nil != self.delegate &&
            [self.delegate
                respondsToSelector:@selector(directoryDataSource:modifiedItems:atIndexes:)]) {
            childrenArray = [self.children array];
            NSMutableIndexSet *modifiedSet = [NSMutableIndexSet new];
            for (WWDirectoryItem *modifiedItem in modified) {
                [modifiedSet addIndex:[childrenArray indexOfObject:modifiedItem]];
            }
            [self.delegate directoryDataSource:self modifiedItems:modified atIndexes:modifiedSet];
        }
    }
    if (nil != add && 0 < add.count) {
        [self.children addObjects:add];
        if (nil != self.delegate &&
            [self.delegate
                respondsToSelector:@selector(directoryDataSource:addedItems:atIndexes:)]) {
            childrenArray = [self.children array];
            NSMutableIndexSet *addSet = [NSMutableIndexSet new];
            for (WWDirectoryItem *addItem in add) {
                [addSet addIndex:[childrenArray indexOfObject:addItem]];
            }
            [self.delegate directoryDataSource:self addedItems:add atIndexes:addSet];
        }
    }

    // handle deletes
    // find if items have been deleted
    NSFileManager *fileManager = [NSFileManager defaultManager];
    for (WWDirectoryItem *item in childrenArray) {
        if (![fileManager fileExistsAtPath:item.path]) {
            // we use the path because url can become nil if doesn't exist and this is a bit safer
            WWDirectoryItem *deleteItem = [item copy];
            [deletes addObject:deleteItem];
        }
    }
    if (nil != deletes) {
        NSMutableIndexSet *deletedIndexSet = [NSMutableIndexSet new];
        for (WWDirectoryItem *deletedItem in deletes) {
            NSArray *children = [self.children array];
            for (NSInteger ii = children.count - 1; ii >= 0; ii--) {
                WWDirectoryItem *item = [children objectAtIndex:ii];
                if ([[item.path lastPathComponent]
                        isEqualToString:[deletedItem.path lastPathComponent]]) {
                    [self.children removeObject:item];
                    [deletedIndexSet addIndex:ii];
                }
            }
        }
        if ([deletedIndexSet count] > 0 && nil != self.delegate &&
            [self.delegate
                respondsToSelector:@selector(directoryDataSource:removedItems:atIndexes:)]) {
            [self.delegate directoryDataSource:self removedItems:deletes atIndexes:deletedIndexSet];
        }
    }
}

@end
