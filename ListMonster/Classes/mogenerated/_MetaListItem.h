// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MetaListItem.h instead.

#import <CoreData/CoreData.h>


extern const struct MetaListItemAttributes {
	__unsafe_unretained NSString *isChecked;
	__unsafe_unretained NSString *isNew;
	__unsafe_unretained NSString *itemIdentity;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *priority;
	__unsafe_unretained NSString *quantity;
	__unsafe_unretained NSString *reminderDate;
} MetaListItemAttributes;

extern const struct MetaListItemRelationships {
	__unsafe_unretained NSString *list;
	__unsafe_unretained NSString *unitOfMeasure;
} MetaListItemRelationships;

extern const struct MetaListItemFetchedProperties {
} MetaListItemFetchedProperties;

@class MetaList;
@class Measure;









@interface MetaListItemID : NSManagedObjectID {}
@end

@interface _MetaListItem : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MetaListItemID*)objectID;




@property (nonatomic, strong) NSNumber* isChecked;


@property BOOL isCheckedValue;
- (BOOL)isCheckedValue;
- (void)setIsCheckedValue:(BOOL)value_;

//- (BOOL)validateIsChecked:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* isNew;


@property BOOL isNewValue;
- (BOOL)isNewValue;
- (void)setIsNewValue:(BOOL)value_;

//- (BOOL)validateIsNew:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* itemIdentity;


//- (BOOL)validateItemIdentity:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* name;


//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* priority;


@property int16_t priorityValue;
- (int16_t)priorityValue;
- (void)setPriorityValue:(int16_t)value_;

//- (BOOL)validatePriority:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSDecimalNumber* quantity;


//- (BOOL)validateQuantity:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSDate* reminderDate;


//- (BOOL)validateReminderDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) MetaList* list;

//- (BOOL)validateList:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) Measure* unitOfMeasure;

//- (BOOL)validateUnitOfMeasure:(id*)value_ error:(NSError**)error_;





@end

@interface _MetaListItem (CoreDataGeneratedAccessors)

@end

@interface _MetaListItem (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveIsChecked;
- (void)setPrimitiveIsChecked:(NSNumber*)value;

- (BOOL)primitiveIsCheckedValue;
- (void)setPrimitiveIsCheckedValue:(BOOL)value_;




- (NSNumber*)primitiveIsNew;
- (void)setPrimitiveIsNew:(NSNumber*)value;

- (BOOL)primitiveIsNewValue;
- (void)setPrimitiveIsNewValue:(BOOL)value_;




- (NSString*)primitiveItemIdentity;
- (void)setPrimitiveItemIdentity:(NSString*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSNumber*)primitivePriority;
- (void)setPrimitivePriority:(NSNumber*)value;

- (int16_t)primitivePriorityValue;
- (void)setPrimitivePriorityValue:(int16_t)value_;




- (NSDecimalNumber*)primitiveQuantity;
- (void)setPrimitiveQuantity:(NSDecimalNumber*)value;




- (NSDate*)primitiveReminderDate;
- (void)setPrimitiveReminderDate:(NSDate*)value;





- (MetaList*)primitiveList;
- (void)setPrimitiveList:(MetaList*)value;



- (Measure*)primitiveUnitOfMeasure;
- (void)setPrimitiveUnitOfMeasure:(Measure*)value;


@end
