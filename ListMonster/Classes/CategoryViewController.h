//
//  CategoryViewController.h
//  ListMonster
//
//  Created by Norm Barnard on 1/20/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Category;

@interface CategoryViewController : UITableViewController {

    NSMutableArray *allCategories;
    Category *selectedCategory;
}

@property (nonatomic,retain) NSMutableArray *allCategories;
@property (nonatomic,retain) Category *selectedCategory;

- (id)initWithCategory:(Category *)aCategory;
- (Category *)returnValue;

@end
