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

@protocol WWDirectoryItemProtocol <NSObject>
@optional
- (void)directoryItem:(nonnull WWDirectoryItem *)item
    childrenDidFinishLoading:(NSInteger)childCount;

- (void)directoryItem:(nonnull WWDirectoryItem *)item
    contentsDidChange:(nonnull NSIndexSet *)setOfChanges
          changeEvent:(nullable CDEvent *)event;
@end

@interface WWDirectoryItem : WWDirectoryDataSource <NSCopying>
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
@property (weak) id<WWDirectoryItemProtocol> _Nullable delegate;
@property (nullable) CDEvents *changeWatcher;

- (nonnull instancetype)initWithUrl:(nonnull NSURL *)url
                        withProject:(nullable NSString *)projectName;

- (nonnull instancetype)initWithUrl:(nonnull NSURL *)url;

- (nullable NSString *)fileName;

- (void)loadChildren;
- (nonnull NSDictionary *)directoryChanges:(BOOL)deep;
@end
