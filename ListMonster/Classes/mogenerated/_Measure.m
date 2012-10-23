// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Measure.m instead.

#import "_Measure.h"

const struct MeasureAttributes MeasureAttributes = {
	.isCustom = @"isCustom",
	.isMetric = @"isMetric",
	.measure = @"measure",
	.sortOrder = @"sortOrder",
	.unit = @"unit",
	.unitAbbreviation = @"unitAbbreviation",
	.unitIdentifier = @"unitIdentifier",
};

const struct MeasureRelationships MeasureRelationships = {
	.items = @"items",
};

const struct MeasureFetchedProperties MeasureFetchedProperties = {
};

@implementation MeasureID
@end

@implementation _Measure

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Measure" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Measure";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Measure" inManagedObjectContext:moc_];
}

- (MeasureID*)objectID {
	return (MeasureID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"isCustomValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isCustom"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"isMetricValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isMetric"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"sortOrderValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"sortOrder"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"unitIdentifierValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"unitIdentifier"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic isCustom;



- (int16_t)isCustomValue {
	NSNumber *result = [self isCustom];
	return [result shortValue];
}

- (void)setIsCustomValue:(int16_t)value_ {
	[self setIsCustom:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveIsCustomValue {
	NSNumber *result = [self primitiveIsCustom];
	return [result shortValue];
}

- (void)setPrimitiveIsCustomValue:(int16_t)value_ {
	[self setPrimitiveIsCustom:[NSNumber numberWithShort:value_]];
}





@dynamic isMetric;



- (int16_t)isMetricValue {
	NSNumber *result = [self isMetric];
	return [result shortValue];
}

- (void)setIsMetricValue:(int16_t)value_ {
	[self setIsMetric:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveIsMetricValue {
	NSNumber *result = [self primitiveIsMetric];
	return [result shortValue];
}

- (void)setPrimitiveIsMetricValue:(int16_t)value_ {
	[self setPrimitiveIsMetric:[NSNumber numberWithShort:value_]];
}





@dynamic measure;






@dynamic sortOrder;



- (int16_t)sortOrderValue {
	NSNumber *result = [self sortOrder];
	return [result shortValue];
}

- (void)setSortOrderValue:(int16_t)value_ {
	[self setSortOrder:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveSortOrderValue {
	NSNumber *result = [self primitiveSortOrder];
	return [result shortValue];
}

- (void)setPrimitiveSortOrderValue:(int16_t)value_ {
	[self setPrimitiveSortOrder:[NSNumber numberWithShort:value_]];
}





@dynamic unit;






@dynamic unitAbbreviation;






@dynamic unitIdentifier;



- (int16_t)unitIdentifierValue {
	NSNumber *result = [self unitIdentifier];
	return [result shortValue];
}

- (void)setUnitIdentifierValue:(int16_t)value_ {
	[self setUnitIdentifier:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveUnitIdentifierValue {
	NSNumber *result = [self primitiveUnitIdentifier];
	return [result shortValue];
}

- (void)setPrimitiveUnitIdentifierValue:(int16_t)value_ {
	[self setPrimitiveUnitIdentifier:[NSNumber numberWithShort:value_]];
}





@dynamic items;

	
- (NSMutableSet*)itemsSet {
	[self willAccessValueForKey:@"items"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"items"];
  
	[self didAccessValueForKey:@"items"];
	return result;
}
	






@end
