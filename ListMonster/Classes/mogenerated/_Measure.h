// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Measure.h instead.

#import <CoreData/CoreData.h>


extern const struct MeasureAttributes {
	__unsafe_unretained NSString *isCustom;
	__unsafe_unretained NSString *isMetric;
	__unsafe_unretained NSString *measure;
	__unsafe_unretained NSString *sortOrder;
	__unsafe_unretained NSString *unit;
	__unsafe_unretained NSString *unitAbbreviation;
	__unsafe_unretained NSString *unitIdentifier;
} MeasureAttributes;

extern const struct MeasureRelationships {
	__unsafe_unretained NSString *items;
} MeasureRelationships;

extern const struct MeasureFetchedProperties {
} MeasureFetchedProperties;

@class MetaListItem;









@interface MeasureID : NSManagedObjectID {}
@end

@interface _Measure : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MeasureID*)objectID;




@property (nonatomic, strong) NSNumber* isCustom;


@property int16_t isCustomValue;
- (int16_t)isCustomValue;
- (void)setIsCustomValue:(int16_t)value_;

//- (BOOL)validateIsCustom:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* isMetric;


@property int16_t isMetricValue;
- (int16_t)isMetricValue;
- (void)setIsMetricValue:(int16_t)value_;

//- (BOOL)validateIsMetric:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* measure;


//- (BOOL)validateMeasure:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* sortOrder;


@property int16_t sortOrderValue;
- (int16_t)sortOrderValue;
- (void)setSortOrderValue:(int16_t)value_;

//- (BOOL)validateSortOrder:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* unit;


//- (BOOL)validateUnit:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* unitAbbreviation;


//- (BOOL)validateUnitAbbreviation:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* unitIdentifier;


@property int16_t unitIdentifierValue;
- (int16_t)unitIdentifierValue;
- (void)setUnitIdentifierValue:(int16_t)value_;

//- (BOOL)validateUnitIdentifier:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet* items;

- (NSMutableSet*)itemsSet;





@end

@interface _Measure (CoreDataGeneratedAccessors)

- (void)addItems:(NSSet*)value_;
- (void)removeItems:(NSSet*)value_;
- (void)addItemsObject:(MetaListItem*)value_;
- (void)removeItemsObject:(MetaListItem*)value_;

@end

@interface _Measure (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveIsCustom;
- (void)setPrimitiveIsCustom:(NSNumber*)value;

- (int16_t)primitiveIsCustomValue;
- (void)setPrimitiveIsCustomValue:(int16_t)value_;




- (NSNumber*)primitiveIsMetric;
- (void)setPrimitiveIsMetric:(NSNumber*)value;

- (int16_t)primitiveIsMetricValue;
- (void)setPrimitiveIsMetricValue:(int16_t)value_;




- (NSString*)primitiveMeasure;
- (void)setPrimitiveMeasure:(NSString*)value;




- (NSNumber*)primitiveSortOrder;
- (void)setPrimitiveSortOrder:(NSNumber*)value;

- (int16_t)primitiveSortOrderValue;
- (void)setPrimitiveSortOrderValue:(int16_t)value_;




- (NSString*)primitiveUnit;
- (void)setPrimitiveUnit:(NSString*)value;




- (NSString*)primitiveUnitAbbreviation;
- (void)setPrimitiveUnitAbbreviation:(NSString*)value;




- (NSNumber*)primitiveUnitIdentifier;
- (void)setPrimitiveUnitIdentifier:(NSNumber*)value;

- (int16_t)primitiveUnitIdentifierValue;
- (void)setPrimitiveUnitIdentifierValue:(int16_t)value_;





- (NSMutableSet*)primitiveItems;
- (void)setPrimitiveItems:(NSMutableSet*)value;


@end
