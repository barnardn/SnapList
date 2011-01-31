//
//  CategoryViewController.h
//  ListMonster
//
//  Created by Norm Barnard on 1/20/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ModalViewProtocol.h"
#import "SettingViewProtocol.h"

@interface CategoryViewController : UITableViewController <SettingViewProtocol, 
                                                           ModalViewProtocol, 
                                                           NSFetchedResultsControllerDelegate> 
{
    NSFetchedResultsController *resultsController;
}

@property(nonatomic,retain) NSFetchedResultsController *resultsController;

@end
