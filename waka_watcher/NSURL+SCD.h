//
//  NSURL+SCD.h
//  waka_watcher
//
//  Created by Samuel DeVore on 10/11/16.
//  Copyright © 2016 Samuel DeVore. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (SCD)



/**
 compares two urls if they are file urls and they both are valid on file they will have
 the actual resources compared

 @param url the url to compare to

 @return BOOL
 */
-(BOOL)scd_equalTo:(nonnull NSURL *)url;
@end
