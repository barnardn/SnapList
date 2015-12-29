//
//  ListMonsterAppDelegate.m
//  ListMonster
//
//  Created by Norm Barnard on 12/27/10.
//  Copyright 2010 clamdango.com. All rights reserved.
//

#import "ListCategory.h"
#import "datetime_utils.h"
#import "ListMonsterAppDelegate.h"
#import "MetaListItem.h"
#import "RootViewController.h"

//static ListMonsterAppDelegate *appDelegateInstance;

@interface ListMonsterAppDelegate()


@property (strong, nonatomic,readwrite) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic,readwrite) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic,readwrite) NSManagedObjectContext *managedObjectContext;

@end

@implementation ListMonsterAppDelegate

+ (ListMonsterAppDelegate *)sharedAppDelegate
{
    static ListMonsterAppDelegate *staticInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticInstance = [[[self class] alloc] init];
    });
    return staticInstance;
}

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{    
    [self setCachedItems:[NSMutableDictionary dictionaryWithCapacity:0]];
    UILocalNotification *launchNotification = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];
    if (launchNotification) {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    }
    RootViewController *rvc = [[RootViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:rvc];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window setRootViewController:navController];
    [[self window] makeKeyAndVisible];
    return YES;
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
    if (_managedObjectModel) return _managedObjectModel;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ListMonster" ofType:@"momd"];
    if (!path) {
        path = [[NSBundle mainBundle] pathForResource:@"ListMonster" ofType:@"mom"];
    }
    ZAssert(path != nil, @"Unable to find data model in main bundle");
    NSURL *url = [NSURL fileURLWithPath:path];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:url];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator 
{
    if (_persistentStoreCoordinator) return _persistentStoreCoordinator;
    
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
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    
    NSError *error = nil;
    if ([self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:storeOptions error:&error]) {
        return _persistentStoreCoordinator;
    }
    _persistentStoreCoordinator = nil;
    ZAssert(NO, @"Failed to initialize persistent store.");
    return nil;

}

- (NSManagedObjectContext *)managedObjectContext 
{
    if (_managedObjectContext) return _managedObjectContext;
    NSPersistentStoreCoordinator *psc = [self persistentStoreCoordinator];
    if (!psc) return nil;
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:psc];
    NSUndoManager *undoManager = [[NSUndoManager alloc] init];
    [_managedObjectContext setUndoManager:undoManager];
    return _managedObjectContext;
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
