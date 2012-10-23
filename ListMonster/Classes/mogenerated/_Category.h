// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Category.h instead.

#import <CoreData/CoreData.h>


extern const struct CategoryAttributes {
	__unsafe_unretained NSString *name;
} CategoryAttributes;

extern const struct CategoryRelationships {
	__unsafe_unretained NSString *list;
} CategoryRelationships;

extern const struct CategoryFetchedProperties {
} CategoryFetchedProperties;

@class MetaList;



@interface CategoryID : NSManagedObjectID {}
@end

@interface _Category : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CategoryID*)objectID;




@property (nonatomic, strong) NSString* name;


//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet* list;

- (NSMutableSet*)listSet;





@end

@interface _Category (CoreDataGeneratedAccessors)

- (void)addList:(NSSet*)value_;
- (void)removeList:(NSSet*)value_;
- (void)addListObject:(MetaList*)value_;
- (void)removeListObject:(MetaList*)value_;

@end

@interface _Category (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;





- (NSMutableSet*)primitiveList;
- (void)setPrimitiveList:(NSMutableSet*)value;


@end
