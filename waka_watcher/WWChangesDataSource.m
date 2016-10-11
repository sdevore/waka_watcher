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
#import "NSURL+SCD.h"
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

-(void)addedItems:(NSArray *)added {
    NSMutableIndexSet *addedSet = [NSMutableIndexSet new];
    NSMutableArray *addedArray = [NSMutableArray new];
    NSMutableIndexSet *modifiedSet = [NSMutableIndexSet new];
    NSMutableArray *modifiedArray = [NSMutableArray new];
    for (WWDirectoryItem *addedItem in added) {
        BOOL found = NO;
        NSArray *array = __added.array;
        for (WWDirectoryItem *existing in array) {
            if ([existing.url scd_equalTo:addedItem.url]) {
                [existing update];
                found = true;
                [modifiedArray addObject:existing];
                break;
            }
        }
        if (!found) {
            [addedArray addObject:addedItem];
            [__added addObject:addedItem];
        }
    }
    if ([addedArray count] > 0) {
        if ([self.delegate respondsToSelector:@selector(changeDataSource:addedItems:atIndexes:)]) {
            for (WWDirectoryItem *item in addedArray) {
                [addedSet addIndex:[__added.array indexOfObject:item]];
            }
            [self.delegate changeDataSource:self addedItems:addedArray atIndexes:addedSet];
        }
    }
    if ([modifiedArray count] > 0) {
        if ([self.delegate respondsToSelector:@selector(changeDataSource:modifiedItems:atIndexes:)]) {
            for (WWDirectoryItem *item in modifiedArray) {
                [modifiedSet addIndex:[__added.array indexOfObject:item]];
            }
            [self.delegate changeDataSource:self modifiedItems:addedArray atIndexes:addedSet];
        }
    }
}

-(NSDictionary *)getChanges:(BOOL)shouldFlush {
    NSDictionary *changes = @{
                              @"added" : [NSArray arrayWithArray:__added.array],
                              @"modified":[NSArray arrayWithArray:__modified.array],
                              @"deleted":[NSArray arrayWithArray:__deleted.array]
                              };
    if (shouldFlush) {
        __added = [MTEThreadsafeArray new];
        __modified = [MTEThreadsafeArray new];
        __deleted = [MTEThreadsafeArray new];
    }
    
    return changes;
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
