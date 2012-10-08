//
//  EditListItemViewController.h
//  ListMonster
//
//  Created by Norm Barnard on 2/17/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ListItemsViewController.h"

@class MetaList;
@class MetaListItem;
@class EditTextViewController;

@interface EditListItemViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate> {

    UITableView *listItemTableView;
    UIToolbar *toolBar;
    MetaList *theList;
    MetaListItem *theItem;
    NSArray *editPropertySections;
    BOOL isModal;
    id<ListItemsViewControllerProtocol> __weak delegate;
    BOOL skipSaveLogic;
    NSString *backgroundImageFilename;
    
}

@property(nonatomic,strong) IBOutlet UITableView *listItemTableView;
@property(nonatomic,strong) IBOutlet UIToolbar *toolBar;
@property(nonatomic,strong) MetaList *theList;
@property(nonatomic,strong) MetaListItem *theItem;
@property(nonatomic,strong) NSArray *editPropertySections;
@property(nonatomic,assign) BOOL isModal;
@property(nonatomic,weak) id<ListItemsViewControllerProtocol> delegate;
@property(nonatomic,strong) NSString *backgroundImageFilename;

- (IBAction)moreActionsBtnPressed:(id)sender;
- (id)initWithList:(MetaList *)list editItem:(MetaListItem *)listItem;

@end
