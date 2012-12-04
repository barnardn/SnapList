//
//  DataManager.m
//  ListMonster
//
//  Created by Norm Barnard on 12/2/12.
//
//

#import "DataManager.h"
#import "ListMonsterAppDelegate.h"

@implementation DataManager

+ (NSArray *)fetchAllInstancesOf:(NSString *)entityName orderedBy:(NSString *)attributeName inContext:(NSManagedObjectContext *)moc
{
    NSArray *sortDescriptors = nil;
    if (attributeName) {
        NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:attributeName ascending:YES];
        sortDescriptors = @[sd];
    }
    return [DataManager fetchAllInstancesOf:entityName sortDescriptors:sortDescriptors inContext:moc];
}

+ (NSArray *)fetchAllInstancesOf:(NSString *)entityName sortDescriptors:(NSArray *)sortDescriptors inContext:(NSManagedObjectContext *)moc
{
    return [DataManager fetchAllInstancesOf:entityName sortDescriptors:sortDescriptors filteredBy:nil inContext:moc];
}

+ (NSArray *)fetchAllInstancesOf:(NSString *)entityName sortDescriptors:(NSArray *)sortDescriptors filteredBy:(NSPredicate *)filter inContext:(NSManagedObjectContext *)moc
{
    NSFetchRequest *fetchReq = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
    [fetchReq setEntity:entity];
    [fetchReq setSortDescriptors:sortDescriptors];
    [fetchReq setPredicate:filter];
    NSError *error = nil;
    NSArray *resultSet = [moc executeFetchRequest:fetchReq error:&error];
    if (!resultSet) {
        DLog(@"Error fetching all instances of %@", entityName);
    }
    return resultSet;
}


@end
