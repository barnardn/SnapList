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
    
}

@property(nonatomic,retain) MetaList *theList;


- (id)initWithList:(MetaList *)l;

@end
