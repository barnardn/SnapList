// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MetaListItem.m instead.

#import "_MetaListItem.h"

const struct MetaListItemAttributes MetaListItemAttributes = {
	.isChecked = @"isChecked",
	.isNew = @"isNew",
	.itemIdentity = @"itemIdentity",
	.name = @"name",
	.order = @"order",
	.priority = @"priority",
	.quantity = @"quantity",
	.reminderDate = @"reminderDate",
};

const struct MetaListItemRelationships MetaListItemRelationships = {
	.list = @"list",
	.unitOfMeasure = @"unitOfMeasure",
};

const struct MetaListItemFetchedProperties MetaListItemFetchedProperties = {
};

@implementation MetaListItemID
@end

@implementation _MetaListItem

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MetaListItem" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MetaListItem";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MetaListItem" inManagedObjectContext:moc_];
}

- (MetaListItemID*)objectID {
	return (MetaListItemID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"isCheckedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isChecked"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"isNewValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isNew"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"orderValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"order"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"priorityValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"priority"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic isChecked;



- (BOOL)isCheckedValue {
	NSNumber *result = [self isChecked];
	return [result boolValue];
}

- (void)setIsCheckedValue:(BOOL)value_ {
	[self setIsChecked:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsCheckedValue {
	NSNumber *result = [self primitiveIsChecked];
	return [result boolValue];
}

- (void)setPrimitiveIsCheckedValue:(BOOL)value_ {
	[self setPrimitiveIsChecked:[NSNumber numberWithBool:value_]];
}





@dynamic isNew;



- (BOOL)isNewValue {
	NSNumber *result = [self isNew];
	return [result boolValue];
}

- (void)setIsNewValue:(BOOL)value_ {
	[self setIsNew:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsNewValue {
	NSNumber *result = [self primitiveIsNew];
	return [result boolValue];
}

- (void)setPrimitiveIsNewValue:(BOOL)value_ {
	[self setPrimitiveIsNew:[NSNumber numberWithBool:value_]];
}





@dynamic itemIdentity;






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






@dynamic reminderDate;






@dynamic list;

	

@dynamic unitOfMeasure;

	






@end
