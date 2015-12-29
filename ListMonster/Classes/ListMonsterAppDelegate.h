//
//  ListMonsterAppDelegate.h
//  ListMonster
//
//  Created by Norm Barnard on 12/27/10.
//  Copyright 2010 clamdango.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface ListMonsterAppDelegate : NSObject <UIApplicationDelegate> 

@property(nonatomic, strong) UIWindow *window;
@property(nonatomic,strong) UINavigationController *navController;
@property(nonatomic,strong) NSArray *allColors;
@property(nonatomic,strong) NSMutableDictionary *cachedItems;
@property (strong, nonatomic,readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic,readonly) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic,readonly) NSManagedObjectContext *managedObjectContext;

- (NSString *)documentsFolder;

- (void)addCacheObject:(id)object withKey:(NSString *)key;
- (void)deleteCacheObjectForKey:(NSString *)key;
- (id)cacheObjectForKey:(NSString *)key;
- (void)flushCache;

+ (ListMonsterAppDelegate *)sharedAppDelegate;

@end

