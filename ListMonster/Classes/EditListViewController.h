//
//  EditListViewController.h
//  ListMonster
//
//  Created by Norm Barnard on 1/17/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#define elvNUM_SECTIONS     5

@class MetaList;

@interface EditListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>


- (id)initWithList:(MetaList *)aList;

@end
