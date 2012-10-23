// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ItemStash.h instead.

#import <CoreData/CoreData.h>


extern const struct ItemStashAttributes {
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *priority;
	__unsafe_unretained NSString *quantity;
	__unsafe_unretained NSString *unitIdentifier;
} ItemStashAttributes;

extern const struct ItemStashRelationships {
} ItemStashRelationships;

extern const struct ItemStashFetchedProperties {
} ItemStashFetchedProperties;







@interface ItemStashID : NSManagedObjectID {}
@end

@interface _ItemStash : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ItemStashID*)objectID;




@property (nonatomic, strong) NSString* name;


//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* priority;


@property int16_t priorityValue;
- (int16_t)priorityValue;
- (void)setPriorityValue:(int16_t)value_;

//- (BOOL)validatePriority:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSDecimalNumber* quantity;


//- (BOOL)validateQuantity:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* unitIdentifier;


@property int16_t unitIdentifierValue;
- (int16_t)unitIdentifierValue;
- (void)setUnitIdentifierValue:(int16_t)value_;

//- (BOOL)validateUnitIdentifier:(id*)value_ error:(NSError**)error_;






@end

@interface _ItemStash (CoreDataGeneratedAccessors)

@end

@interface _ItemStash (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSNumber*)primitivePriority;
- (void)setPrimitivePriority:(NSNumber*)value;

- (int16_t)primitivePriorityValue;
- (void)setPrimitivePriorityValue:(int16_t)value_;




- (NSDecimalNumber*)primitiveQuantity;
- (void)setPrimitiveQuantity:(NSDecimalNumber*)value;




- (NSNumber*)primitiveUnitIdentifier;
- (void)setPrimitiveUnitIdentifier:(NSNumber*)value;

- (int16_t)primitiveUnitIdentifierValue;
- (void)setPrimitiveUnitIdentifierValue:(int16_t)value_;




@end
