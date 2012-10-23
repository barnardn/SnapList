// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MetaList.m instead.

#import "_MetaList.h"

const struct MetaListAttributes MetaListAttributes = {
	.dateCreated = @"dateCreated",
	.listID = @"listID",
	.name = @"name",
	.note = @"note",
};

const struct MetaListRelationships MetaListRelationships = {
	.category = @"category",
	.color = @"color",
	.items = @"items",
};

const struct MetaListFetchedProperties MetaListFetchedProperties = {
};

@implementation MetaListID
@end

@implementation _MetaList

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MetaList" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MetaList";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MetaList" inManagedObjectContext:moc_];
}

- (MetaListID*)objectID {
	return (MetaListID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic dateCreated;






@dynamic listID;






@dynamic name;






@dynamic note;






@dynamic category;

	

@dynamic color;

	

@dynamic items;

	
- (NSMutableSet*)itemsSet {
	[self willAccessValueForKey:@"items"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"items"];
  
	[self didAccessValueForKey:@"items"];
	return result;
}
	






@end
