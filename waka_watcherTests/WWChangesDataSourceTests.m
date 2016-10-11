//
//  WWChangesDataSourceTests.m
//  waka_watcher
//
//  Created by Samuel DeVore on 9/7/16.
//  Copyright © 2016 Samuel DeVore. All rights reserved.
//

#import "SCDTestCase.h"
#import "WWChangesDataSource.h"
#import "WWDirectoryItem.h"
#import <OCHamcrest/OCHamcrest.h>
#import <OCMockito/OCMockito.h>
#import <XCTest/XCTest.h>

@interface WWChangesDataSourceTests : SCDTestCase <WWChangesDataSourceProtocol>

@end

@implementation WWChangesDataSourceTests {
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

- (BOOL)requireFilesystem {
    // Enable filesystem support. If enabled, a new temporary directory is
    // created prior and deleted after each individual test.
    return YES;
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the
    // class.
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
    // Put teardown code here. This method is called after the invocation of each test method in the
    // class.
    _testItem = nil;
    [super tearDown];
}

- (void)testNewDataSource {
    WWChangesDataSource *source = [WWChangesDataSource new];
    assertThat(source, notNilValue());
}
- (void)testDataSource_checkIsGroup {
    WWChangesDataSource *source = [WWChangesDataSource new];
    assertThatBool([source isGroup:0], isTrue());
    assertThatBool([source isGroup:1], isTrue());

    assertThatBool([source isGroup:3], isTrue());
}

- (void)testDataSource_countRows {
    WWChangesDataSource *source = [WWChangesDataSource new];
    NSTableView *view = [NSTableView new];
    assertThatLong([source numberOfRowsInTableView:view], equalToLong(3));
}

-(void)testDataSource_addedItems_addItem {
    WWChangesDataSource *source = [WWChangesDataSource new];
    id<WWChangesDataSourceProtocol> delegate = mockProtocol(@protocol(WWChangesDataSourceProtocol));
    source.delegate = delegate;
    WWDirectoryItem *item = [[WWDirectoryItem alloc] initWithUrl:_firstSubFolder];
    [source addedItems:@[item]];
    assertThatInteger([source numberOfRowsInTableView:[NSTableView new]], equalToInteger(4));
    WWDirectoryItem *second = [[WWDirectoryItem alloc] initWithUrl:_firstSubFolder];
    
    [source addedItems:@[second]];
    assertThatInteger([source numberOfRowsInTableView:[NSTableView new]], equalToInteger(4));
    [verifyCount(delegate, atLeastOnce()) changeDataSource:anything() addedItems:anything() atIndexes:anything()];
}

-(void)testDataSource_deletedItems_addItem {
    WWChangesDataSource *source = [WWChangesDataSource new];
    id<WWChangesDataSourceProtocol> delegate = mockProtocol(@protocol(WWChangesDataSourceProtocol));
    source.delegate = delegate;
    WWDirectoryItem *item = [[WWDirectoryItem alloc] initWithUrl:_firstSubFolder];
    [source deletedItems:@[item]];
    assertThatInteger([source numberOfRowsInTableView:[NSTableView new]], equalToInteger(4));
    WWDirectoryItem *second = [[WWDirectoryItem alloc] initWithUrl:_firstSubFolder];
    [source deletedItems:@[second]];
    assertThatInteger([source numberOfRowsInTableView:[NSTableView new]], equalToInteger(4));
    [verifyCount(delegate, atLeastOnce()) changeDataSource:anything() deletedItems:anything() atIndexes:anything()];
}

-(void)testDataSource_modifiedItems_addItem {
    WWChangesDataSource *source = [WWChangesDataSource new];
    id<WWChangesDataSourceProtocol> delegate = mockProtocol(@protocol(WWChangesDataSourceProtocol));
    source.delegate = delegate;
    WWDirectoryItem *item = [[WWDirectoryItem alloc] initWithUrl:_firstSubFolder];
    [source modifiedItems:@[item]];
    assertThatInteger([source numberOfRowsInTableView:[NSTableView new]], equalToInteger(4));
    WWDirectoryItem *second = [[WWDirectoryItem alloc] initWithUrl:_firstSubFolder];
    [source modifiedItems:@[second]];
    assertThatInteger([source numberOfRowsInTableView:[NSTableView new]], equalToInteger(4));
    [verifyCount(delegate, atLeastOnce()) changeDataSource:anything() deletedItems:anything() atIndexes:anything()];
}



- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
