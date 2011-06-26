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
    id<ListItemsViewControllerProtocol> delegate;
    BOOL skipSaveLogic;
    NSString *backgroundImageFilename;
    
}

@property(nonatomic,retain) IBOutlet UITableView *listItemTableView;
@property(nonatomic,retain) IBOutlet UIToolbar *toolBar;
@property(nonatomic,retain) MetaList *theList;
@property(nonatomic,retain) MetaListItem *theItem;
@property(nonatomic,retain) NSArray *editPropertySections;
@property(nonatomic,assign) BOOL isModal;
@property(nonatomic,assign) id<ListItemsViewControllerProtocol> delegate;
@property(nonatomic,retain) NSString *backgroundImageFilename;

- (IBAction)moreActionsBtnPressed:(id)sender;
- (id)initWithList:(MetaList *)list editItem:(MetaListItem *)listItem;

@end
