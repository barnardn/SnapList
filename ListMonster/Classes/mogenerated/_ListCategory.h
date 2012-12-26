// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ListCategory.h instead.

#import <CoreData/CoreData.h>


extern const struct ListCategoryAttributes {
	__unsafe_unretained NSString *isNew;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *order;
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




@property (nonatomic, strong) NSNumber* isNew;


@property BOOL isNewValue;
- (BOOL)isNewValue;
- (void)setIsNewValue:(BOOL)value_;

//- (BOOL)validateIsNew:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* name;


//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* order;


@property int16_t orderValue;
- (int16_t)orderValue;
- (void)setOrderValue:(int16_t)value_;

//- (BOOL)validateOrder:(id*)value_ error:(NSError**)error_;





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


- (NSNumber*)primitiveIsNew;
- (void)setPrimitiveIsNew:(NSNumber*)value;

- (BOOL)primitiveIsNewValue;
- (void)setPrimitiveIsNewValue:(BOOL)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSNumber*)primitiveOrder;
- (void)setPrimitiveOrder:(NSNumber*)value;

- (int16_t)primitiveOrderValue;
- (void)setPrimitiveOrderValue:(int16_t)value_;





- (NSMutableSet*)primitiveList;
- (void)setPrimitiveList:(NSMutableSet*)value;


@end
