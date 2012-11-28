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

#import "SwipeToEditCellTableViewController.h"

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


@interface ListItemsViewController : SwipeToEditCellTableViewController <UITableViewDataSource,
                                                       UITableViewDelegate, 
                                                       UITextViewDelegate>
{
    BOOL inEditMode;
    UINavigationController *editItemNavController;
    NSString *backgroundImageFilename;
}

@property (nonatomic, weak) IBOutlet UIToolbar *toolBar;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *editBtn;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *btnViewAll;
@property(nonatomic,strong) MetaList *theList;


- (id)initWithList:(MetaList *)aList;

@end
