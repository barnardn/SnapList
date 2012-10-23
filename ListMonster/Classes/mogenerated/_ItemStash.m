// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ItemStash.m instead.

#import "_ItemStash.h"

const struct ItemStashAttributes ItemStashAttributes = {
	.name = @"name",
	.priority = @"priority",
	.quantity = @"quantity",
	.unitIdentifier = @"unitIdentifier",
};

const struct ItemStashRelationships ItemStashRelationships = {
};

const struct ItemStashFetchedProperties ItemStashFetchedProperties = {
};

@implementation ItemStashID
@end

@implementation _ItemStash

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"ItemStash" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"ItemStash";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"ItemStash" inManagedObjectContext:moc_];
}

- (ItemStashID*)objectID {
	return (ItemStashID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"priorityValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"priority"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"unitIdentifierValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"unitIdentifier"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic name;






@dynamic priority;



- (int16_t)priorityValue {
	NSNumber *result = [self priority];
	return [result shortValue];
}

- (void)setPriorityValue:(int16_t)value_ {
	[self setPriority:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitivePriorityValue {
	NSNumber *result = [self primitivePriority];
	return [result shortValue];
}

- (void)setPrimitivePriorityValue:(int16_t)value_ {
	[self setPrimitivePriority:[NSNumber numberWithShort:value_]];
}





@dynamic quantity;






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










@end
