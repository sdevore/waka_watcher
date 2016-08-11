//
//  TestBase.m
//

#import "SCDTestCase.h"

@interface SCDTestCase ()

- (NSURL *)getResources;

@end

@implementation SCDTestCase

- (BOOL)requireFilesystem {

  return NO;
}

- (NSURL *)copyResource:(NSString *)resourceName {

  return [self copyResource:resourceName toDirectory:self.testLocation];
}

- (NSURL *)copyResource:(NSString *)resourceName
            toDirectory:(NSURL *)directory {

  NSError *error;
  NSURL *source =
      [[self getResources] URLByAppendingPathComponent:resourceName];
  NSURL *target = [directory URLByAppendingPathComponent:resourceName];

  if (![[NSFileManager defaultManager] copyItemAtURL:source
                                               toURL:target
                                               error:&error]) {
    NSLog(@"Error copying test resource: %@", error.localizedDescription);
    return nil;
  }

  return target;
}

- (NSURL *)createFile:(NSString *)name withContent:(NSData *)content {

  return [self createFile:name
              withContent:content
          insideDirectory:self.testLocation];
}

- (NSURL *)createFile:(NSString *)name
          withContent:(NSData *)content
      insideDirectory:(NSURL *)directory {

  NSURL *file = [directory URLByAppendingPathComponent:name];

  if (![[NSFileManager defaultManager] createFileAtPath:file.path
                                               contents:content
                                             attributes:nil]) {
    NSLog(@"Error creating file: %@", name);
    return nil;
  }

  return file;
}

- (NSURL *)createDirectory:(NSString *)name {

  return [self createDirectory:name insideDirectory:self.testLocation];
}

- (NSURL *)createDirectory:(NSString *)name insideDirectory:(NSURL *)directory {

  NSError *error;
  NSURL *dir = [directory URLByAppendingPathComponent:name];

  if (![[NSFileManager defaultManager] createDirectoryAtURL:dir
                                withIntermediateDirectories:YES
                                                 attributes:nil
                                                      error:&error]) {
    NSLog(@"Error creating test directory: %@", error.localizedDescription);
    return nil;
  }

  return dir;
}

- (void)setUp {

  [super setUp];

  // Abort tests immediately when an assertion fails
  self.continueAfterFailure = NO;

  if ([self requireFilesystem]) {

    NSError *error;
    NSURL *location = [[NSURL fileURLWithPath:NSTemporaryDirectory()]
        URLByAppendingPathComponent:[[NSProcessInfo processInfo]
                                        globallyUniqueString]];
location = [location URLByResolvingSymlinksInPath];
    if ([[NSFileManager defaultManager] createDirectoryAtURL:location
                                 withIntermediateDirectories:YES
                                                  attributes:nil
                                                       error:&error]) {
      self.testLocation = location;
    } else {
      NSLog(@"Error creating test directory: %@", error.localizedDescription);
    }
  } else {
    _testLocation = nil;
  }
    
}

- (void)tearDown {

  if ([self requireFilesystem]) {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:self.testLocation.path]) {
      [fileManager removeItemAtPath:self.testLocation.path error:nil];
    }
  }

  [super tearDown];
}

- (NSURL *)getResources {

  // Path to test resources

  return [[NSBundle bundleForClass:self.class] URLForResource:@"Resources"
                                                withExtension:nil];
}

- (BOOL)expected:(NSURL *)expected isEqualToActual:(NSURL *)actual
{
    id fileURLIDExpected;
    [expected getResourceValue:&fileURLIDExpected forKey:NSURLFileResourceIdentifierKey error:NULL];
    
    id fileURLIDActual;
    [actual getResourceValue:&fileURLIDActual forKey:NSURLFileResourceIdentifierKey error:NULL];
    
    if (!fileURLIDActual || !fileURLIDExpected) return NO; // no file URLs?
    
    return ([fileURLIDExpected isEqual:fileURLIDActual]);
}

@end
