//
//  ItemStash.h
//  ListMonster
//
//  Created by Norm Barnard on 4/10/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import <CoreData/CoreData.h>

@class MetaListItem;
@class Measure;

@interface ItemStash : NSManagedObject {
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *quantity;
@property (nonatomic, retain) NSNumber *unitIdentifier;
@property (nonatomic, retain) NSNumber *priority;

+ (void)addToStash:(MetaListItem *)anItem;
+ (NSString *)nameForPriority:(NSNumber *)priority;

@end
