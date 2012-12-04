//
//  DataManager.h
//  ListMonster
//
//  Created by Norm Barnard on 12/2/12.
//
//

#import <Foundation/Foundation.h>

@interface DataManager : NSObject

+ (NSArray *)fetchAllInstancesOf:(NSString *)entityName orderedBy:(NSString *)attributeName inContext:(NSManagedObjectContext *)moc;
+ (NSArray *)fetchAllInstancesOf:(NSString *)entityName sortDescriptors:(NSArray *)sortDescriptors inContext:(NSManagedObjectContext *)moc;
+ (NSArray *)fetchAllInstancesOf:(NSString *)entityName sortDescriptors:(NSArray *)sortDescriptors filteredBy:(NSPredicate *)filter inContext:(NSManagedObjectContext *)moc;

@end
