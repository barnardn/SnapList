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
#import "Tuple.h"

@interface ReminderViewController()

- (NSArray *)readDayNamesForLocale:(NSLocale *)locale;
- (void)setupSimpleDateDataSource;
- (void)stopDateSelectorAnimation;
- (void)defaultViewForReminderDate:(NSDate *)date;

@end

@implementation ReminderViewController

@synthesize selectedReminderDate, dateSelectionMode, datePicker, simpleDateTable; 
@synthesize simpleDates, reminderItem, viewTitle;
@synthesize selectedSimpleDate, lastSelectedIndexPath;

- (id)initWithTitle:(id)aTitle listItem:(id<ReminderItemProtocol>)item;
{
    self = [super initWithNibName:@"ReminderView" bundle:nil];
    if (!self) return nil;
    [self setupSimpleDateDataSource];
    [self setReminderItem:item];
    [self setViewTitle:aTitle];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}


#pragma mark -
#pragma mark View Life cycle

- (void)viewDidLoad 
{
    [super viewDidLoad];
#ifndef DEBUG
    [[self datePicker] setMinimumDate:today_at_midnight()];
#endif
    DLog(@"setting date to: %@", [NSDate date]);
    [[self datePicker] setDate:[NSDate date]];
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", @"back button") 
                                                                style:UIBarButtonItemStylePlain 
                                                               target:nil 
                                                               action:nil];
    [[self navigationItem] setBackBarButtonItem:backBtn];
    [[self simpleDateTable] setAllowsSelection:YES];
    [[self navigationItem] setTitle:NSLocalizedString(@"Set Reminder", @"reminder view title")];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([[self reminderItem] reminderDate]) {
        [self defaultViewForReminderDate:[[self reminderItem] reminderDate]];
    } else {
        [[self datePicker] setHidden:YES];
        [[self simpleDateTable] setHidden:NO];
    }
#ifdef DEBUG
    [[self datePicker] setMinuteInterval:1];
#endif
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSInteger selectedMode = [[self dateSelectionMode] selectedSegmentIndex];
    if (selectedMode == rvSIMPLE_MODE) {
        
        if (![self selectedSimpleDate]) return;
        NSInteger daysOffset = [[[self selectedSimpleDate] second] intValue];
        if (daysOffset < 0) {
            [[self reminderItem] setReminderDate:nil];
            return;
        }
        NSDate *todayAtMidnight = today_at_midnight();
        NSDate *rd = date_by_adding_days(todayAtMidnight, daysOffset);
        [[self reminderItem] setReminderDate:rd];
    } else {
        [[self reminderItem] setReminderDate:[self selectedReminderDate]];
    }
}

- (void)defaultViewForReminderDate:(NSDate *)date 
{
    NSDate *today = today_at_midnight();
    NSInteger dayDiff = date_diff(today, date);
    if (dayDiff < 8) {
        NSPredicate *bySimpleDateOffset = [NSPredicate predicateWithFormat:@"self.second == %d", dayDiff];
        NSArray *matches = [[self simpleDates] filteredArrayUsingPredicate:bySimpleDateOffset];
        if ([matches count] == 0) {
            [[self datePicker] setDate:date];
            [[self dateSelectionMode] setSelectedSegmentIndex:rvPICKER_MODE];
            return;
        } else {
            [self setSelectedSimpleDate:matches[0]];
        }
    } else {
        [[self datePicker] setDate:date];
        [[self dateSelectionMode] setSelectedSegmentIndex:rvPICKER_MODE];
    }
}


#pragma mark -
#pragma mark Action methods

- (IBAction)dateSelectionModeChanged:(id)sender 
{    
    CGContextRef gfxContext = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:gfxContext];
    [UIView setAnimationDidStopSelector:@selector(stopDateSelectorAnimation)];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5f];
    
    NSInteger selectedMode = [[self dateSelectionMode] selectedSegmentIndex];
    if (selectedMode == rvSIMPLE_MODE) {
        [[self simpleDateTable] setHidden:NO];
        [[self simpleDateTable] setAlpha:1.0f];
        [[self datePicker] setAlpha:0.0f];
        [[self datePicker] setDate:[NSDate date]];
    } else {
        [[self datePicker] setHidden:NO];
        [[self simpleDateTable] setAlpha:0.0f];
        [[self datePicker] setAlpha:1.0f];
    }
    [UIView commitAnimations];
    [self setSelectedReminderDate:nil];
}

- (IBAction)datePickerDateChanged:(id)sender 
{
    NSDate *date = [[self datePicker] date];
    NSDate *noSeconds = date_minus_seconds(date);
    DLog(@"date without seconds: %@", noSeconds);
    [self setSelectedReminderDate:noSeconds];
}

- (void)stopDateSelectorAnimation
{
    NSInteger selectedMode = [[self dateSelectionMode] selectedSegmentIndex];
    if (selectedMode == rvSIMPLE_MODE) {
        [[self datePicker] setHidden:YES];
    } else {
        [[self simpleDateTable] setHidden:YES];
    }
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
        Tuple *t = [Tuple tupleWithFirst:dayNames[(weekDayIdx%7)] second:INT_OBJ(dayOffset)];
        if (dayOffset == 0)
            [t setSecond:INT_OBJ(7)];       // for one week from today
        NSInteger replacePoint = (weekDayIdx % 7) + 3;
        DLog(@"%@ at %d", t, replacePoint);
        dow[replacePoint] = t;
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
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    Tuple *dow = [self simpleDates][[indexPath row]];
    if (dow == [self selectedSimpleDate] && ![self lastSelectedIndexPath]) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        [self setLastSelectedIndexPath:indexPath];
    }
    [[cell textLabel] setText:[dow first]];
    return cell;
}


#pragma mark -
#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"didSelectRow");
    if ([indexPath row] == [[self lastSelectedIndexPath] row]) return;
    Tuple *selected = [self simpleDates][[indexPath row]];
    [self setSelectedSimpleDate:selected];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UITableViewCell *lastCell = [tableView cellForRowAtIndexPath:[self lastSelectedIndexPath]];
    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    [lastCell setAccessoryType:UITableViewCellAccessoryNone];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self setLastSelectedIndexPath:indexPath];
}

@end


