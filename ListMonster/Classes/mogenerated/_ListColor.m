// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ListColor.m instead.

#import "_ListColor.h"

const struct ListColorAttributes ListColorAttributes = {
	.name = @"name",
	.rgbValue = @"rgbValue",
	.swatchFilename = @"swatchFilename",
};

const struct ListColorRelationships ListColorRelationships = {
	.list = @"list",
};

const struct ListColorFetchedProperties ListColorFetchedProperties = {
};

@implementation ListColorID
@end

@implementation _ListColor

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"ListColor" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"ListColor";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"ListColor" inManagedObjectContext:moc_];
}

- (ListColorID*)objectID {
	return (ListColorID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"rgbValueValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"rgbValue"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic name;






@dynamic rgbValue;



- (int32_t)rgbValueValue {
	NSNumber *result = [self rgbValue];
	return [result intValue];
}

- (void)setRgbValueValue:(int32_t)value_ {
	[self setRgbValue:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveRgbValueValue {
	NSNumber *result = [self primitiveRgbValue];
	return [result intValue];
}

- (void)setPrimitiveRgbValueValue:(int32_t)value_ {
	[self setPrimitiveRgbValue:[NSNumber numberWithInt:value_]];
}





@dynamic swatchFilename;






@dynamic list;

	
- (NSMutableSet*)listSet {
	[self willAccessValueForKey:@"list"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"list"];
  
	[self didAccessValueForKey:@"list"];
	return result;
}
	






@end
