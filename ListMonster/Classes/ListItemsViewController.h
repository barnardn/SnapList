//
//  ListItemsViewController.h
//  ListMonster
//
//  Created by Norm Barnard on 2/13/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#define livcSEGMENT_UNCHECKED   0
#define livcSEGMENT_CHECKED     1
#define livcSEGMENT_VIEW_TAG    1001

@class MetaList;
@class MetaListItem;
@class EditListItemViewController;

@protocol ListItemsViewControllerProtocol

-(void)editListItemViewController:(EditListItemViewController *)editListItemViewController didCancelEditOnNewItem:(MetaListItem *)item;
-(void)editListItemViewController:(EditListItemViewController *)editListItemViewController didAddNewItem:(MetaListItem *)item;

@end


@interface ListItemsViewController : UIViewController <UITableViewDataSource,
                                                       UITableViewDelegate, 
                                                       UIActionSheetDelegate,
                                                       ListItemsViewControllerProtocol>
{
    UITableView *allItemsTableView;
    UIToolbar *toolBar;
    UISegmentedControl *checkedState;
    UIBarButtonItem *addItemBtn;
    UIBarButtonItem *moreActionsBtn;
    UIBarButtonItem *editBtn;
    MetaList *theList;
    NSMutableArray *listItems;
    BOOL inEditMode;
    UINavigationController *editItemNavController;
    NSString *backgroundImageFilename;
}

@property(nonatomic,strong) IBOutlet UITableView *allItemsTableView;
@property(nonatomic,strong) IBOutlet UIToolbar *toolBar;
@property(nonatomic,strong) IBOutlet UISegmentedControl *checkedState;
@property(nonatomic,strong) IBOutlet UIBarButtonItem *addItemBtn;
@property(nonatomic,strong) IBOutlet UIBarButtonItem *moreActionsBtn;
@property(nonatomic,strong) IBOutlet UIBarButtonItem *editBtn;
@property(nonatomic,strong) MetaList *theList;
@property(nonatomic,assign) BOOL inEditMode;
@property(nonatomic,strong) NSMutableArray *listItems;

- (id)initWithList:(MetaList *)aList;
- (IBAction)addItemBtnPressed:(id)sender;
- (IBAction)moreActionsBtnPressed:(id)sender;
- (IBAction)checkedStateValueChanged:(id)sender;


@end
