//
//  ProjectView.h
//  waka_watcher
//
//  Created by Samuel DeVore on 8/10/16.
//  Copyright © 2016 Samuel DeVore. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class WWDirectoryItem;
extern NSString *__nonnull const kProjectViewColumn;

@interface ProjectView : NSTableCellView
@property (nullable, nonatomic) WWDirectoryItem *fileItem;
@property (weak, nullable) IBOutlet NSButton *watchForChanges;
@end
