//
//  EditListItemViewController.h
//  ListMonster
//
//  Created by Norm Barnard on 2/13/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class MetaList;
@class MetaListItem;
@class EditTextViewController;

@interface NewListItemViewController : UITableViewController {

    MetaList *theList;
    NSArray *itemProperties;
    NSInteger editPropertyIndex;
    EditTextViewController *editViewController;
    BOOL hasDirtyProperties;
}

@property(nonatomic,retain) MetaList *theList;
@property(nonatomic,retain) NSArray *itemProperties;
@property(nonatomic,assign) NSInteger editPropertyIndex;
@property(nonatomic,retain) EditTextViewController *editViewController;
@property(nonatomic,assign) BOOL hasDirtyProperties;

- (id)initWithList:(MetaList *)list;


@end
