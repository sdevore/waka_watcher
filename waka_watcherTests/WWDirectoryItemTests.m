//
//  WWDirectoryItemTests.m
//  waka_watcher
//
//  Created by Samuel DeVore on 8/2/16.
//  Copyright © 2016 Samuel DeVore. All rights reserved.
//

#import "MTEThreadsafeArray.h"
#import "SCDTestCase.h"
#import "WWDirectoryItem.h"
#import <OCHamcrest/OCHamcrest.h>
#import <OCMockito/OCMockito.h>

@interface WWDirectoryItemTests : SCDTestCase <WWDirectoryDataSourceProtocol> {
    NSURL *_testFolder;
    NSURL *_firstSubFolder;
    NSURL *_secondSubFolder;
    NSURL *_thirdSubFolder;
    NSURL *_fourthSubFolder;
    WWDirectoryItem *_testItem;

    NSArray *_added;
    NSArray *_modified;
    NSArray *_deleted;
}
@property (weak) id<WWDirectoryDataSourceProtocol> _Nullable delegate;
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

    _added = [NSMutableArray new];
    _modified = [NSMutableArray new];
    _deleted = [NSMutableArray new];
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

- (void)testLoadChildrenDelegateCalls {
    id<WWDirectoryDataSourceProtocol> delegate =
        mockProtocol(@protocol(WWDirectoryDataSourceProtocol));
    [given([delegate directoryDataSource:anything() shouldLoadItem:anything()]) willReturn:@YES];
    _testItem.delegate = delegate;
    [_testItem loadChildren:YES async:NO];
    [verifyCount(delegate, atLeastOnce()) directoryDataSource:anything() shouldLoadItem:anything()];
    [verifyCount(delegate, atLeastOnce()) directoryDataSource:anything() willLoadItem:anything()];
    [verifyCount(delegate, atLeastOnce()) directoryDataSource:anything() didLoadItem:anything()];
}

- (void)testUpdate_noChanges {
    [_testItem loadChildren:YES async:NO];
    NSArray *children = [[_testItem children] array];
    assertThat(children, notNilValue());
    assertThat(children, hasCountOf(8));
    [_testItem updateChildren:YES async:NO];
    NSArray *postChildren = [[_testItem children] array];
    assertThat(postChildren, notNilValue());
    assertThat(postChildren, hasCountOf(8));
}

- (void)testUpdate_addFile {
    [_testItem loadChildren:YES async:NO];
    _testItem.delegate = self;
    NSArray *children = [[_testItem children] array];
    assertThat(children, notNilValue());
    assertThat(children, hasCountOf(8));
    NSURL *newURL = [self createFile:@"new.txt" withContent:nil insideDirectory:_testFolder];
    [_testItem updateChildren:YES async:NO];
    NSArray *postChildren = [[_testItem children] array];
    assertThat(postChildren, notNilValue());
    assertThat(postChildren, hasCountOf(9));
    assertThat(_added, hasCountOf(1));
    WWDirectoryItem *newItem = [_added objectAtIndex:0];
    assertThatBool([self expected:newURL isEqualToActual:newItem.url], isTrue());
}
- (void)testUpdate_deleteFile {
    NSString *uuidNameFile = [[[NSUUID UUID] UUIDString] stringByAppendingPathExtension:@"txt"];
    NSURL *newURL = [self createFile:uuidNameFile withContent:nil insideDirectory:_testFolder];
    _testItem = [[WWDirectoryItem alloc] initWithUrl:_testFolder];
    [_testItem loadChildren:YES async:NO];
    assertThat(_testItem, notNilValue());
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:newURL.path]) {
        [fileManager removeItemAtPath:newURL.path error:nil];
    }
    [_testItem updateChildren:YES async:NO];
    NSArray *postChildren = [[_testItem children] array];
    assertThat(postChildren, notNilValue());
    assertThat(postChildren, hasCountOf(8));
}

- (void)testUpdate_deepAddFile {
}

- (void)testUpdate_delegatesCalled {
    id<WWDirectoryDataSourceProtocol> delegate =
        mockProtocol(@protocol(WWDirectoryDataSourceProtocol));
    _testItem.delegate = delegate;
    [_testItem loadChildren:YES async:NO];
    NSURL *newURL = [self createFile:@"new.txt" withContent:nil insideDirectory:_testFolder];
    [_testItem updateChildren:YES async:NO];

    [verifyCount(delegate, atLeastOnce()) directoryDataSource:anything()
                                                   addedItems:anything()
                                                    atIndexes:anything()];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:newURL.path]) {
        [fileManager removeItemAtPath:newURL.path error:nil];
    }
    [_testItem updateChildren:YES async:NO];
    [verifyCount(delegate, atLeastOnce()) directoryDataSource:anything()
                                                 removedItems:anything()
                                                    atIndexes:anything()];
}
#pragma mark - performance section

- (void)testUpdatePerfomance {
    [_testItem loadChildren:YES async:NO];
    XCTAssertNotNil(_testItem, @"should not be nil");
    [self measureBlock:^{
        // Put the code you want to measure the time of here.

        [_testItem updateChildren:YES async:NO];
    }];
}
- (void)testLoadingPerfomance {
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        WWDirectoryItem *item = [[WWDirectoryItem alloc] initWithUrl:_testFolder];
        [item loadChildren:YES async:NO];
    }];
}

- (void)testDirectoryItemParamaterPerformance {
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

// delegate methods...

- (void)directoryDataSource:(WWDirectoryDataSource *)source
                 addedItems:(NSArray *)items
                  atIndexes:(NSIndexSet *)indexSet {
    _added = [_added arrayByAddingObjectsFromArray:items];
}

- (void)directoryDataSource:(WWDirectoryDataSource *)source
              modifiedItems:(NSArray *)items
                  atIndexes:(NSIndexSet *)indexSet {
    _modified = [_modified arrayByAddingObjectsFromArray:items];
}

- (void)directoryDataSource:(WWDirectoryDataSource *)source
               removedItems:(NSArray *)items
                  atIndexes:(NSIndexSet *)indexSet {
    _deleted = [_deleted arrayByAddingObjectsFromArray:items];
}

@end
