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

@interface CategorySelectViewController : UITableViewController {
    
    NSArray *allCategories;
    Category *selectedCategory;
}

@property(nonatomic, retain) NSArray *allCategories;
@property(nonatomic, retain) Category *selectedCategory;

- (id)initWithCategory:(Category *)defaultCategory;
- (Category *)returnValue;

@end
