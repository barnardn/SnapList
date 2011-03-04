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

@class Category;
@class MetaList;

@interface CategorySelectViewController : UITableViewController <NSFetchedResultsControllerDelegate, EditCategoryDelegate> {
    
    MetaList *theList;
    NSFetchedResultsController *resultsController;
    Category *newCategory;
}

@property(nonatomic,retain) MetaList *theList;
@property(nonatomic,retain) NSFetchedResultsController *resultsController;
@property(nonatomic,retain) Category *newCategory;

- (id)initWithList:(MetaList *)aList;

@end
