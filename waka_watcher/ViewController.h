//
//  ViewController.h
//  waka_watcher
//
//  Created by Samuel DeVore on 1/1/16.
//  Copyright © 2016 Samuel DeVore. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class WWDirectoryDataSource;
@class WWChangesDataSource;
@class WWDirectoryItemProtocol;

@interface ViewController : NSViewController <WWDirectoryDataSourceProtocol, NSOutlineViewDelegate, NSTableViewDelegate>
@property (nullable, weak) IBOutlet NSButton *watchingButton;
@property (nullable, weak) IBOutlet NSTableView *recentChangesView;
@property (nullable, weak) IBOutlet NSOutlineView *directoryView;
@property (nullable) WWDirectoryDataSource *outlineDatasource;
@property (nullable) WWChangesDataSource *changesDatasource;
- (IBAction)addDirectory:(nullable id)sender;
- (IBAction)removeSelectedDirectory:(nullable id)sender;
- (IBAction)watching:(nullable id)sender;
- (IBAction)watchingDefault:(nullable id)sender;

@end
