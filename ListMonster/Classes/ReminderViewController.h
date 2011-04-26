//
//  ReminderViewController.h
//  ListMonster
//
//  Created by Norm Barnard on 4/20/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MetaListItem.h"

@class Tuple;

#define rvDAYS_FILE_DEFAULT  @"days-en_US"
#define rvSIMPLE_MODE       0
#define rvPICKER_MODE       1
#define rvSUNDAY            1
#define rvSATURDAY          7

@interface ReminderViewController : UIViewController <UITableViewDataSource, 
                                                      UITableViewDelegate, 
                                                      UIPickerViewDelegate> 
{
    UISegmentedControl *dateSelectionMode;
    UIDatePicker *datePicker;
    UITableView *simpleDateTable;
    NSArray *simpleDates;
    id<ReminderItemProtocol> reminderItem;
    NSDate *selectedReminderDate;
}

@property(nonatomic,retain) IBOutlet UISegmentedControl *dateSelectionMode;
@property(nonatomic,retain) IBOutlet UIDatePicker *datePicker;
@property(nonatomic,retain) IBOutlet UITableView *simpleDateTable;
@property(nonatomic,retain) NSArray *simpleDates;
@property(nonatomic,retain) id reminderItem;
@property(nonatomic,retain) NSDate *selectedReminderDate;

- (id)initWithReminderItem:(id)item;
- (IBAction)dateSelectionModeChanged:(id)sender;
- (IBAction)datePickerDateChanged:(id)sender;


@end
