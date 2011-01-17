//
//  RootViewController.h
//  ListMonster
//
//  Created by Norm Barnard on 12/27/10.
//  Copyright 2010 clamdango.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ListEditViewController.h"

@class ListMonsterAppDelegate;

@interface RootViewController : UITableViewController <ListEditProtocol> {
    ListMonsterAppDelegate *appDelegate;
    NSFetchedResultsController *resultsController;
}

@property(nonatomic,assign) ListMonsterAppDelegate *appDelegate;
@property(nonatomic,retain) NSFetchedResultsController *resultsController;

@end
