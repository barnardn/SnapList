// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MetaList.h instead.

#import <CoreData/CoreData.h>


extern const struct MetaListAttributes {
	__unsafe_unretained NSString *dateCreated;
	__unsafe_unretained NSString *listID;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *note;
} MetaListAttributes;

extern const struct MetaListRelationships {
	__unsafe_unretained NSString *category;
	__unsafe_unretained NSString *color;
	__unsafe_unretained NSString *items;
} MetaListRelationships;

extern const struct MetaListFetchedProperties {
} MetaListFetchedProperties;

@class Category;
@class ListColor;
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





@property (nonatomic, strong) Category* category;

//- (BOOL)validateCategory:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) ListColor* color;

//- (BOOL)validateColor:(id*)value_ error:(NSError**)error_;




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





- (Category*)primitiveCategory;
- (void)setPrimitiveCategory:(Category*)value;



- (ListColor*)primitiveColor;
- (void)setPrimitiveColor:(ListColor*)value;



- (NSMutableSet*)primitiveItems;
- (void)setPrimitiveItems:(NSMutableSet*)value;


@end
