//
//  ItemStashViewController.h
//  ListMonster
//
//  Created by Norm Barnard on 4/11/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class MetaList;
@class ItemStash;

@interface ItemStashViewController : UIViewController <UITableViewDataSource, 
                                                       UITableViewDelegate, 
                                                       NSFetchedResultsControllerDelegate> 
{
    UITableView *stashTableView;
    UINavigationBar *navBar;
    MetaList *theList;
    NSFetchedResultsController *resultsController;
    ItemStash *selectedItem;
    
}

@property(nonatomic,retain) IBOutlet UITableView *stashTableView;
@property(nonatomic,retain) IBOutlet UINavigationBar *navBar;
@property(nonatomic,retain) MetaList *theList;
@property(nonatomic,retain) NSFetchedResultsController *resultsController;
@property(nonatomic,retain) ItemStash *selectedItem;
@property(nonatomic,retain) NSString *backgroundImageFilename;

- (id)initWithList:(MetaList *)list;

@end
