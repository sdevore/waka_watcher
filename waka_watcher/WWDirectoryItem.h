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
@property (nullable) NSString *project;
@property (nullable) NSString *language;
@property (atomic, assign) BOOL isLoading;
@property (assign, nonatomic) BOOL watching;

- (nonnull instancetype)initWithUrl:(nonnull NSURL *)url
                           inParent:(nullable WWDirectoryItem *)parent
                        withProject:(nullable NSString *)projectName;

- (nonnull instancetype)initWithUrl:(nonnull NSURL *)url
                           inParent:(nullable WWDirectoryItem *)parent;
- (nonnull instancetype)initWithUrl:(nonnull NSURL *)url;
- (nullable NSString *)fileName;
- (BOOL)isModified;
/**
 *  updates many of the properties of the item
 */
- (void)update;

/**
 *  Loads the children of the currently selected object, if a delegate is set and the delegate
 * adopts the WWDirectoryDataSourceProtocol those methods will be called on the same thread that
 * loadChildren:async: is called on
 *
 *  @param deep  if the each child shall be loaded as well
 *  @param async if true and deep is true then loading of children will happen asyncronously
 */
- (void)loadChildren:(BOOL)deep async:(BOOL)async;

/**
 *  update the children of the current WWDirectoryItem, if a delegate is set and the delegate adopts
 * the WWDirectoryDataSourceProtocol those methods will be called on the same thread that
 * updateChildren was called on
 *
 *  @param deep  if the each child shall be updateing as well
 *  @param async if true and deep is true then updating of children will happen asyncronously
 */
- (void)updateChildren:(BOOL)deep async:(BOOL)async;

@end
