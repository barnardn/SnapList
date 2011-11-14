//
//  Measure.h
//  ListMonster
//
//  Created by Norm Barnard on 10/25/11.
//  Copyright (c) 2011 clamdango.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MetaListItem;
@class Measure;

@interface Measure : NSManagedObject

@property (nonatomic, retain) NSString *measure;
@property (nonatomic, retain) NSString *unit;
@property (nonatomic, retain) NSString *unitAbbreviation;
@property (nonatomic, retain) NSNumber *isMetric;
@property (nonatomic, retain) NSNumber *sortOrder;
@property (nonatomic, retain) NSNumber *unitIdentifier;
@property (nonatomic, retain) NSSet *items;

+ (Measure *)findMatchingMeasure:(Measure *)measure inManagedObjectContext:(NSManagedObjectContext *)moc;
+ (Measure *)findMeasureMatchingIdentifier:(NSNumber *)identifier inManagedObjectContext:(NSManagedObjectContext *)moc;

- (BOOL) isMetricUnit;

@end
