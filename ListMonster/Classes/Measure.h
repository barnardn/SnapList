//
//  Measure.h
//  ListMonster
//
//  Created by Norm Barnard on 10/25/11.
//  Copyright (c) 2011 clamdango.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "_Measure.h"

@class MetaListItem;
@class Measure;

@interface Measure : _Measure

+ (Measure *)findMatchingMeasure:(Measure *)measure inManagedObjectContext:(NSManagedObjectContext *)moc;
+ (Measure *)findMeasureMatchingIdentifier:(NSNumber *)identifier inManagedObjectContext:(NSManagedObjectContext *)moc;

- (BOOL)isMetricUnit;
- (BOOL)isCustomUnit;

@end
