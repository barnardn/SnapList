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

@property(nonatomic,weak) IBOutlet UISegmentedControl *dateSelectionMode;
@property(nonatomic,weak) IBOutlet UIDatePicker *datePicker;
@property(nonatomic,weak) IBOutlet UITableView *simpleDateTable;
@property(nonatomic,strong) NSArray *simpleDates;
@property(nonatomic,strong) id reminderItem;
@property(nonatomic,strong) NSDate *selectedReminderDate;  // for picker only!?!?!?
@property(nonatomic,strong) NSString *viewTitle;
@property(nonatomic,strong) Tuple *selectedSimpleDate;

@property (nonatomic, weak) id<EditItemViewDelegate> delegate;

- (id)initWithTitle:(NSString *)aTitle listItem:(id<ReminderItemProtocol>)anItem; // designated initializer
- (IBAction)dateSelectionModeChanged:(id)sender;
- (IBAction)datePickerDateChanged:(id)sender;


@end
