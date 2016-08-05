//
//  FIleView.h
//  waka_watcher
//
//  Created by Samuel DeVore on 7/15/16.
//  Copyright © 2016 Samuel DeVore. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WWDirectoryItem.h"

extern NSString * __nonnull const kFileViewColumn;

@interface FileView : NSTableCellView

@property (nullable, nonatomic) WWDirectoryItem *fileItem;

@property (weak, nullable) IBOutlet NSImageView *iconView;
@property (weak, nullable) IBOutlet NSButton *watchForChanges;
@property (weak, nullable) IBOutlet NSTextField *directoryItemLabel;



- (IBAction)watchForChanges:(nullable id)sender;
@end
