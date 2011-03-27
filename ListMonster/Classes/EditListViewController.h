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
    BOOL editActionCancelled;
    BOOL isNewList;
    NSString *notificationMessage;
}

@property(nonatomic,retain) MetaList *theList;
@property(nonatomic,assign) BOOL editActionCancelled;
@property(nonatomic,assign) BOOL isNewList;
@property(nonatomic,retain) NSString *notificationMessage;

- (id)initWithList:(MetaList *)aList;

@end
