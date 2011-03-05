//
//  ListMonsterAppDelegate.m
//  ListMonster
//
//  Created by Norm Barnard on 12/27/10.
//  Copyright 2010 clamdango.com. All rights reserved.
//

#import "Category.h"
#import "ListMonsterAppDelegate.h"
#import "RootViewController.h"
#import "SettingsViewController.h"
#import "ListColor.h"

static ListMonsterAppDelegate *appDelegateInstance;

@interface ListMonsterAppDelegate()

- (void)populateStaticData;
- (NSArray *)importColors;
- (void)importCategories;

@end



@implementation ListMonsterAppDelegate

@synthesize window, navController, allColors;

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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    [self populateStaticData];
    RootViewController *rvc = [[RootViewController alloc] init];
    navController = [[UINavigationController alloc] initWithRootViewController:rvc];
    [[self window] addSubview:[navController view]];
    [[self window] makeKeyAndVisible];
    return YES;
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
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}

- (void)dealloc {
    [window release];
    [navController release];
    [super dealloc];
}

#pragma mark -
#pragma mark Misc methods

- (NSString *)documentsFolder {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [paths objectAtIndex:0];
    return docPath;
}


#pragma mark -
#pragma mark core data methods

- (NSManagedObjectModel *)managedObjectModel {
    
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

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
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

- (NSManagedObjectContext *)managedObjectContext {
    
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

- (NSFetchedResultsController *)fetchedResultsControllerWithFetchRequest:(NSFetchRequest *)theRequest {
    
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:theRequest 
                                                                          managedObjectContext:moc 
                                                                            sectionNameKeyPath:nil 
                                                                                     cacheName:@"ListMonster"];
    NSError *error = nil;
    BOOL ok = [frc performFetch:&error];
    if (!ok) {      // show an alert box or something here...
        DLog(@"Error fetching request: %@", [error localizedDescription]);
    }
    return [frc autorelease];
}

- (NSArray *)fetchAllInstancesOf:(NSString *)entityName orderedBy:(NSString *)attributeName {
    
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSFetchRequest *fetchReq = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
    [fetchReq setEntity:entity];
    if (attributeName) {
        NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:attributeName ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sd];
        [fetchReq setSortDescriptors:sortDescriptors];
    }
    NSError *error = nil;
    NSArray *resultSet = [moc executeFetchRequest:fetchReq error:&error];
    [fetchReq release];
    if (!resultSet) {
        DLog(@"Error fetching all instances of %@ sorted by %@", entityName, attributeName);
    }
    return resultSet;
}

#pragma mark -
#pragma mark Static data initializer methods


- (void)populateStaticData {
    
    NSArray *colors = [self fetchAllInstancesOf:@"ListColor" orderedBy:nil];
    if ([colors count] == 0)
        colors = [self importColors];
    [self setAllColors:colors];
    
    NSArray *categories = [self fetchAllInstancesOf:@"Category" orderedBy:nil];
    if ([categories count] == 0)
        [self importCategories];
    
}

- (NSArray *)importColors {
    
    NSString *colorFile = [[NSBundle mainBundle] pathForResource:@"Colors" ofType:@"plist"];
    NSArray *defColors = [NSArray arrayWithContentsOfFile:colorFile];
    if ([defColors count] <= 0) return nil;
    
    NSMutableArray *colors = [NSMutableArray arrayWithCapacity:[defColors count]];
    NSEntityDescription *colorEntity = [NSEntityDescription entityForName:@"ListColor" inManagedObjectContext:[self managedObjectContext]];
    for (NSDictionary *colorDict in defColors) {
        ListColor *color = [[ListColor alloc] initWithEntity:colorEntity insertIntoManagedObjectContext:[self managedObjectContext]];
        [color setName:[colorDict valueForKey:@"colorName"]];
        [color setSwatchFilename:[colorDict valueForKey:@"swatchFilename"]];
        NSString *rgbStr = [colorDict valueForKey:@"rgbValue"];
        NSNumber *rgb = INT_OBJ([rgbStr intValue]);
        [color setRgbValue:rgb];
        [colors addObject:color];
        [color release];   
    }
    NSError *error = nil;
    [[self managedObjectContext] save:&error];
    if (error) {
        DLog(@"Unable to initialize colors entity: %@", [error localizedDescription]);
        return nil;
    }
    return colors;
}

- (void)importCategories {
    
    NSString *categoryFile = [[NSBundle mainBundle] pathForResource:@"Categories" ofType:@"plist"];
    NSArray *dfltCategories = [NSArray arrayWithContentsOfFile:categoryFile];
    if ([dfltCategories count] <= 0) return;
    
    NSEntityDescription *categoryEntity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:[self managedObjectContext]];
    for (NSString *catName in dfltCategories) {
        Category *category = [[Category alloc] initWithEntity:categoryEntity insertIntoManagedObjectContext:[self managedObjectContext]];
        [category setName:catName];
    }
    NSError *error = nil;
    [[self managedObjectContext] save:&error];
    if (error) {
        DLog(@"Unable to initialize default categories: %@", [error localizedDescription]);
    }
}


@end
