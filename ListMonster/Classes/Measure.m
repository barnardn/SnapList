//
//  Measure.m
//  ListMonster
//
//  Created by Norm Barnard on 10/25/11.
//  Copyright (c) 2011 clamdango.com. All rights reserved.
//

#import "ListMonsterAppDelegate.h"
#import "Measure.h"
#import "MetaListItem.h"


@implementation Measure

@dynamic measure;
@dynamic isCustom;
@dynamic unit;
@dynamic unitAbbreviation;
@dynamic isMetric;
@dynamic sortOrder;
@dynamic unitIdentifier;
@dynamic items;

+ (Measure *)findMatchingMeasure:(Measure *)measure inManagedObjectContext:(NSManagedObjectContext *)moc
{
    NSFetchRequest *matchingUnitFetch = [[[NSFetchRequest alloc] init] autorelease];
    [matchingUnitFetch setEntity:[NSEntityDescription entityForName:@"Measure" inManagedObjectContext:moc]];
    NSPredicate *byMatchingMeasure = [NSPredicate predicateWithFormat:@"unitIdentifier = %d", [measure unitIdentifier]];
    [matchingUnitFetch setPredicate:byMatchingMeasure];
    NSError *error = nil;
    NSArray *soughtMeasure = [moc executeFetchRequest:matchingUnitFetch error:&error];
    if (error) {
        DLog(@"Unable to fetch a meatching measure items", [error localizedDescription]);
        return nil;
    }
    return ([soughtMeasure count]) ? [soughtMeasure objectAtIndex:0] : nil;
}

+ (Measure *)findMeasureMatchingIdentifier:(NSNumber *)identifier inManagedObjectContext:(NSManagedObjectContext *)moc
{
    NSFetchRequest *matchingUnitFetch = [[[NSFetchRequest alloc] init] autorelease];
    if (!moc)
        moc = [[ListMonsterAppDelegate sharedAppDelegate] managedObjectContext];
    [matchingUnitFetch setEntity:[NSEntityDescription entityForName:@"Measure" inManagedObjectContext:moc]];
    NSPredicate *byMatchingMeasure = [NSPredicate predicateWithFormat:@"unitIdentifier = %@", identifier];
    [matchingUnitFetch setPredicate:byMatchingMeasure];
    NSError *error = nil;
    NSArray *soughtMeasure = [moc executeFetchRequest:matchingUnitFetch error:&error];
    if (error) {
        DLog(@"Unable to fetch a meatching measure items", [error localizedDescription]);
        return nil;
    }
    return ([soughtMeasure count]) ? [soughtMeasure objectAtIndex:0] : nil;

}

- (BOOL) isMetricUnit
{
    if (![self isMetric]) return NO;
    return (1 == [[self isMetric] intValue]);
}

 - (BOOL)isCustomUnit
{
    if (![self isCustom]) return NO;
    return (1 == [[self isCustom] intValue]);
}

@end
