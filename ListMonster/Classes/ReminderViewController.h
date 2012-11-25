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
    NSIndexPath *lastSelectedIndexPath;
}

@property(nonatomic,strong) IBOutlet UISegmentedControl *dateSelectionMode;
@property(nonatomic,strong) IBOutlet UIDatePicker *datePicker;
@property(nonatomic,strong) IBOutlet UITableView *simpleDateTable;
@property(nonatomic,strong) NSArray *simpleDates;
@property(nonatomic,strong) id reminderItem;
@property(nonatomic,strong) NSDate *selectedReminderDate;  // for picker only!?!?!?
@property(nonatomic,strong) NSString *viewTitle;
@property(nonatomic,strong) Tuple *selectedSimpleDate;
@property(nonatomic,strong) NSIndexPath *lastSelectedIndexPath;

@property (nonatomic, weak) id<EditItemViewDelegate> delegate;

- (id)initWithTitle:(NSString *)aTitle listItem:(id<ReminderItemProtocol>)anItem; // designated initializer
- (IBAction)dateSelectionModeChanged:(id)sender;
- (IBAction)datePickerDateChanged:(id)sender;


@end
