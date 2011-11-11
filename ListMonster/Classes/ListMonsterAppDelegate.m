//
//  ListMonsterAppDelegate.m
//  ListMonster
//
//  Created by Norm Barnard on 12/27/10.
//  Copyright 2010 clamdango.com. All rights reserved.
//

#import "Alerts.h"
#import "Category.h"
#import "datetime_utils.h"
#import "ListMonsterAppDelegate.h"
#import "MetaListItem.h"
#import "RootViewController.h"
#import "ListColor.h"

static ListMonsterAppDelegate *appDelegateInstance;

@interface ListMonsterAppDelegate()

- (void)prefetchListColors;
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
    [self cancelRogueLocalNotifications];
    [self setCachedItems:[NSMutableDictionary dictionaryWithCapacity:0]];
    UILocalNotification *launchNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (launchNotification) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_OVERDUE_ITEM object:nil];
    }
    [self prefetchListColors];
    RootViewController *rvc = [[RootViewController alloc] init];
    navController = [[UINavigationController alloc] initWithRootViewController:rvc];
    [rvc release];  // profiler reccomendation
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

- (void)dealloc 
{
    [window release];
    [navController release];
    [cachedItems release];
    [super dealloc];
}

#pragma mark -
#pragma mark Misc methods

- (NSString *)documentsFolder 
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [paths objectAtIndex:0];
    return docPath;
}

- (void)cancelRogueLocalNotifications
{
    NSString *path = [NSString pathWithComponents:[NSArray arrayWithObjects:[self documentsFolder], @"rogue-notifications.dat", nil]];
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
            DLog(@"%@:%s Error copying file %@", [self class], _cmd, error);
        }
    }
    NSURL *url = [NSURL fileURLWithPath:dbPath];
    NSManagedObjectModel *mom = [self managedObjectModel];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    NSError *error = nil;
    if ([persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:&error]) {
        return persistentStoreCoordinator;
    }
    [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
    NSDictionary *userInfo = [error userInfo];
    if (![userInfo valueForKey:NSDetailedErrorsKey]) {
        DLog(@"%@:%s Error adding store %@", [self class], _cmd, [error localizedDescription]);
    } else {
        for (NSError *subError in [userInfo valueForKey:NSDetailedErrorsKey]) {
            DLog(@"%@:%s Error: %@", [self class], _cmd, [subError localizedDescription]);
        }
    }
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
    [undoManager release];
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
    return [frc autorelease];
}

- (NSArray *)fetchAllInstancesOf:(NSString *)entityName orderedBy:(NSString *)attributeName 
{
    NSArray *sortDescriptors = nil;
    if (attributeName) {
        NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:attributeName ascending:YES];
        sortDescriptors = [NSArray arrayWithObject:sd];
        [sd release];
    }
    return [self fetchAllInstancesOf:entityName sortDescriptors:sortDescriptors];
}

- (NSArray *)fetchAllInstancesOf:(NSString *)entityName sortDescriptors:(NSArray *)sortDescriptors 
{
    return [self fetchAllInstancesOf:entityName sortDescriptors:sortDescriptors filteredBy:nil];
}

- (NSArray *)fetchAllInstancesOf:(NSString *)entityName sortDescriptors:(NSArray *)sortDescriptors filteredBy:(NSPredicate *)filter 
{
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSFetchRequest *fetchReq = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
    [fetchReq setEntity:entity];
    [fetchReq setSortDescriptors:sortDescriptors];
    [fetchReq setPredicate:filter];
    NSError *error = nil;
    NSArray *resultSet = [moc executeFetchRequest:fetchReq error:&error];
    [fetchReq release];
    if (!resultSet) {
        DLog(@"Error fetching all instances of %@", entityName);
    }
    return resultSet;
}

#pragma mark - Cache methods

- (void)addCacheObject:(id)object withKey:(NSString *)key
{
    [[self cachedItems] setObject:object forKey:key];
}
- (void)deleteCacheObjectForKey:(NSString *)key
{
    [[self cachedItems] removeObjectForKey:key];
}
- (id)cacheObjectForKey:(NSString *)key
{
    return [[self cachedItems] objectForKey:key];
}
- (void)flushCache
{
    [[self cachedItems] removeAllObjects];
}



#pragma mark -
#pragma mark Static data initializer methods

- (void)prefetchListColors 
{
    NSArray *colors = [self fetchAllInstancesOf:@"ListColor" orderedBy:nil];
    ZAssert(([colors count] != 0), @"ABORT:  No colors found in the database.");
    [self setAllColors:colors];
}

@end
