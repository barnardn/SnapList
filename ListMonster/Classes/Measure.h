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

@property (nonatomic, strong) NSString *measure;
@property (nonatomic, strong) NSString *unit;
@property (nonatomic, strong) NSString *unitAbbreviation;
@property (nonatomic, strong) NSNumber *isMetric;
@property (nonatomic, strong) NSNumber *isCustom;
@property (nonatomic, strong) NSNumber *sortOrder;
@property (nonatomic, strong) NSNumber *unitIdentifier;
@property (nonatomic, strong) NSSet *items;

+ (Measure *)findMatchingMeasure:(Measure *)measure inManagedObjectContext:(NSManagedObjectContext *)moc;
+ (Measure *)findMeasureMatchingIdentifier:(NSNumber *)identifier inManagedObjectContext:(NSManagedObjectContext *)moc;

- (BOOL)isMetricUnit;
- (BOOL)isCustomUnit;

@end
