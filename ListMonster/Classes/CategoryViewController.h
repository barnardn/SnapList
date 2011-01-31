//
//  CategoryViewController.h
//  ListMonster
//
//  Created by Norm Barnard on 1/20/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingViewProtocol.h"

@class Category;

@interface CategoryViewController : UITableViewController <SettingViewProtocol> {

    NSMutableArray *allCategories;
}

@property(nonatomic,retain) NSMutableArray *allCategories;

@end
