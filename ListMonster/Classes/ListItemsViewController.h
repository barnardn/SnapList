//
//  ListItemsViewController.h
//  ListMonster
//
//  Created by Norm Barnard on 2/13/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class MetaList;

@interface ListItemsViewController : UIViewController <UITableViewDataSource,
                                                       UITableViewDelegate, 
                                                       UIActionSheetDelegate>
{
    UITableView *allItemsTableView;
    UIToolbar *toolBar;
    UISegmentedControl *checkedState;
    UIBarButtonItem *addItemBtn;
    UIBarButtonItem *moreActionsBtn;
    UIBarButtonItem *editBtn;
    MetaList *theList;
    NSArray *listItems;
    BOOL inEditMode;
    UINavigationController *editItemNavController;
}

@property(nonatomic,retain) IBOutlet UITableView *allItemsTableView;
@property(nonatomic,retain) IBOutlet UIToolbar *toolBar;
@property(nonatomic,retain) IBOutlet UISegmentedControl *checkedState;
@property(nonatomic,retain) IBOutlet UIBarButtonItem *addItemBtn;
@property(nonatomic,retain) IBOutlet UIBarButtonItem *moreActionsBtn;
@property(nonatomic,retain) IBOutlet UIBarButtonItem *editBtn;
@property(nonatomic,retain) MetaList *theList;
@property(nonatomic,assign) BOOL inEditMode;
@property(nonatomic,retain) NSArray *listItems;

- (id)initWithList:(MetaList *)aList;
- (IBAction)addItemBtnPressed:(id)sender;
- (IBAction)moreActionsBtnPressed:(id)sender;
- (IBAction)checkedStateValueChanged:(id)sender;



@end
