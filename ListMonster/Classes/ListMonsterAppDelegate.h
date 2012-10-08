//
//  ListMonsterAppDelegate.h
//  ListMonster
//
//  Created by Norm Barnard on 12/27/10.
//  Copyright 2010 clamdango.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface ListMonsterAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    UINavigationController *navController;
    NSManagedObjectContext *managedObjectContext;
    NSManagedObjectModel *managedObjectModel;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSArray *allColors;
    NSMutableDictionary *cachedItems;
    
}

@property(nonatomic, strong) IBOutlet UIWindow *window;
@property(nonatomic,strong) UINavigationController *navController;
@property(nonatomic,strong) NSArray *allColors;
@property(nonatomic,strong) NSMutableDictionary *cachedItems;

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (NSManagedObjectModel *)managedObjectModel;
- (NSManagedObjectContext *)managedObjectContext;
- (NSFetchedResultsController *)fetchedResultsControllerWithFetchRequest:(NSFetchRequest *)theRequest sectionNameKeyPath:(NSString *)sectionNameKeyPath;
- (NSArray *)fetchAllInstancesOf:(NSString *)entityName orderedBy:(NSString *)attributeName;
- (NSArray *)fetchAllInstancesOf:(NSString *)entityName sortDescriptors:(NSArray *)sortDescriptors;
- (NSArray *)fetchAllInstancesOf:(NSString *)entityName sortDescriptors:(NSArray *)sortDescriptors filteredBy:(NSPredicate *)filter;
- (NSString *)documentsFolder;

- (void)addCacheObject:(id)object withKey:(NSString *)key;
- (void)deleteCacheObjectForKey:(NSString *)key;
- (id)cacheObjectForKey:(NSString *)key;
- (void)flushCache;

+ (ListMonsterAppDelegate *)sharedAppDelegate;

@end

