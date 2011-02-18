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

@interface NewListItemViewController : UITableViewController {

    MetaList *theList;
    MetaListItem *theItem;
    NSArray *itemProperties;
}

@property(nonatomic,retain) MetaList *theList;
@property(nonatomic,retain) MetaListItem *theItem;
@property(nonatomic,retain) NSArray *itemProperties;

- (id)initWithList:(MetaList *)list editItem:(MetaListItem *)listItem;


@end
