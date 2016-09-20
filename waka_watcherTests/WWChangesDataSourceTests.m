//
//  WWChangesDataSourceTests.m
//  waka_watcher
//
//  Created by Samuel DeVore on 9/7/16.
//  Copyright © 2016 Samuel DeVore. All rights reserved.
//

#import "WWChangesDataSource.h"
#import "WWDirectoryItem.h"
#import <OCHamcrest/OCHamcrest.h>
#import <OCMockito/OCMockito.h>
#import <XCTest/XCTest.h>

@interface WWChangesDataSourceTests : XCTestCase

@end

@implementation WWChangesDataSourceTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the
    // class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the
    // class.
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

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
