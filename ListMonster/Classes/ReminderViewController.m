//
//  ReminderViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 4/20/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import "datetime_utils.h"
#import "ReminderViewController.h"
#import "Tuple.h"

@interface ReminderViewController()

- (NSArray *)readDayNamesForLocale:(NSLocale *)locale;
- (void)setupSimpleDateDataSource;
- (void)donePressed:(id)sender;

@end


@implementation ReminderViewController

@synthesize selectedReminderDate, dateSelectionMode, datePicker, simpleDateTable; 
@synthesize simpleDates, reminderItem;


- (id)initWithReminderItem:(id)item 
{
    self = [super initWithNibName:@"ReminderView" bundle:nil];
    if (!self) return nil;
    [self setupSimpleDateDataSource];
    [self setReminderItem:item];
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
    return nil;
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
    [self setSimpleDateTable:nil];
    [self setDatePicker:nil];
    [self setDateSelectionMode:nil];
}


- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc 
{
    [simpleDateTable release];
    [datePicker release];
    [dateSelectionMode release];
    [simpleDates release];
    [super dealloc];
}

#pragma mark -
#pragma mark View Life cycle

- (void)viewDidLoad 
{
    [super viewDidLoad];
    [[self datePicker] setHidden:YES];
    [[self simpleDateTable] setHidden:NO];
    [[self datePicker] setMinimumDate:[NSDate date]];
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", @"back button") 
                                                                style:UIBarButtonItemStylePlain 
                                                               target:nil 
                                                               action:nil];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"done button")
                                                                style:UIBarButtonItemStyleDone 
                                                               target:self 
                                                               action:@selector(donePressed:)];
    [[self navigationItem] setBackBarButtonItem:backBtn];
    [[self navigationItem] setRightBarButtonItem:doneBtn];
    [backBtn release];
    [doneBtn release];
    
}


#pragma mark -
#pragma mark Action methods

- (IBAction)dateSelectionModeChanged:(id)sender 
{    
    NSInteger selectedMode = [[self dateSelectionMode] selectedSegmentIndex];
    if (selectedMode == rvSIMPLE_MODE) {
        [[self simpleDateTable] setHidden:NO];
        [[self datePicker] setHidden:YES];
        [[self datePicker] setDate:[NSDate date]];
    } else {
        [[self simpleDateTable] setHidden:YES];
        [[self datePicker] setHidden:NO];
    }
    [self setSelectedReminderDate:nil];
}

- (void)donePressed:(id)sender 
{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)datePickerDateChanged:(id)sender 
{
    [self setSelectedReminderDate:[[self datePicker] date]];
}


#pragma mark -
#pragma mark Methods

- (void)setupSimpleDateDataSource 
{    
    Tuple *today = [Tuple tupleWithFirst:NSLocalizedString(@"Today", @"today item") second:INT_OBJ(0)];
    Tuple *tomorrow = [Tuple tupleWithFirst:NSLocalizedString(@"Tomorrow", @"tomorrow item") second:INT_OBJ(1)];
    NSArray *dayNames = [self readDayNamesForLocale:[NSLocale currentLocale]];
    
    NSMutableArray *dow = [NSMutableArray arrayWithCapacity:9];
    [dow insertObject:today atIndex:0];
    [dow insertObject:tomorrow atIndex:1];
    
    NSInteger curWeekday = weekday_for_today();
    for (int idx = rvSUNDAY; idx <= rvSATURDAY; idx++) {
        NSInteger dayOffset = curWeekday - idx;
        if (dayOffset < 0)
            dayOffset += rvSATURDAY;
        DLog(@"offset for day %d: %d", idx, dayOffset);
        Tuple *d = [Tuple tupleWithFirst:[dayNames objectAtIndex:(idx-1)] second:INT_OBJ(dayOffset)];
        [dow insertObject:d atIndex:idx+1];
    }
    [self setSimpleDates:dow];
}

- (NSArray *)readDayNamesForLocale:(NSLocale *)locale 
{    
    NSString *daysFile = [NSString stringWithFormat:@"days-%@", [locale localeIdentifier]];
    NSString *path = [[NSBundle mainBundle] pathForResource:daysFile ofType:@"plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
        path = [[NSBundle mainBundle] pathForResource:rvDAYS_FILE_DEFAULT ofType:@"plist"];
    NSArray *dow = [NSArray arrayWithContentsOfFile:path];
    return dow;
}


#pragma mark -
#pragma mark UITableView Datasource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [simpleDates count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    Tuple *dow = [[self simpleDates] objectAtIndex:[indexPath row]];
    [[cell textLabel] setText:[dow first]];
    return cell;
}


#pragma mark -
#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Tuple *selected = [[self simpleDates] objectAtIndex:[indexPath row]];
    NSNumber *dow = [selected second];
    NSDate *todayAtMidnight = today_at_midnight();
    NSDate *rd = date_by_adding_days(todayAtMidnight, [dow intValue]);
    [self setSelectedReminderDate:rd];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    [cell setSelected:NO];
}


@end


