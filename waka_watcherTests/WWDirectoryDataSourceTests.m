//
//  WWDirectoryDataSourceTests.m
//  waka_watcher
//
//  Created by Samuel DeVore on 7/20/16.
//  Copyright © 2016 Samuel DeVore. All rights reserved.
//

#import "SCDTestCase.h"
#import "WWDirectoryDataSource.h"
#import "WWDirectoryItem.h"
#import <XCTest/XCTest.h>
#import <OCHamcrest/OCHamcrest.h>
#import <OCMockito/OCMockito.h>
@interface WWDirectoryDataSourceTests : SCDTestCase

@end

@implementation WWDirectoryDataSourceTests {
    NSURL *_library;
}

- (BOOL)requireFilesystem {
    // Enable filesystem support. If enabled, a new temporary directory is
    // created prior and deleted after each individual test.
    return YES;
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each
    // test method in the class.
    // Create some directories...
    _library = [self createDirectory:@"JDocLibrary"];
    NSURL *awmDocuments = [self createDirectory:@"AWM" insideDirectory:_library];
    NSURL *companyDocuments = [self createDirectory:@"Company" insideDirectory:_library];
    NSURL *flightDocuments = [self createDirectory:@"Flight" insideDirectory:_library];
    NSURL *operatorDocuments = [self createDirectory:@"Operator" insideDirectory:_library];
    NSLog(@"create four folders: \r%@\r%@\r%@\r%@", awmDocuments, companyDocuments, flightDocuments,
          operatorDocuments);
    // Create temporary files...
    [self createFile:@"one.txt" withContent:nil insideDirectory:companyDocuments];
    [self createFile:@"two.txt" withContent:nil insideDirectory:companyDocuments];
    [self createFile:@"three.txt" withContent:nil insideDirectory:companyDocuments];
    [self createFile:@"four.txt" withContent:nil insideDirectory:companyDocuments];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each
    // test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the
    // correct results.
}

- (void)testAddURLsNoURLs {
    WWDirectoryDataSource *ds = [WWDirectoryDataSource new];
    NSIndexSet *set;
    set = [ds addURLs:[NSArray array] withDelegate:nil];
    XCTAssertNotNil(set, @"empty array added should return empty NSIndexSet");
    XCTAssert(set.count == 0, @"empty array added should return empty NSIndexSet");
}

- (void)testAddURLsToEmptyDataSource {
    WWDirectoryDataSource *ds = [WWDirectoryDataSource new];
    NSIndexSet *set;
    NSURL *url = _library;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *urls = [fm contentsOfDirectoryAtURL:url
                      includingPropertiesForKeys:NULL
                                         options:NSDirectoryEnumerationSkipsHiddenFiles
                                           error:nil];
    set = [ds addURLs:urls withDelegate:nil];
    XCTAssertNotNil(set);
    XCTAssertEqual(set.count, 4);
}

- (void)testExpandable {
    WWDirectoryDataSource *ds = [WWDirectoryDataSource new];
    NSIndexSet *set;
    NSURL *url = _library;
    [self createFile:@"four.txt" withContent:nil insideDirectory:_library];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *urls = [fm contentsOfDirectoryAtURL:url
                      includingPropertiesForKeys:NULL
                                         options:NSDirectoryEnumerationSkipsHiddenFiles
                                           error:nil];
    set = [ds addURLs:urls withDelegate:nil];
    XCTAssertNotNil(set);
    XCTAssertEqual(set.count, 5);
    WWDirectoryItem *item = [ds outlineView:[NSOutlineView new] child:3 ofItem:nil];
    XCTAssertFalse([item isDirectory]);
    item = [ds outlineView:[NSOutlineView new] child:1 ofItem:nil];
    XCTAssertTrue([item isDirectory]);
}

- (void)testFolderWakaProjectFileExists {
    WWDirectoryDataSource *ds = [WWDirectoryDataSource new];
    NSIndexSet *set;
    NSString *projectName = @"prject name";
    NSData *projectNameAsData = [projectName dataUsingEncoding:NSUTF8StringEncoding];

    [self createFile:@".wakatime-project" withContent:projectNameAsData insideDirectory:_library];
    NSArray *urls = [NSArray arrayWithObject:_library];
    set = [ds addURLs:urls withDelegate:nil];
    WWDirectoryItem *item = [ds outlineView:[NSOutlineView new] child:0 ofItem:NULL];
    XCTAssertNotNil(item);
    XCTAssertNotNil(item.project);
    XCTAssertTrue([projectName isEqualToString:item.project]);
}

- (void)testFolderWakaProjectFileNotExists {
    WWDirectoryDataSource *ds = [WWDirectoryDataSource new];
    NSIndexSet *set;
    NSArray *urls = [NSArray arrayWithObject:_library];
    set = [ds addURLs:urls withDelegate:nil];
    WWDirectoryItem *item = [ds outlineView:[NSOutlineView new] child:0 ofItem:NULL];
    XCTAssertNotNil(item);
    XCTAssertNil(item.project);
}

-(void)testWatchingStateChanges {
    WWDirectoryDataSource *ds = [WWDirectoryDataSource new];
    NSIndexSet *set;
    NSURL *url = _library;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *urls = [fm contentsOfDirectoryAtURL:url
                      includingPropertiesForKeys:NULL
                                         options:NSDirectoryEnumerationSkipsHiddenFiles
                                           error:nil];
    set = [ds addURLs:urls withDelegate:nil];
    assertThatInteger(ds.watching, equalToInteger(NSOffState));
    [ds setWatching:NSOnState];
    NSInteger result = ds.watching;
    assertThatInteger(ds.watching, equalToInteger(NSOnState));
    WWDirectoryItem *item = [ds outlineView:[NSOutlineView new] child:0 ofItem:nil];
    assertThat(item, notNilValue());
               
    
}

- (void)testPerformanceAddURLsToEmptyDataSource {
    // This is an example of a performance test case.
    [self measureBlock:^{
        WWDirectoryDataSource *ds = [WWDirectoryDataSource new];
        NSArray *urls = [[NSFileManager defaultManager]
              contentsOfDirectoryAtURL:_library
            includingPropertiesForKeys:NULL
                               options:NSDirectoryEnumerationSkipsHiddenFiles
                                 error:nil];
        [ds addURLs:urls withDelegate:nil];

    }];
}

@end
