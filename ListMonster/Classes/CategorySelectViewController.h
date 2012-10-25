//
//  CategorySelectViewController.h
//  ListMonster
//
//  Created by Norm Barnard on 1/24/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "EditCategoryViewController.h"

@class ListCategory;
@class MetaList;

@interface CategorySelectViewController : UITableViewController <NSFetchedResultsControllerDelegate, EditCategoryDelegate> {
    
    MetaList *theList;
    NSFetchedResultsController *resultsController;
    ListCategory *theCategory;
    ListCategory *selectedCategory;
    NSIndexPath *lastSelectedIndexPath;
    
}

@property(nonatomic,strong) MetaList *theList;
@property(nonatomic,strong) NSFetchedResultsController *resultsController;
@property(nonatomic,strong) ListCategory *theCategory;
@property(nonatomic,strong) ListCategory *selectedCategory;
@property(nonatomic,strong) NSIndexPath *lastSelectedIndexPath;

- (id)initWithList:(MetaList *)aList;

@end
