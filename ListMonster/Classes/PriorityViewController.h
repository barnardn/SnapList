//
//  PriorityViewController.h
//  ListMonster
//
//  Created by Norm Barnard on 7/5/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditItemViewProtocol.h"

@class MetaListItem;

@interface PriorityViewController : UITableViewController <EditItemViewProtocol> {
    NSIndexPath *lastIndexPath;
    MetaListItem *theItem;
}

@property(nonatomic,strong) NSArray *priorityList;
@property(nonatomic,strong) MetaListItem *theItem;
@property(nonatomic,strong) NSString *backgroundImageFilename;
@property(nonatomic,strong) NSIndexPath *lastIndexPath;

-(id)initWithTitle:(NSString *)title listItem:(MetaListItem *)anItem;
@end
