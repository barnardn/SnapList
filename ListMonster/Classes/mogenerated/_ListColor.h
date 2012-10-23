// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ListColor.h instead.

#import <CoreData/CoreData.h>


extern const struct ListColorAttributes {
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *rgbValue;
	__unsafe_unretained NSString *swatchFilename;
} ListColorAttributes;

extern const struct ListColorRelationships {
	__unsafe_unretained NSString *list;
} ListColorRelationships;

extern const struct ListColorFetchedProperties {
} ListColorFetchedProperties;

@class MetaList;





@interface ListColorID : NSManagedObjectID {}
@end

@interface _ListColor : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ListColorID*)objectID;




@property (nonatomic, strong) NSString* name;


//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* rgbValue;


@property int32_t rgbValueValue;
- (int32_t)rgbValueValue;
- (void)setRgbValueValue:(int32_t)value_;

//- (BOOL)validateRgbValue:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* swatchFilename;


//- (BOOL)validateSwatchFilename:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet* list;

- (NSMutableSet*)listSet;





@end

@interface _ListColor (CoreDataGeneratedAccessors)

- (void)addList:(NSSet*)value_;
- (void)removeList:(NSSet*)value_;
- (void)addListObject:(MetaList*)value_;
- (void)removeListObject:(MetaList*)value_;

@end

@interface _ListColor (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSNumber*)primitiveRgbValue;
- (void)setPrimitiveRgbValue:(NSNumber*)value;

- (int32_t)primitiveRgbValueValue;
- (void)setPrimitiveRgbValueValue:(int32_t)value_;




- (NSString*)primitiveSwatchFilename;
- (void)setPrimitiveSwatchFilename:(NSString*)value;





- (NSMutableSet*)primitiveList;
- (void)setPrimitiveList:(NSMutableSet*)value;


@end
