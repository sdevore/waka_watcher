//
//  ViewController.m
//  waka_watcher
//
//  Created by Samuel DeVore on 1/1/16.
//  Copyright © 2016 Samuel DeVore. All rights reserved.
//

#import "FileView.h"
#import "ModifiedView.h"
#import "ProjectView.h"
#import "ViewController.h"
#import "WWChangesDataSource.h"
#import "WWChangesHeaderView.h"
#import "WWDirectoryDataSource.h"
#import "WWDirectoryItem.h"
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    self.outlineDatasource = [WWDirectoryDataSource new];
    self.changesDatasource = [WWChangesDataSource new];
    [self.directoryView setDelegate:self];
    [self.directoryView setDataSource:self.outlineDatasource];
    [self.recentChangesView setDelegate:self];
    [self.recentChangesView setDataSource:self.changesDatasource];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)addDirectory:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.canChooseDirectories = YES;
    panel.canChooseFiles = NO;
    panel.allowsMultipleSelection = YES;
    panel.showsHiddenFiles = NO;
    panel.title = NSLocalizedString(@"Select directories to monitor",
                                    @"select directories to monitor window title");
    panel.message =
        NSLocalizedString(@"Select the directories that you are planning to monitor and submit to "
                          @"WakaTime for tracking your time.  These directories will be monitored "
                          @"for file changes.  You can specify projects later.",
                          @"select directories message");
    [panel beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            dispatch_queue_t myQueue =
                dispatch_queue_create("com.scidsolutions.wakawatcher.url_loader", NULL);
            dispatch_async(myQueue, ^{
                // Perform long running process
                NSArray *URLs = [NSArray arrayWithArray:panel.URLs];
                NSIndexSet *newRows = [self.outlineDatasource addURLs:URLs withDelegate:self];
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Update the UI
                    [self.directoryView insertItemsAtIndexes:newRows
                                                    inParent:nil
                                               withAnimation:YES];
                });

            });
        }

    }];
}

- (IBAction)removeSelectedDirectory:(id)sender {
}

- (IBAction)watching:(id)sender {
    if (self.outlineDatasource != nil) {
        [self.outlineDatasource setWatching:YES];
    }
}

- (IBAction)watchingDefault:(id)sender {
}

#pragma mark - NSTableViewDelegate methods
- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    // Make the row view keep track of our main model object
    WWChangesGroup *item = [self.changesDatasource tableView:tableView
                                   objectValueForTableColumn:[NSTableColumn new]
                                                         row:row];
    WWChangesHeaderView *result = [[WWChangesHeaderView alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)];
    result.objectValue = item;
    return result;
}
- (BOOL)tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row {
    return [self.changesDatasource isGroup:row];
}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row {
   
    if ([self tableView:tableView isGroupRow:row]) {
        NSTextField *textField = [tableView makeViewWithIdentifier:@"TextCell" owner:self];

        WWChangesGroup *item = [self.changesDatasource tableView:tableView
                                       objectValueForTableColumn:tableColumn
                                                             row:row];
        [textField setStringValue:item.string];
        return textField;

    } else {
    }
    return nil;
}
#pragma mark - NSOutlineViewDelegate methods

- (NSView *)outlineView:(NSOutlineView *)outlineView
     viewForTableColumn:(NSTableColumn *)tableColumn
                   item:(id)item {
    NSString *identifier = tableColumn.identifier;
    if ([identifier isEqualToString:kFileViewColumn]) {
        FileView *fileView = [outlineView makeViewWithIdentifier:kFileViewColumn owner:self];
        fileView.fileItem = item;
        return fileView;
    } else if ([identifier isEqualToString:kFileModifiedColumn]) {
        ModifiedView *result = [outlineView makeViewWithIdentifier:kFileModifiedColumn owner:self];
        result.textField.objectValue = [(WWDirectoryItem *)item modified];
        return result;
    } else if ([identifier isEqualToString:kProjectViewColumn]) {
        NSTableCellView *result = [outlineView makeViewWithIdentifier:identifier owner:self];
        result.textField.stringValue = [(WWDirectoryItem *)item project];
        result.objectValue = item;
        [result.imageView setTarget:self];
        [result.imageView setAction:@selector(editProjectLabel:)];
        return result;
    } else {
        NSTableCellView *result = [outlineView makeViewWithIdentifier:identifier owner:self];
        result.objectValue = item;
        return result;
    }
}

- (IBAction)editProjectLabel:(id)sender {
    DDLogInfo(@"sender: %@", sender);
}
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldExpandItem:(id)item {
    if ([item isKindOfClass:[WWDirectoryItem class]]) {
        if (![(WWDirectoryItem *)item isLoading] && [(WWDirectoryItem *)item isDirectory]) {
            return YES;
        }
    }
    return NO;
}

- (void)directoryItem:(WWDirectoryItem *)item childrenDidFinishLoading:(NSInteger)childCount {
}

- (void)directoryItem:(WWDirectoryItem *)item
    contentsDidChange:(NSIndexSet *)setOfChanges
          changeEvent:(CDEvent *)event {
}

-(void)directoryDataSource:(WWDirectoryDataSource *)source addedItems:(NSArray *)items atIndexes:(NSIndexSet *)indexSet {
    [self.changesDatasource addedItems:items];
    [self.recentChangesView reloadData];
}

-(void)directoryDataSource:(WWDirectoryDataSource *)source modifiedItems:(NSArray *)items atIndexes:(NSIndexSet *)indexSet {
    [self.changesDatasource modifiedItems:items];
    [self.recentChangesView reloadData];
}
-(void)directoryDataSource:(WWDirectoryDataSource *)source removedItems:(NSArray *)items atIndexes:(NSIndexSet *)indexSet {
    [self.changesDatasource deletedItems:items];
    [self.recentChangesView reloadData];
}

@end
