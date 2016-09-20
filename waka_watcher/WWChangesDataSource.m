//
//  WWChangesDataSourace.m
//  waka_watcher
//
//  Created by Samuel DeVore on 9/7/16.
//  Copyright © 2016 Samuel DeVore. All rights reserved.
//

#import "WWChangesDataSource.h"

#import "MTEThreadsafeArray.h"
#import "WWDirectoryItem.h"

@implementation WWChangesGroup
- (id)copyWithZone:(NSZone *)zone {
    WWChangesGroup *new = [ WWChangesGroup new ];
    new.string = [ self.string copyWithZone : zone ];
    new.icon = [ self.icon copyWithZone : zone ];
    return new;
}
- (NSString *)description {
    return self.string;
}

@end

@interface WWChangesDataSource ()
@property (nullable) MTEThreadsafeArray *_added;
@property (nullable) MTEThreadsafeArray *_modified;
@property (nullable) MTEThreadsafeArray *_deleted;

@end
@implementation WWChangesDataSource
- (instancetype)init {
    self = [super init];
    if (self) {
        __added = [MTEThreadsafeArray new];
        __modified = [MTEThreadsafeArray new];
        __deleted = [MTEThreadsafeArray new];
    }
    return self;
}
- (BOOL)isGroup:(NSInteger)row {
    if (0 <= row) {
        return YES;
    }
    row = row - 1;
    if (row < [self._added count]) {
        return NO;
    }
    row = row - [self._added count];
    if (0 == row) {
        return YES;
    }
    row = row - 1;
    if (row < [self._modified count]) {
        return NO;
    }
    row = row - [self._modified count];
    if (0 == row) {
        return YES;
    }
    row = row - 1;
    if (row < [self._deleted count]) {
        return NO;
    }
    return NO;
}
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    NSInteger result = 0;
    if (nil != self._added) {
        result += 1 + self._added.count;
    }
    if (nil != self._modified) {
        result += 1 + self._modified.count;
    }
    if (nil != self._deleted) {
        result += 1 + self._deleted.count;
    }
    return result;
}

- (id)tableView:(NSTableView *)tableView
    objectValueForTableColumn:(NSTableColumn *)tableColumn
                          row:(NSInteger)row {
    if (0 == row) {
        WWChangesGroup *result = [WWChangesGroup new];
        result.string = NSLocalizedString(@"Added Files", @"Group header for list of added files");
        result.count = [self._added count];
        return result;
    }
    row = row - 1;
    if (row < [self._added count]) {
        return [self._added objectAtIndex:row];
    }
    row = row - [self._added count];
    if (0 == row) {
        WWChangesGroup *result = [WWChangesGroup new];
        result.string =
            NSLocalizedString(@"Modified Files", @"Group header for list of modified files");
        result.count = [self._modified count];
        return result;
    }
    row = row - 1;
    if (row < [self._modified count]) {
        return [self._modified objectAtIndex:row];
    }
    row = row - [self._modified count];
    if (0 == row) {
        WWChangesGroup *result = [WWChangesGroup new];
        result.string =
            NSLocalizedString(@"Deleted Files", @"Group header for list of deleted files");
        result.count = [self._deleted count];
        return result;
    }
    row = row - 1;
    if (row < [self._deleted count]) {
        return [self._deleted objectAtIndex:row];
    }
    return nil;
}
@end
