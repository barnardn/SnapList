// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MetaList.h instead.

#import <CoreData/CoreData.h>


extern const struct MetaListAttributes {
	__unsafe_unretained NSString *dateCreated;
	__unsafe_unretained NSString *listID;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *note;
	__unsafe_unretained NSString *order;
	__unsafe_unretained NSString *tintColor;
} MetaListAttributes;

extern const struct MetaListRelationships {
	__unsafe_unretained NSString *category;
	__unsafe_unretained NSString *items;
} MetaListRelationships;

extern const struct MetaListFetchedProperties {
} MetaListFetchedProperties;

@class ListCategory;
@class MetaListItem;








@interface MetaListID : NSManagedObjectID {}
@end

@interface _MetaList : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MetaListID*)objectID;




@property (nonatomic, strong) NSDate* dateCreated;


//- (BOOL)validateDateCreated:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* listID;


//- (BOOL)validateListID:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* name;


//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* note;


//- (BOOL)validateNote:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* order;


@property int16_t orderValue;
- (int16_t)orderValue;
- (void)setOrderValue:(int16_t)value_;

//- (BOOL)validateOrder:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* tintColor;


//- (BOOL)validateTintColor:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) ListCategory* category;

//- (BOOL)validateCategory:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet* items;

- (NSMutableSet*)itemsSet;





@end

@interface _MetaList (CoreDataGeneratedAccessors)

- (void)addItems:(NSSet*)value_;
- (void)removeItems:(NSSet*)value_;
- (void)addItemsObject:(MetaListItem*)value_;
- (void)removeItemsObject:(MetaListItem*)value_;

@end

@interface _MetaList (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveDateCreated;
- (void)setPrimitiveDateCreated:(NSDate*)value;




- (NSString*)primitiveListID;
- (void)setPrimitiveListID:(NSString*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSString*)primitiveNote;
- (void)setPrimitiveNote:(NSString*)value;




- (NSNumber*)primitiveOrder;
- (void)setPrimitiveOrder:(NSNumber*)value;

- (int16_t)primitiveOrderValue;
- (void)setPrimitiveOrderValue:(int16_t)value_;




- (NSString*)primitiveTintColor;
- (void)setPrimitiveTintColor:(NSString*)value;





- (ListCategory*)primitiveCategory;
- (void)setPrimitiveCategory:(ListCategory*)value;



- (NSMutableSet*)primitiveItems;
- (void)setPrimitiveItems:(NSMutableSet*)value;


@end
