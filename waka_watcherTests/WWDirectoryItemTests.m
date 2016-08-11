//
//  WWDirectoryItemTests.m
//  waka_watcher
//
//  Created by Samuel DeVore on 8/2/16.
//  Copyright © 2016 Samuel DeVore. All rights reserved.
//

#import "SCDTestCase.h"
#import "WWDirectoryItem.h"
#import <OCMock/OCMock.h>

@interface WWDirectoryItemTests : SCDTestCase {
    NSURL *_testFolder;
    NSURL *_firstSubFolder;
    NSURL *_secondSubFolder;
    NSURL *_thirdSubFolder;
    NSURL *_fourthSubFolder;
    WWDirectoryItem *_testItem;
}
@end

@implementation WWDirectoryItemTests
- (BOOL)requireFilesystem {
    // Enable filesystem support. If enabled, a new temporary directory is
    // created prior and deleted after each individual test.
    return YES;
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each
    // test method in the class.
    _testFolder = [self createDirectory:@"WWDirectoryItemTests"];
    [self createFile:@"one.txt" withContent:nil insideDirectory:_testFolder];
    [self createFile:@"two.txt" withContent:nil insideDirectory:_testFolder];
    [self createFile:@"three.txt" withContent:nil insideDirectory:_testFolder];
    [self createFile:@"four.txt" withContent:nil insideDirectory:_testFolder];

    // create subfolders
    _firstSubFolder = [self createDirectory:@"First" insideDirectory:_testFolder];
    [self createFile:@"one.txt" withContent:nil insideDirectory:_firstSubFolder];
    [self createFile:@"two.txt" withContent:nil insideDirectory:_firstSubFolder];
    [self createFile:@"three.txt" withContent:nil insideDirectory:_firstSubFolder];
    [self createFile:@"four.txt" withContent:nil insideDirectory:_firstSubFolder];

    _secondSubFolder = [self createDirectory:@"Second" insideDirectory:_testFolder];
    [self createFile:@"one.txt" withContent:nil insideDirectory:_secondSubFolder];
    [self createFile:@"two.txt" withContent:nil insideDirectory:_secondSubFolder];
    [self createFile:@"three.txt" withContent:nil insideDirectory:_secondSubFolder];
    [self createFile:@"four.txt" withContent:nil insideDirectory:_secondSubFolder];

    _thirdSubFolder = [self createDirectory:@"Third" insideDirectory:_testFolder];
    [self createFile:@"one.txt" withContent:nil insideDirectory:_thirdSubFolder];
    [self createFile:@"two.txt" withContent:nil insideDirectory:_thirdSubFolder];
    [self createFile:@"three.txt" withContent:nil insideDirectory:_thirdSubFolder];
    [self createFile:@"four.txt" withContent:nil insideDirectory:_thirdSubFolder];

    _fourthSubFolder = [self createDirectory:@"Fourth" insideDirectory:_testFolder];
    [self createFile:@"one.txt" withContent:nil insideDirectory:_fourthSubFolder];
    [self createFile:@"two.txt" withContent:nil insideDirectory:_fourthSubFolder];
    [self createFile:@"three.txt" withContent:nil insideDirectory:_fourthSubFolder];
    [self createFile:@"four.txt" withContent:nil insideDirectory:_fourthSubFolder];

    _testItem = [[WWDirectoryItem alloc] initWithUrl:_testFolder];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each
    // test method in the class.
    _testItem = nil;
    [super tearDown];
}

- (void)testInitializers {
    NSURL *one = [_testFolder URLByAppendingPathComponent:@"one.txt"];
    XCTAssertNotNil(one);
    WWDirectoryItem *item = [[WWDirectoryItem alloc] initWithUrl:one];
    XCTAssertNotNil(item);
    XCTAssertNil(item.project);

    item = [[WWDirectoryItem alloc] initWithUrl:one inParent:NULL withProject:@"project"];
    XCTAssertEqualObjects(item.project, @"project");
}
- (void)testBasicAttributes {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the
    // correct results.
    NSURL *one = [_testFolder URLByAppendingPathComponent:@"one.txt"];
    XCTAssertNotNil(one);
    WWDirectoryItem *item = [[WWDirectoryItem alloc] initWithUrl:one];
    XCTAssertNotNil(item);
    XCTAssertEqualObjects(item.fileName, @"one.txt");
    XCTAssertNotNil(item.created);
    XCTAssertNotNil(item.modified);
    XCTAssertNotNil(item.icon);
}

- (void)testDirectoryChangesNone {
    WWDirectoryItem *item = [[WWDirectoryItem alloc] initWithUrl:_testFolder];
    [item loadChildren];
    XCTAssertNotNil(item, @"should not be nil");
    NSDictionary *changes = [item directoryChanges:NO];
    XCTAssertNotNil(changes, @"changes should not be nil");
    XCTAssertEqual([changes count], 3, @"should be three items although they may be empty");
    XCTAssertNotNil([changes objectForKey:kAddDictionaryKey], @"add object should exist");
    XCTAssertEqual([[changes objectForKey:kAddDictionaryKey] count], 0,
                   @"should be zero items although they may be empty");
    XCTAssertNotNil([changes objectForKey:kModifiedDictionaryKey], @"modified object should exist");
    XCTAssertEqual([[changes objectForKey:kModifiedDictionaryKey] count], 0,
                   @"should be zero items although they may be empty");
    XCTAssertNotNil([changes objectForKey:kDeleteDictionaryKey], @"delete object should exist");
    XCTAssertEqual([[changes objectForKey:kDeleteDictionaryKey] count], 0,
                   @"should be 0 items although they may be empty");
}

- (void)testDirectoryChangesAddFile {
    WWDirectoryItem *item = [[WWDirectoryItem alloc] initWithUrl:_testFolder];
    [item loadChildren];
    XCTAssertNotNil(item, @"should not be nil");
    NSURL *newURL = [self createFile:@"new.txt" withContent:nil insideDirectory:_testFolder];
    NSDictionary *changes = [item directoryChanges:NO];
    XCTAssertNotNil(changes, @"changes should not be nil");
    XCTAssertEqual([changes count], 3, @"should be three items although they may be empty");
    NSArray *add = [changes objectForKey:kAddDictionaryKey];
    XCTAssertNotNil(add, @"add object should exist");
    XCTAssertEqual([add count], 1, @"should be zero items although they may be empty");
    WWDirectoryItem *addedItem = [add objectAtIndex:0];
    XCTAssertNotNil(addedItem, @"add object should exist");
    XCTAssertTrue([self expected:newURL isEqualToActual:addedItem.url], @"url should match");
    XCTAssertNotNil([changes objectForKey:kModifiedDictionaryKey], @"modified object should exist");
    XCTAssertEqual([[changes objectForKey:kModifiedDictionaryKey] count], 0,
                   @"should be zero items although they may be empty");
    XCTAssertNotNil([changes objectForKey:kDeleteDictionaryKey], @"delete object should exist");
    XCTAssertEqual([[changes objectForKey:kDeleteDictionaryKey] count], 0,
                   @"should be 0 items although they may be empty");
}

- (void)testDirectoryChangesDeleteFile {
    NSString *uuidNameFile = [[[NSUUID UUID] UUIDString] stringByAppendingPathExtension:@"txt"];
    NSURL *newURL = [self createFile:uuidNameFile withContent:nil insideDirectory:_testFolder];
    WWDirectoryItem *item = [[WWDirectoryItem alloc] initWithUrl:_testFolder];
    [item loadChildren];
    XCTAssertNotNil(item, @"should not be nil");
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:newURL.path]) {
        [fileManager removeItemAtPath:newURL.path error:nil];
    }

    NSDictionary *changes = [item directoryChanges:NO];
    XCTAssertNotNil(changes, @"changes should not be nil");
    XCTAssertEqual([changes count], 3, @"should be three items although they may be empty");
    NSArray *delete = [changes objectForKey:kDeleteDictionaryKey];
    XCTAssertNotNil(delete, @"delete object should exist");
    XCTAssertEqual([delete count], 1, @"should be zero items although they may be empty");
    WWDirectoryItem *deletedItem = [delete objectAtIndex:0];
    XCTAssertNotNil(deletedItem, @"delete object should exist");
    NSString *newURLLastPathComponent = [newURL.path lastPathComponent];
    NSString *deletedItemLastPathComponent = [deletedItem.path lastPathComponent];
    XCTAssertEqualObjects(newURLLastPathComponent, deletedItemLastPathComponent,
                          @"url should match");
}

- (void)testDirectoryChangesModifyFile {
    NSString *uuidNameFile = [[[NSUUID UUID] UUIDString] stringByAppendingPathExtension:@"txt"];
    NSURL *newURL = [self createFile:uuidNameFile withContent:nil insideDirectory:_testFolder];
    NSDate *now = [NSDate date];
    NSDate *yesterday = [now dateByAddingTimeInterval:-86400.0];
    [newURL setResourceValue:yesterday forKey:NSURLContentModificationDateKey error:nil];
    [newURL setResourceValue:yesterday forKey:NSURLCreationDateKey error:nil];
    WWDirectoryItem *item = [[WWDirectoryItem alloc] initWithUrl:_testFolder];
    [item loadChildren];
    XCTAssertNotNil(item, @"should not be nil");
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSError *error;
    if ([fileManager fileExistsAtPath:newURL.path]) {
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingToURL:newURL error:&error];
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[@"stuff to add" dataUsingEncoding:NSUTF8StringEncoding]];
        [fileHandle closeFile];
    }
    // nsurl does cache some resources for the duration of the run loop in some cases
    [newURL removeAllCachedResourceValues];
    NSDictionary *changes = [item directoryChanges:NO];
    XCTAssertNotNil(changes, @"changes should not be nil");
    XCTAssertEqual([changes count], 3, @"should be three items although they may be empty");
    NSArray *modified = [changes objectForKey:kModifiedDictionaryKey];
    XCTAssertNotNil(modified, @"modified object should exist");
    XCTAssertEqual([modified count], 1, @"should be one items although they may be empty");
    WWDirectoryItem *modifiedItem = [modified objectAtIndex:0];
    XCTAssertNotNil(modifiedItem, @"modified object should exist");
    XCTAssertTrue([self expected:newURL isEqualToActual:modifiedItem.url], @"url should match");
}

- (void)testDirectoryChangesDeepAddFile {
    WWDirectoryItem *item = [[WWDirectoryItem alloc] initWithUrl:_testFolder];
    [item loadChildren];
    XCTAssertNotNil(item, @"should not be nil");
    NSURL *newURL = [self createFile:@"new.txt" withContent:nil insideDirectory:_firstSubFolder];
    NSDictionary *changes = [item directoryChanges:YES];
    XCTAssertNotNil(changes, @"changes should not be nil");
    XCTAssertEqual([changes count], 3, @"should be three items although they may be empty");
    NSArray *add = [changes objectForKey:kAddDictionaryKey];
    XCTAssertNotNil(add, @"add object should exist");
    XCTAssertEqual([add count], 1, @"should be zero items although they may be empty");
    WWDirectoryItem *addedItem = [add objectAtIndex:0];
    XCTAssertNotNil(addedItem, @"add object should exist");
    XCTAssertTrue([self expected:newURL isEqualToActual:addedItem.url], @"url should match");
    XCTAssertNotNil([changes objectForKey:kModifiedDictionaryKey], @"modified object should exist");
    XCTAssertEqual([[changes objectForKey:kModifiedDictionaryKey] count], 0,
                   @"should be zero items although they may be empty");
    XCTAssertNotNil([changes objectForKey:kDeleteDictionaryKey], @"delete object should exist");
    XCTAssertEqual([[changes objectForKey:kDeleteDictionaryKey] count], 0,
                   @"should be 0 items although they may be empty");
}

- (void)testDirectoryChangesDeepDeleteFile {
    NSString *uuidNameFile = [[[NSUUID UUID] UUIDString] stringByAppendingPathExtension:@"txt"];
    NSURL *newURL = [self createFile:uuidNameFile withContent:nil insideDirectory:_firstSubFolder];
    WWDirectoryItem *item = [[WWDirectoryItem alloc] initWithUrl:_testFolder];
    [item loadChildren];
    XCTAssertNotNil(item, @"should not be nil");
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:newURL.path]) {
        [fileManager removeItemAtPath:newURL.path error:nil];
    }

    NSDictionary *changes = [item directoryChanges:YES];
    XCTAssertNotNil(changes, @"changes should not be nil");
    XCTAssertEqual([changes count], 3, @"should be three items although they may be empty");
    NSArray *delete = [changes objectForKey:kDeleteDictionaryKey];
    XCTAssertNotNil(delete, @"delete object should exist");
    XCTAssertEqual([delete count], 1, @"should be zero items although they may be empty");
    WWDirectoryItem *deletedItem = [delete objectAtIndex:0];
    XCTAssertNotNil(deletedItem, @"delete object should exist");
    NSString *newURLLastPathComponent = [newURL.path lastPathComponent];
    NSString *deletedItemLastPathComponent = [deletedItem.path lastPathComponent];
    XCTAssertEqualObjects(newURLLastPathComponent, deletedItemLastPathComponent,
                          @"url should match");
}

- (void)testDirectoryChangesDeepModifyFile {
    NSString *uuidNameFile = [[[NSUUID UUID] UUIDString] stringByAppendingPathExtension:@"txt"];
    NSURL *newURL = [self createFile:uuidNameFile withContent:nil insideDirectory:_testFolder];
    NSDate *now = [NSDate date];
    NSDate *yesterday = [now dateByAddingTimeInterval:-86400.0];
    [newURL setResourceValue:yesterday forKey:NSURLContentModificationDateKey error:nil];
    [newURL setResourceValue:yesterday forKey:NSURLCreationDateKey error:nil];
    WWDirectoryItem *item = [[WWDirectoryItem alloc] initWithUrl:_testFolder];
    [item loadChildren];
    XCTAssertNotNil(item, @"should not be nil");
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSError *error;
    if ([fileManager fileExistsAtPath:newURL.path]) {
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingToURL:newURL error:&error];
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[@"stuff to add" dataUsingEncoding:NSUTF8StringEncoding]];
        [fileHandle closeFile];
    }
    // nsurl does cache some resources for the duration of the run loop in some cases
    [newURL removeAllCachedResourceValues];
    NSDictionary *changes = [item directoryChanges:NO];
    XCTAssertNotNil(changes, @"changes should not be nil");
    XCTAssertEqual([changes count], 3, @"should be three items although they may be empty");
    NSArray *modified = [changes objectForKey:kModifiedDictionaryKey];
    XCTAssertNotNil(modified, @"modified object should exist");
    XCTAssertEqual([modified count], 1, @"should be one items although they may be empty");
    WWDirectoryItem *modifiedItem = [modified objectAtIndex:0];
    XCTAssertNotNil(modifiedItem, @"modified object should exist");
    XCTAssertTrue([self expected:newURL isEqualToActual:modifiedItem.url], @"url should match");
}

- (void)testDirectoryChangesPerfomance {
    WWDirectoryItem *item = [[WWDirectoryItem alloc] initWithUrl:_testFolder];
    [item loadChildren];
    XCTAssertNotNil(item, @"should not be nil");
    [self measureBlock:^{
        // Put the code you want to measure the time of here.

        NSDictionary *changes = [item directoryChanges:NO];
        XCTAssertNotNil(changes, @"changes should not be nil");
        XCTAssertEqual([changes count], 3, @"should be three items although they may be empty");
    }];
}

- (void)testUpdate_noChanges {
}

- (void)testUpdate_addFile {
}
- (void)testUpdate_deleteFile {
}

- (void)testUpdate_deepAddFile {
    <#given - when - then#>
}
- (void)testLoadingPerfomance {
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        WWDirectoryItem *item = [[WWDirectoryItem alloc] initWithUrl:_testFolder];
        [item loadChildren];
    }];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    NSURL *one = [_testFolder URLByAppendingPathComponent:@"one.txt"];
    WWDirectoryItem *item = [[WWDirectoryItem alloc] initWithUrl:one];
    [self measureBlock:^{
        // Put the code you want to measure the time of here.

        XCTAssertNotNil(item);
        XCTAssertEqualObjects(item.fileName, @"one.txt");
        XCTAssertNotNil(item.created);
        XCTAssertNotNil(item.modified);
        XCTAssertNotNil(item.icon);

    }];
}

@end
