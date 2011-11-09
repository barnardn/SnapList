//
//  Measure.m
//  ListMonster
//
//  Created by Norm Barnard on 10/25/11.
//  Copyright (c) 2011 clamdango.com. All rights reserved.
//

#import "Measure.h"
#import "MetaListItem.h"


@implementation Measure

@dynamic measure;
@dynamic unit;
@dynamic unitAbbreviation;
@dynamic isMetric;
@dynamic sortOrder;

@dynamic itemStash;
@dynamic items;


+ (Measure *)findMatchingMeasure:(Measure *)measure inManagedObjectContext:(NSManagedObjectContext *)moc
{
    NSFetchRequest *matchingUnitFetch = [[[NSFetchRequest alloc] init] autorelease];
    [matchingUnitFetch setEntity:[NSEntityDescription entityForName:@"Measure" inManagedObjectContext:moc]];
    NSPredicate *byMatchingMeasure = [NSPredicate predicateWithFormat:@"isMetric == %@ and unit == %@ and measure == %@", 
                                      [measure isMetric],[measure unit], [measure measure]];
    [matchingUnitFetch setPredicate:byMatchingMeasure];
    NSError *error = nil;
    NSArray *soughtMeasure = [moc executeFetchRequest:matchingUnitFetch error:&error];
    if (error) {
        DLog(@"Unable to fetch a meatching measure items", [error localizedDescription]);
        [matchingUnitFetch release];
        return nil;
    }
    return ([soughtMeasure count]) ? [soughtMeasure objectAtIndex:0] : nil;
}

@end
