//
//  ItemStash.h
//  ListMonster
//
//  Created by Norm Barnard on 4/10/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "_ItemStash.h"

@class MetaListItem;
@class Measure;

@interface ItemStash : _ItemStash {
}


+ (void)addToStash:(MetaListItem *)anItem;
+ (NSString *)nameForPriority:(NSNumber *)priority;

@end
