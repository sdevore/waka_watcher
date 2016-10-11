//
//  NSURL+SCD.m
//  waka_watcher
//
//  Created by Samuel DeVore on 10/11/16.
//  Copyright © 2016 Samuel DeVore. All rights reserved.
//

#import "NSURL+SCD.h"

@implementation NSURL (SCD)

-(BOOL)scd_equalTo:(nonnull NSURL *)url {
    if ([self isEqual:url]) {
        return YES;
    }
    
    if (self.isFileURL && url.isFileURL) {
        id fileURLIDSelf;
        NSError *errSelf;
        if (![self getResourceValue:&fileURLIDSelf forKey:NSURLFileResourceIdentifierKey error:&errSelf]) {
            return NO;
        }
        
        id fileURLID;
        NSError *err;
        if (![url getResourceValue:&fileURLID forKey:NSURLFileResourceIdentifierKey error:&err]){
            return NO;
        }
        
        if (!fileURLIDSelf || !fileURLID) {
            return NO; // no file URLs?
        }
        return ([fileURLIDSelf isEqual:fileURLID]);
    }
    else {
        return [[self absoluteURL] isEqual:[url absoluteURL]];
    }
    
    return NO;
}
@end
