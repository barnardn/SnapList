// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ListCategory.m instead.

#import "_ListCategory.h"

const struct ListCategoryAttributes ListCategoryAttributes = {
	.name = @"name",
	.order = @"order",
};

const struct ListCategoryRelationships ListCategoryRelationships = {
	.list = @"list",
};

const struct ListCategoryFetchedProperties ListCategoryFetchedProperties = {
};

@implementation ListCategoryID
@end

@implementation _ListCategory

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"ListCategory" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"ListCategory";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"ListCategory" inManagedObjectContext:moc_];
}

- (ListCategoryID*)objectID {
	return (ListCategoryID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"orderValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"order"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic name;






@dynamic order;



- (int16_t)orderValue {
	NSNumber *result = [self order];
	return [result shortValue];
}

- (void)setOrderValue:(int16_t)value_ {
	[self setOrder:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveOrderValue {
	NSNumber *result = [self primitiveOrder];
	return [result shortValue];
}

- (void)setPrimitiveOrderValue:(int16_t)value_ {
	[self setPrimitiveOrder:[NSNumber numberWithShort:value_]];
}





@dynamic list;

	
- (NSMutableSet*)listSet {
	[self willAccessValueForKey:@"list"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"list"];
  
	[self didAccessValueForKey:@"list"];
	return result;
}
	






@end
