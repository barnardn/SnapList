//
//  ColorSelectViewController.h
//  ListMonster
//
//  Created by Norm Barnard on 1/23/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class ListColor;
@class MetaList;

@interface ColorSelectViewController : UITableViewController {
    
    NSArray *allColors;
    MetaList *theList;
}

@property(nonatomic,retain) NSArray *allColors;
@property(nonatomic,retain) MetaList *theList;

- (id)initWithList:(MetaList *)aList;


@end
