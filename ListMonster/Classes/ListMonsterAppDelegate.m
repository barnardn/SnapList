//
//  ListMonsterAppDelegate.m
//  ListMonster
//
//  Created by Norm Barnard on 12/27/10.
//  Copyright 2010 clamdango.com. All rights reserved.
//

#import "Alerts.h"
#import "ListCategory.h"
#import "datetime_utils.h"
#import "ListMonsterAppDelegate.h"
#import "MetaListItem.h"
#import "RootViewController.h"

static ListMonsterAppDelegate *appDelegateInstance;

@interface ListMonsterAppDelegate()

- (void)cancelRogueLocalNotifications;

@end

@implementation ListMonsterAppDelegate

@synthesize window, navController, allColors, cachedItems;

- (id)init {
    
    if (appDelegateInstance) {
        return appDelegateInstance;
    }
    self = [super init];
    appDelegateInstance = self;
    return self;
}

+ (ListMonsterAppDelegate *)sharedAppDelegate {
    return appDelegateInstance;
}

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{    
//    [self cancelRogueLocalNotifications];
    [self setCachedItems:[NSMutableDictionary dictionaryWithCapacity:0]];
    UILocalNotification *launchNotification = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];
    if (launchNotification) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_OVERDUE_ITEM object:nil];
    }
    RootViewController *rvc = [[RootViewController alloc] init];
    navController = [[UINavigationController alloc] initWithRootViewController:rvc];
      // profiler reccomendation
    [[self window] addSubview:[navController view]];
    [[self window] makeKeyAndVisible];
    return YES;
}

// TODO: alert should have a "view details" button and take the user to the 
// EditListItemView for that item
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_OVERDUE_ITEM object:nil];

}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_OVERDUE_ITEM object:nil];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application 
{
    [self flushCache];
}


#pragma mark -
#pragma mark Misc methods

- (NSString *)documentsFolder 
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = paths[0];
    return docPath;
}

- (void)cancelRogueLocalNotifications
{
    NSString *path = [NSString pathWithComponents:@[[self documentsFolder], @"rogue-notifications.dat"]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    }
}


#pragma mark -
#pragma mark core data methods

- (NSManagedObjectModel *)managedObjectModel 
{
    if (managedObjectModel) return managedObjectModel;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ListMonster" ofType:@"momd"];
    if (!path) {
        path = [[NSBundle mainBundle] pathForResource:@"ListMonster" ofType:@"mom"];
    }
    ZAssert(path != nil, @"Unable to find data model in main bundle");
    NSURL *url = [NSURL fileURLWithPath:path];
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:url];
    return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator 
{
    if (persistentStoreCoordinator) return persistentStoreCoordinator;
    
    NSFileManager *fileMan = [NSFileManager defaultManager];
    NSString *docFolder = [self documentsFolder];
    NSString *dbPath = [docFolder stringByAppendingPathComponent:@"listmonster.sqlite"];
    if (![fileMan fileExistsAtPath:dbPath]) {
        NSString *defaultDb = [[NSBundle mainBundle] pathForResource:@"listmonster" ofType:@"sqlite"];
        NSError *error = nil;
        if (defaultDb && ![fileMan copyItemAtPath:defaultDb toPath:dbPath error:&error]) {
            DLog(@"%@ Error copying file %@", [self class], error);
        }
    }
    NSURL *url = [NSURL fileURLWithPath:dbPath];
   NSDictionary *storeOptions = @{NSMigratePersistentStoresAutomaticallyOption: BOOL_OBJ(YES),
                                  NSInferMappingModelAutomaticallyOption: BOOL_OBJ(YES)};
    NSManagedObjectModel *mom = [self managedObjectModel];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    
    NSError *error = nil;
    if ([persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:storeOptions error:&error]) {
        return persistentStoreCoordinator;
    }
    persistentStoreCoordinator = nil;
    ZAssert(NO, @"Failed to initialize persistent store.");
    return nil;

}

- (NSManagedObjectContext *)managedObjectContext 
{
    if (managedObjectContext) return managedObjectContext;
    NSPersistentStoreCoordinator *psc = [self persistentStoreCoordinator];
    if (!psc) return nil;
    managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:psc];
    NSUndoManager *undoManager = [[NSUndoManager alloc] init];
    [managedObjectContext setUndoManager:undoManager];
    return managedObjectContext;
}

- (NSFetchedResultsController *)fetchedResultsControllerWithFetchRequest:(NSFetchRequest *)theRequest sectionNameKeyPath:(NSString *)sectionNameKeyPath 
{
    NSManagedObjectContext *moc = [self managedObjectContext];
    [NSFetchedResultsController deleteCacheWithName:@"ListMonster"];
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:theRequest 
                                                                          managedObjectContext:moc 
                                                                            sectionNameKeyPath:sectionNameKeyPath 
                                                                                     cacheName:@"ListMonster"];
    NSError *error = nil;
    BOOL ok = [frc performFetch:&error];
    if (!ok) {      // show an alert box or something here...
        DLog(@"Error fetching request: %@", [error localizedDescription]);
    }
    return frc;
}

- (NSArray *)fetchAllInstancesOf:(NSString *)entityName orderedBy:(NSString *)attributeName 
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"Deprecated method %@",NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (NSArray *)fetchAllInstancesOf:(NSString *)entityName sortDescriptors:(NSArray *)sortDescriptors 
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"Deprecated method %@",NSStringFromSelector(_cmd)]
                                 userInfo:nil];
    
}

- (NSArray *)fetchAllInstancesOf:(NSString *)entityName sortDescriptors:(NSArray *)sortDescriptors filteredBy:(NSPredicate *)filter 
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"Deprecated method %@",NSStringFromSelector(_cmd)]
                                 userInfo:nil];    
}

#pragma mark - Cache methods

- (void)addCacheObject:(id)object withKey:(NSString *)key
{
    [self cachedItems][key] = object;
}
- (void)deleteCacheObjectForKey:(NSString *)key
{
    [[self cachedItems] removeObjectForKey:key];
}
- (id)cacheObjectForKey:(NSString *)key
{
    return [self cachedItems][key];
}
- (void)flushCache
{
    [[self cachedItems] removeAllObjects];
}


@end
