//
//  ProjectView.m
//  waka_watcher
//
//  Created by Samuel DeVore on 8/10/16.
//  Copyright © 2016 Samuel DeVore. All rights reserved.
//

#import "ProjectView.h"
#import "WWDirectoryItem.h"

NSString *const kProjectViewColumn = @"projectViewColumn";
@implementation ProjectView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    // Drawing code here.
}
- (void)setFileItem:(WWDirectoryItem *)fileItem {
    _fileItem = fileItem;
    [self.textField setStringValue:fileItem.project];
}

@end
