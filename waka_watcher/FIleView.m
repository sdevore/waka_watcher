//
//  FIleView.m
//  waka_watcher
//
//  Created by Samuel DeVore on 7/15/16.
//  Copyright © 2016 Samuel DeVore. All rights reserved.
//

#import "FileView.h"
NSString *const kFileViewColumn = @"fileViewColumn";



@implementation FileView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    // Drawing code here.
}

- (void)setFileItem:(WWDirectoryItem *)fileItem {
    _fileItem = fileItem;
    [self.iconView setImage:fileItem.icon];
    [self.directoryItemLabel setStringValue:[fileItem.url lastPathComponent]];
}

- (IBAction)watchForChanges:(id)sender {
    if (nil != self.fileItem && nil != sender && [sender isKindOfClass:[NSButton class]]) {
        self.fileItem.shouldWatch = [(NSButton *)sender state] == NSOnState;
    }
}
@end
