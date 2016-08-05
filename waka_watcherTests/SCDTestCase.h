//
//  TestBase.h
//

@import XCTest;

@interface SCDTestCase : XCTestCase

@property NSURL *testLocation;

- (BOOL)requireFilesystem;
- (NSURL *)copyResource:(NSString *)resourceName;
- (NSURL *)copyResource:(NSString *)resourceName toDirectory:(NSURL *)directory;
- (NSURL *)createFile:(NSString *)name withContent:(NSData *)content;
- (NSURL *)createFile:(NSString *)name
          withContent:(NSData *)content
      insideDirectory:(NSURL *)directory;
- (NSURL *)createDirectory:(NSString *)name;
- (NSURL *)createDirectory:(NSString *)name insideDirectory:(NSURL *)directory;

@end
