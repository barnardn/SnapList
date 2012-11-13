//
//  ListItemsViewController.h
//  ListMonster
//
//  Created by Norm Barnard on 2/13/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
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
                                                       UITextViewDelegate,
                                                       ListItemsViewControllerProtocol>
{
    UIToolbar *toolBar;
    UISegmentedControl *checkedState;
    UIBarButtonItem *moreActionsBtn;
    UIBarButtonItem *editBtn;
    MetaList *theList;
    BOOL inEditMode;
    UINavigationController *editItemNavController;
    NSString *backgroundImageFilename;
}

@property(nonatomic,strong) IBOutlet UITableView *tableView;;
@property(nonatomic,strong) IBOutlet UIToolbar *toolBar;
@property(nonatomic,strong) IBOutlet UIBarButtonItem *moreActionsBtn;
@property(nonatomic,strong) IBOutlet UIBarButtonItem *editBtn;
@property(nonatomic,strong) MetaList *theList;
@property(nonatomic,assign) BOOL inEditMode;


- (id)initWithList:(MetaList *)aList;
- (IBAction)moreActionsBtnPressed:(id)sender;
- (IBAction)checkedStateValueChanged:(id)sender;


@end
