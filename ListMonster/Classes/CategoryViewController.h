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
}

@property (nonatomic,retain) NSMutableArray *allCategories;

@end
