//
//  RootViewController.h
//  ListMonster
//
//  Created by Norm Barnard on 12/27/10.
//  Copyright 2010 clamdango.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class ListMonsterAppDelegate;
@class MetaList;

@interface RootViewController : UITableViewController  {

    NSMutableDictionary *allLists;
    NSArray *categoryNameKeys;
    UINavigationController *edListNav;
    NSMutableArray *overdueItems;
}

@property(nonatomic,strong) NSMutableDictionary *allLists;
@property(nonatomic,strong) NSArray *categoryNameKeys;
@property(nonatomic,strong) NSMutableArray *overdueItems;

@end
