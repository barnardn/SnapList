//
//  ReminderViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 4/20/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import "datetime_utils.h"
#import "MetaList.h"
#import "ReminderViewController.h"
#import "ThemeManager.h"

@interface ReminderViewController()

- (IBAction)datePickerDateChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *clearReminderButton;

@end

@implementation ReminderViewController


- (id)initWithTitle:(id)aTitle listItem:(id<ReminderItemProtocol>)item;
{
    self = [super init];
    if (!self) return nil;
    [self setReminderItem:item];
    [self setViewTitle:aTitle];
    return self;
}

- (NSString *)nibName {
    return @"ReminderView";
}

- (NSString *)title {
    return NSLocalizedString(@"Select a Reminder Time", @"reminder time nav bar title");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

#pragma mark -
#pragma mark View Life cycle

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [ThemeManager appBackgroundColor];
    [[self datePicker] setDate:[NSDate date]];
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", @"back button") style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [[self navigationItem] setBackBarButtonItem:backBtn];
    [self.clearReminderButton setTitle:NSLocalizedString(@"Do Not Remind Me", @"reminder view nav bar title") forState:UIControlStateNormal];
    self.clearReminderButton.enabled = NO;
    NSDate *defaultDate = [self.reminderItem reminderDate];
    if (defaultDate) {
        [[self datePicker] setDate:defaultDate];
        self.selectedReminderDate = defaultDate;
        self.clearReminderButton.enabled = YES;
    }
    
#ifdef DEBUG
    [[self datePicker] setMinuteInterval:1];
#endif
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[self reminderItem] setReminderDate:[self selectedReminderDate]];
    [[self reminderItem] scheduleReminder];
    [[self delegate] editItemViewController:self didChangeValue:[self selectedReminderDate] forItem:[self reminderItem]];
}


#pragma mark -
#pragma mark Action methods

- (IBAction)datePickerDateChanged:(id)sender 
{
    NSDate *date = [[self datePicker] date];
    NSDate *noSeconds = date_minus_seconds(date);
    DLog(@"date without seconds: %@", noSeconds);
    [self setSelectedReminderDate:noSeconds];
    self.clearReminderButton.enabled = YES;
}

- (IBAction)_clearReminderButtonTapped:(UIButton *)sender {
    self.selectedReminderDate = nil;
    [[self reminderItem] scheduleReminder];
    [[self delegate] editItemViewController:self didChangeValue:[self selectedReminderDate] forItem:[self reminderItem]];
    [self.navigationController popViewControllerAnimated:YES];
}

@end


