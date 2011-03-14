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

    NSDictionary *allLists;
    NSArray *categoryNameKeys;
    UINavigationController *edListNav;
}

@property(nonatomic,retain) NSDictionary *allLists;
@property(nonatomic,retain) NSArray *categoryNameKeys;

@end
