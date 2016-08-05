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

- (instancetype)initWithUrl:(NSURL *)url withProject:(nullable NSString *)projectName {
    self = [super init];
    if (self) {
        if (nil != url) {
            _url = [url copy];
            _path = [[url path] copy];

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
        }
        _project = projectName;
    }
    return self;
}

- (instancetype)initWithUrl:(NSURL *)url {
    return [self initWithUrl:url withProject:nil];
}

- (id)copyWithZone:(NSZone *)zone {
    WWDirectoryItem *copy = [[WWDirectoryItem alloc] initWithUrl:self.url withProject:self.project];

    if (self.url == nil) {
        copy.path = _path;
        copy.lastChange = _lastChange;
        copy.created = _created;
        copy.modified = _modified;
        copy.icon = _icon;
        copy.isDirectory = _isDirectory;
        copy.project = _project;
        copy.delegate = _delegate;
    }
    return copy;
}

- (NSString *)fileName {
    if (nil != self.url) {
        return [self.url lastPathComponent];
    } else {
        return @"";
    }
}

- (NSDate *)created {
    if (nil != self.url) {
        @synchronized(self) {
            if (nil == _created) {
                NSDate *fileDate;
                NSError *error;
                [self.url getResourceValue:&fileDate forKey:NSURLCreationDateKey error:&error];
                if (!error) {
                    _created = [fileDate copy];
                }
            }
        }
        return _created;
    } else {
        return nil;
    }
}

- (NSDate *)modified {
    if (nil != self.url) {
        @synchronized(self) {
            if (nil == _modified) {
                NSDate *fileDate;
                NSError *error;
                [self.url getResourceValue:&fileDate
                                    forKey:NSURLContentModificationDateKey
                                     error:&error];
                if (!error) {
                    _modified = [fileDate copy];
                }
            }
        }
        return _modified;
    } else {
        return nil;
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
            self.changeWatcher = [[CDEvents alloc]
                initWithURLs:[NSArray arrayWithObject:self.url]
                       block:^(CDEvents *watcher, CDEvent *event) {
                           DDLogInfo(@"[Block] URLWatcher: %@\nEvent: %@", watcher, event);
                       }];
            DDLogInfo(@"-[CDEventsTestAppController run]:\n%@\n------\n%@", self.changeWatcher,
                      [self.changeWatcher streamDescription]);
        }
    } else {
        self.changeWatcher = nil;
    }
}

- (void)loadChildren {
    if (!self.isDirectory) {
        return;
    }
    self.isLoading = YES;
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
        WWDirectoryItem *item = [[WWDirectoryItem alloc] initWithUrl:url withProject:self.project];
        [self.children addObject:item];
        if (item.isDirectory) {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^{
                [item loadChildren];
            });
        }
    }
    self.isLoading = NO;
}

- (NSDictionary *)directoryChanges:(BOOL)deep {
    NSMutableDictionary *changes = [NSMutableDictionary dictionaryWithCapacity:3];
    NSMutableArray *add = [NSMutableArray array];
    NSMutableArray *modified = [NSMutableArray array];
    NSMutableArray *delete = [NSMutableArray array];
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
                [self.url getResourceValue:&fileDate
                                    forKey:NSURLContentModificationDateKey
                                     error:&error];
                if (!error) {
                    if (![fileDate isEqualToDate:item.modified]) {
                        isModfied = true;
                    }
                }
                break;
            }
        }
        if (isModfied) {
            WWDirectoryItem *modifiedItem =
                [[WWDirectoryItem alloc] initWithUrl:url withProject:self.project];
            [modified addObject:modifiedItem];
        } else if (!isFound) {
            WWDirectoryItem *addItem =
                [[WWDirectoryItem alloc] initWithUrl:url withProject:self.project];
            [add addObject:addItem];
        }
    }
    // find if items have been deleted
    for (WWDirectoryItem *item in childrenArray) {
        BOOL isFound = false;
        for (NSURL *url in currentContents) {
            if ([item.url isEqual:url]) {
                isFound = true;
                break;
            }
        }
        if (!isFound) {
            WWDirectoryItem *deleteItem = [WWDirectoryItem copy];
            [delete addObject:deleteItem];
        }
    }
    [changes setObject:[NSArray arrayWithArray:add] forKey:kAddDictionaryKey];
    [changes setObject:[NSArray arrayWithArray:modified] forKey:kModifiedDictionaryKey];
    [changes setObject:[NSArray arrayWithArray:delete] forKey:kDeleteDictionaryKey];
    return [NSDictionary dictionaryWithDictionary:changes];
}
@end
