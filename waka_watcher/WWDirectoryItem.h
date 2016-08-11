//
//  WWDirectoryItem.h
//  waka_watcher
//
//  Created by Samuel DeVore on 7/19/16.
//  Copyright © 2016 Samuel DeVore. All rights reserved.
//

#import "CDEvent.h"
#import "CDEvents.h"
#import "WWDirectoryDataSource.h"

@class WWDirectoryItem;
@class CDEvent;
@class CDEvents;

extern NSString *__nonnull const kAddDictionaryKey;
extern NSString *__nonnull const kModifiedDictionaryKey;
extern NSString *__nonnull const kDeleteDictionaryKey;

@interface WWDirectoryItem : WWDirectoryDataSource <NSCopying>
@property (nullable, weak) WWDirectoryItem *parent;
@property (nullable, copy) NSURL *url;
@property (nonnull, copy) NSString *path; // incase the underlying file is deleted
@property (nullable, copy) NSString *lastChange;
@property (nullable, nonatomic) NSDate *created;
@property (nullable, nonatomic) NSDate *modified;
@property (nullable, nonatomic) NSImage *icon;
@property (assign) BOOL isDirectory;
@property (assign, nonatomic) BOOL shouldWatch;
@property (nullable) NSString *project;
@property (atomic, assign) BOOL isLoading;
@property (nullable) CDEvents *changeWatcher;

- (nonnull instancetype)initWithUrl:(nonnull NSURL *)url
                           inParent:(nullable WWDirectoryItem *)parent
                        withProject:(nullable NSString *)projectName;

- (nonnull instancetype)initWithUrl:(nonnull NSURL *)url
                           inParent:(nullable WWDirectoryItem *)parent;
- (nonnull instancetype)initWithUrl:(nonnull NSURL *)url;
- (nullable NSString *)fileName;

- (void)loadChildren;
- (void)updateChildren:(BOOL)deep;
- (nonnull NSDictionary *)directoryChanges:(BOOL)deep;
@end
