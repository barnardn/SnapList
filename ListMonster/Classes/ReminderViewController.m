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
@synthesize simpleDates, reminderItem, backgroundImageFilename, viewTitle;
@synthesize selectedSimpleDate;

- (id)initWithTitle:(id)aTitle reminderItem:(id<ReminderItemProtocol>)item;
{
    self = [super initWithNibName:@"ReminderView" bundle:nil];
    if (!self) return nil;
    [self setupSimpleDateDataSource];
    [self setReminderItem:item];
    [self setViewTitle:aTitle];
    return self;
}

- (id)initWithTitle:(NSString *)aTitle listItem:(MetaListItem *)anItem
{
    return [self initWithTitle:aTitle reminderItem:anItem];
}
/*
- (id)initWithTitle:(NSString *)aTitle list:(MetaList *)list
{
    return [self initWithTitle:aTitle reminderItem:list];    
}
*/
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
    [backgroundImageFilename release];
    [viewTitle release];
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
    
    ///*** WHY DO I HAVE A DONE BUTTON IN THIS VIEW??!?!??!
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"done button")
                                                                style:UIBarButtonItemStyleDone 
                                                               target:self 
                                                               action:@selector(donePressed:)];
    [[self navigationItem] setBackBarButtonItem:backBtn];
    [[self navigationItem] setRightBarButtonItem:doneBtn];
    [backBtn release];
    [doneBtn release];
    if ([self backgroundImageFilename]) {
        [[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:[self backgroundImageFilename]]]];
    }
    [[self navigationItem] setTitle:NSLocalizedString(@"Set Reminder", @"reminder view title")];
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
    Tuple *never = [Tuple tupleWithFirst:NSLocalizedString(@"Never", @"never due") second:INT_OBJ(-1)];
    Tuple *today = [Tuple tupleWithFirst:NSLocalizedString(@"Today", @"today item") second:INT_OBJ(0)];
    Tuple *tomorrow = [Tuple tupleWithFirst:NSLocalizedString(@"Tomorrow", @"tomorrow item") second:INT_OBJ(1)];

    NSArray *dayNames = [self readDayNamesForLocale:[NSLocale currentLocale]];
    
    NSMutableArray *dow = [NSMutableArray arrayWithCapacity:10];
    [dow addObject:never];
    [dow addObject:today];
    [dow addObject:tomorrow];
    for (int idx = 0; idx < 7; idx++)
        [dow addObject:[NSNull null]];
    
    NSInteger curWeekday = weekday_for_today();
    for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
        NSInteger weekDayIdx = (curWeekday - 1) + dayOffset;
        Tuple *t = [Tuple tupleWithFirst:[dayNames objectAtIndex:(weekDayIdx%7)] second:INT_OBJ(dayOffset)];
        if (dayOffset == 0)
            [t setSecond:INT_OBJ(7)];       // for one week from today
        NSInteger replacePoint = (weekDayIdx % 7) + 3;
        DLog(@"%@ at %d", t, replacePoint);
        [dow replaceObjectAtIndex:replacePoint withObject:t];
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
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    Tuple *dow = [[self simpleDates] objectAtIndex:[indexPath row]];
    if (dow == [self selectedSimpleDate])
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    [[cell textLabel] setText:[dow first]];
    return cell;
}


#pragma mark -
#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"didSelect = start");
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setAccessoryType:UITableViewCellAccessoryCheckmark]; 
    Tuple *selected = [[self simpleDates] objectAtIndex:[indexPath row]];
    NSNumber *dow = [selected second];
    NSDate *todayAtMidnight = today_at_midnight();
    NSDate *rd = date_by_adding_days(todayAtMidnight, [dow intValue]);
    [self setSelectedSimpleDate:selected];
    DLog(@"didSelect date: %@", rd);
}


- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    DLog(@"DEselect - start");
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell accessoryType] == UITableViewCellAccessoryCheckmark) {
        DLog(@"DEselect - unselect");
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        [self setSelectedSimpleDate:nil];
    }
    DLog(@"DEselect - end");
}


@end


