//
//  NSURL+SCDTest.m
//  waka_watcher
//
//  Created by Samuel DeVore on 10/11/16.
//  Copyright (c) 2016 Samuel DeVore. All rights reserved.
//

#import "SCDTestCase.h"
#import <XCTest/XCTest.h>
#import <OCHamcrest/OCHamcrest.h>
#import <OCMockito/OCMockito.h>
#import "NSURL+SCD.h"

@interface NSURL_SCDTest : SCDTestCase

@end

@implementation NSURL_SCDTest{
    NSURL *_folder;
    

}


-(BOOL)requireFilesystem {
    return YES;
}

- (void)setUp {
    [super setUp];
    _folder = [self createDirectory:@"NSURL_SCDTest"];
    [self createFile:@"one.txt" withContent:nil insideDirectory:_folder];
    [self createFile:@"two.txt" withContent:nil insideDirectory:_folder];
    [self createFile:@"three.txt" withContent:nil insideDirectory:_folder];
    [self createFile:@"four.txt" withContent:nil insideDirectory:_folder];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testFileURLS {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    NSString *path1 = [[_folder URLByAppendingPathComponent:@"one.txt"] path] ;
    NSString *path2 = [@"/private" stringByAppendingString:path1];
    NSURL *url1 = [NSURL fileURLWithPath:path1];
    NSURL *url2 = [NSURL fileURLWithPath:path2];
    assertThatBool([url1 scd_equalTo:url2], isTrue());
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
