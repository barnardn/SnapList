// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ListCategory.m instead.

#import "_ListCategory.h"

const struct ListCategoryAttributes ListCategoryAttributes = {
	.name = @"name",
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
	

	return keyPaths;
}




@dynamic name;






@dynamic list;

	
- (NSMutableSet*)listSet {
	[self willAccessValueForKey:@"list"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"list"];
  
	[self didAccessValueForKey:@"list"];
	return result;
}
	






@end
