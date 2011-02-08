//
//  CategorySelectViewController.h
//  ListMonster
//
//  Created by Norm Barnard on 1/24/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class Category;
@class MetaList;

@interface CategorySelectViewController : UITableViewController {
    
    NSArray *allCategories;
    MetaList *theList;
    Category *selectedCategory;
}

@property(nonatomic,retain) NSArray *allCategories;
@property(nonatomic,retain) MetaList *theList;
@property(nonatomic,retain) Category *selectedCategory;

- (id)initWithList:(MetaList *)aList;

@end
