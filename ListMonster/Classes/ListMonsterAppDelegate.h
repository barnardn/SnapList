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
    
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic,retain) UINavigationController *navController;
@property (nonatomic,retain) NSArray *allColors;

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (NSManagedObjectModel *)managedObjectModel;
- (NSManagedObjectContext *)managedObjectContext;
- (NSFetchedResultsController *)fetchedResultsControllerWithFetchRequest:(NSFetchRequest *)theRequest;
- (NSArray *)fetchAllInstancesOf:(NSString *)entityName orderedBy:(NSString *)attributeName;

- (NSString *)documentsFolder;

+ (ListMonsterAppDelegate *)sharedAppDelegate;

@end

