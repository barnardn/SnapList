//
//  EditListViewController.h
//  ListMonster
//
//  Created by Norm Barnard on 1/17/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class MetaList;

@interface EditListViewController : UITableViewController {

    MetaList *theList;
    NSArray *editablePropertyKeys;
    id selectedSubview;
    NSInteger editPropertyIndex;
}

@property(nonatomic,retain) MetaList *theList;
@property(nonatomic,retain) NSArray *editablePropertyKeys;  // order must match section index in table
@property(nonatomic,retain) id selectedSubview;

- (id)initWithList:(MetaList *)l;

@end
