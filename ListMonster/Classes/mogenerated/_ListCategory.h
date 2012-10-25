// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ListCategory.h instead.

#import <CoreData/CoreData.h>


extern const struct ListCategoryAttributes {
	__unsafe_unretained NSString *name;
} ListCategoryAttributes;

extern const struct ListCategoryRelationships {
	__unsafe_unretained NSString *list;
} ListCategoryRelationships;

extern const struct ListCategoryFetchedProperties {
} ListCategoryFetchedProperties;

@class MetaList;



@interface ListCategoryID : NSManagedObjectID {}
@end

@interface _ListCategory : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ListCategoryID*)objectID;




@property (nonatomic, strong) NSString* name;


//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet* list;

- (NSMutableSet*)listSet;





@end

@interface _ListCategory (CoreDataGeneratedAccessors)

- (void)addList:(NSSet*)value_;
- (void)removeList:(NSSet*)value_;
- (void)addListObject:(MetaList*)value_;
- (void)removeListObject:(MetaList*)value_;

@end

@interface _ListCategory (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;





- (NSMutableSet*)primitiveList;
- (void)setPrimitiveList:(NSMutableSet*)value;


@end
