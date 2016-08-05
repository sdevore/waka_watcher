//
//  WWDirectoryItemTests.m
//  waka_watcher
//
//  Created by Samuel DeVore on 8/2/16.
//  Copyright © 2016 Samuel DeVore. All rights reserved.
//

#import "SCDTestCase.h"
#import "WWDirectoryItem.h"

@interface WWDirectoryItemTests : SCDTestCase {
    NSURL *_testFolder;
    NSURL *_firstSubFolder;
    NSURL *_secondSubFolder;
    NSURL *_thirdSubFolder;
    NSURL *_fourthSubFolder;
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

    NSLog(@"create four sub folders: \r%@\r%@\r%@\r%@", _firstSubFolder, _secondSubFolder,
          _thirdSubFolder, _fourthSubFolder);
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each
    // test method in the class.
    [super tearDown];
}

- (void)testInitializers {
    NSURL *one = [_testFolder URLByAppendingPathComponent:@"one.txt"];
    XCTAssertNotNil(one);
    WWDirectoryItem *item = [[WWDirectoryItem alloc] initWithUrl:one];
    XCTAssertNotNil(item);
    XCTAssertNil(item.project);

    item = [[WWDirectoryItem alloc] initWithUrl:one withProject:@"project"];
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
    XCTAssertEqual([[changes objectForKey:kAddDictionaryKey] count], 0, @"should be zero items although they may be empty");
    XCTAssertNotNil([changes objectForKey:kModifiedDictionaryKey], @"modified object should exist");
    XCTAssertEqual([[changes objectForKey:kModifiedDictionaryKey] count], 0, @"should be zero items although they may be empty");
    XCTAssertNotNil([changes objectForKey:kDeleteDictionaryKey], @"delete object should exist");
    XCTAssertEqual([[changes objectForKey:kDeleteDictionaryKey] count], 0, @"should be 0 items although they may be empty");
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
    XCTAssertEqualObjects(newURL.path, [addedItem.url path], @"url should match");
    XCTAssertNotNil([changes objectForKey:kModifiedDictionaryKey], @"modified object should exist");
    XCTAssertEqual([[changes objectForKey:kModifiedDictionaryKey] count], 0, @"should be zero items although they may be empty");
    XCTAssertNotNil([changes objectForKey:kDeleteDictionaryKey], @"delete object should exist");
    XCTAssertEqual([[changes objectForKey:kDeleteDictionaryKey] count], 0, @"should be 0 items although they may be empty");

    
}

- (void)testDirectoryChangesDeleteFile {
    XCTAssert(false, @"not written");
}

- (void)testDirectoryChangesModifyFile {
    XCTAssert(false, @"not written");
}

- (void)testDirectoryChangesDeepAddFile {
    XCTAssert(false, @"not written");
}

- (void)testDirectoryChangesDeepDeleteFile {
    XCTAssert(false, @"not written");
}

- (void)testDirectoryChangesDeepModifyFile {
    XCTAssert(false, @"not written");
}

- (void)testDirectoryChangesPerfomance {
    XCTAssert(false, @"not written");
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        XCTAssert(false);
    }];
}

- (void)testLoadingPerfomance {
    XCTAssert(false, @"not written");
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        XCTAssert(false);
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
