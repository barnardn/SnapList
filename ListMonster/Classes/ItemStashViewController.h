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
    NSNumberFormatter *numFormatter;
    
}

@property(nonatomic,strong) IBOutlet UITableView *stashTableView;
@property(nonatomic,strong) IBOutlet UINavigationBar *navBar;
@property(nonatomic,strong) MetaList *theList;
@property(nonatomic,strong) NSFetchedResultsController *resultsController;
@property(nonatomic,strong) ItemStash *selectedItem;
@property(nonatomic,strong) NSString *backgroundImageFilename;

- (id)initWithList:(MetaList *)list;

@end
