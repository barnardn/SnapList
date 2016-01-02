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

@interface ReminderViewController : UIViewController <UIPickerViewDelegate, EditItemViewProtocol>

@property(nonatomic,weak) IBOutlet UIDatePicker *datePicker;
@property(nonatomic,strong) id reminderItem;
@property(nonatomic,strong) NSDate *selectedReminderDate;  // for picker only!?!?!?
@property(nonatomic,strong) NSString *viewTitle;
@property (nonatomic, weak) id<EditItemViewDelegate> delegate;

- (id)initWithTitle:(NSString *)aTitle listItem:(id<ReminderItemProtocol>)anItem; // designated initializer



@end
