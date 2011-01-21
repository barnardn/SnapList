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

@interface RootViewController : UITableViewController  {
    ListMonsterAppDelegate *appDelegate;
    NSFetchedResultsController *resultsController;
    
    UINavigationController *edListNav;
}

@property(nonatomic,assign) ListMonsterAppDelegate *appDelegate;
@property(nonatomic,retain) NSFetchedResultsController *resultsController;

@end
