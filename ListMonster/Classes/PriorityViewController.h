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

@property(nonatomic,retain) NSArray *priorityList;
@property(nonatomic,retain) MetaListItem *theItem;
@property(nonatomic,retain) NSString *backgroundImageFilename;
@property(nonatomic,retain) NSIndexPath *lastIndexPath;

-(id)initWithTitle:(NSString *)title listItem:(MetaListItem *)anItem;
@end
