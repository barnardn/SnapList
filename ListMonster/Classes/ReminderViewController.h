//
//  ReminderViewController.h
//  ListMonster
//
//  Created by Norm Barnard on 4/20/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditItemViewProtocol.h"
#import "MetaListItem.h"

@class MetaListItem;
@class MetaList;
@class Tuple;

#define rvDAYS_FILE_DEFAULT  @"days-en_US"
#define rvSIMPLE_MODE       0
#define rvPICKER_MODE       1
#define rvSUNDAY            1
#define rvSATURDAY          7

@interface ReminderViewController : UIViewController <UITableViewDataSource, 
                                                      UITableViewDelegate, 
                                                      UIPickerViewDelegate,
                                                      EditItemViewProtocol> 
{
    UISegmentedControl *dateSelectionMode;
    UIDatePicker *datePicker;
    UITableView *simpleDateTable;
    NSArray *simpleDates;
    id<ReminderItemProtocol> reminderItem;
    NSDate *selectedReminderDate;
    NSString *backgroundImageFilename;
    NSString *viewTitle;
    Tuple *selectedSimpleDate;
    NSIndexPath *selectedIndexPath;
}

@property(nonatomic,retain) IBOutlet UISegmentedControl *dateSelectionMode;
@property(nonatomic,retain) IBOutlet UIDatePicker *datePicker;
@property(nonatomic,retain) IBOutlet UITableView *simpleDateTable;
@property(nonatomic,retain) NSArray *simpleDates;
@property(nonatomic,retain) id reminderItem;
@property(nonatomic,retain) NSDate *selectedReminderDate;  // for picker only!?!?!?
@property(nonatomic,retain) NSString *viewTitle;
@property(nonatomic,retain) Tuple *selectedSimpleDate;

- (id)initWithTitle:(NSString *)aTitle listItem:(id<ReminderItemProtocol>)anItem; // designated initializer
- (IBAction)dateSelectionModeChanged:(id)sender;
- (IBAction)datePickerDateChanged:(id)sender;


@end
