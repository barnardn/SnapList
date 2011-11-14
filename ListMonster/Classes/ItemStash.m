//
//  ItemStash.m
//  ListMonster
//
//  Created by Norm Barnard on 4/10/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import "ItemStash.h"
#import "ListMonsterAppDelegate.h"
#import "Measure.h"
#import "MetaListItem.h"

@implementation ItemStash

@dynamic name, quantity, unitIdentifier, priority;


// add an item to the item stash using a local managed object context so as to 
// not mess up transactions at the app level moc.
//
+ (void)addToStash:(MetaListItem *)anItem
{
    NSManagedObjectContext *ctx = [[NSManagedObjectContext alloc] init];
    [ctx setPersistentStoreCoordinator:[[ListMonsterAppDelegate sharedAppDelegate] persistentStoreCoordinator]];
    NSFetchRequest *fetchStashItems = [[NSFetchRequest alloc] init];
    NSEntityDescription *ed = [NSEntityDescription entityForName:@"ItemStash" inManagedObjectContext:ctx];
    [fetchStashItems setEntity:ed];
    NSError *error = nil;
    NSArray *stash = [ctx executeFetchRequest:fetchStashItems error:&error];
    if (error) {
        DLog(@"Unable to fetch stashed items", [error localizedDescription]);
        [fetchStashItems release];
        [ctx release];  // prof rcmd
        return;
    }
    [fetchStashItems release];
    NSPredicate *hasItemName = [NSPredicate predicateWithFormat:@"self.name == %@", [anItem name]];
    NSArray *exists = [stash filteredArrayUsingPredicate:hasItemName];
    ItemStash *stashItem = nil;
    if ([exists count] > 0) {
        stashItem = [exists objectAtIndex:0];
    } else {
        stashItem = [NSEntityDescription insertNewObjectForEntityForName:@"ItemStash" inManagedObjectContext:ctx];
        [stashItem setName:[anItem name]];
    }
    [stashItem setQuantity:[anItem quantity]];
    [stashItem setPriority:[anItem priority]];
    if ([anItem unitOfMeasure])
        [stashItem setUnitIdentifier:[[anItem unitOfMeasure] unitIdentifier]];
    error = nil;
    [ctx save:&error];
    if (error) {
        DLog(@"Unable to save item to stash: %@", [error localizedDescription]);
    }
    [ctx release];
}

+ (NSString *)nameForPriority:(NSNumber *)priority
{
    if (!priority)
        return nil;
    switch ([priority intValue]) {
        case 0:
            return @"Normal";            
        case 1: 
            return @"High";
        case -1:
            return @"Low";
    }
    return nil;
}



@end
