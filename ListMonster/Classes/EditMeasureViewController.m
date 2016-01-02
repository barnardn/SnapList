//
//  EditMeasureViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 10/26/11.
//  Copyright (c) 2011 clamdango.com. All rights reserved.
//

#import "EditMeasureViewController.h"
#import "ListMonsterAppDelegate.h"
#import "Measure.h"
#import "MetaListItem.h"
#import "NSArrayExtensions.h"
#import "NSString+EmptyString.h"
#import "ThemeManager.h"

@interface EditMeasureViewController()

@end


@implementation EditMeasureViewController

- (id)initWithTitle:(id)aTitle listItem:(MetaListItem *)anItem;
{
    self = [super init];
    if (!self) return nil;
    [self setItem:anItem];
    [self setViewTitle:aTitle];
    return self;
}

- (NSString *)nibName {
    return @"EditMeasureView";
}


- (NSInteger)defaultUnitSelection
{
    NSNumber *unitIdx = [[ListMonsterAppDelegate sharedAppDelegate] cacheObjectForKey:@"defaultUnit"];
    return (!unitIdx) ? 0 : [unitIdx intValue];
}

- (void)setDefaultUnitSelection:(NSInteger)unitIdx;
{
    NSNumber *idxObj = @(unitIdx);
    [[ListMonsterAppDelegate sharedAppDelegate] addCacheObject:idxObj withKey:@"defaultUnit"];
}

- (NSString *)title {
    return NSLocalizedString(@"Select Unit of Measure", @"select units nav bar title");
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", @"back button") style:UIBarButtonItemStylePlain  target:nil action:nil];
    self.view.backgroundColor = [ThemeManager appBackgroundColor];
    [[self navigationItem] setBackBarButtonItem:backBtn];
    
    [[self unitSelector] setTitle:NSLocalizedString(@"English", nil) forSegmentAtIndex:emvENGLISH_UNIT_INDEX];
    [[self unitSelector] setTitle:NSLocalizedString(@"Metric", nil) forSegmentAtIndex:emvMETRIC_UNIT_INDEX];
    [[self unitSelector] setTitle:NSLocalizedString(@"None", nil) forSegmentAtIndex:emvNONE_UNIT_INDEX];
    NSInteger measurementSet = [self defaultUnitSelection];
    if ([[[self item] unitOfMeasure] isMetricUnit])
        measurementSet = emvMETRIC_UNIT_INDEX;
    [self loadMeasurementSet:measurementSet];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setupUIWithDefaultMeasure:[[self item] unitOfMeasure]];
    if ([[self item] unitOfMeasure])
        [self setSelectedMeasure:[[self item] unitOfMeasure]];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[self item] setUnitOfMeasure:[self selectedMeasure]];
    [[self delegate] editItemViewController:self didChangeValue:[self selectedMeasure] forItem:[self item]];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}


#pragma mark - Actions

- (IBAction)unitSelectorTapped:(id)sender
{
    NSInteger measurementSet = [[self unitSelector] selectedSegmentIndex];
    if (measurementSet == emvNONE_UNIT_INDEX) {
        [self setSelectedMeasure:nil];
        [self setSelectedMeasureKey:nil];
        [UIView animateWithDuration:0.25f animations:^{
            [[self measurePicker] setAlpha:0.0f];
        } completion:^(BOOL finished) {
            [[self measurePicker] setHidden:YES];
        }];
        return;
    }
    [self loadMeasurementSet:measurementSet];
    [self setSelectedMeasureKey:nil];
    [self setSelectedMeasure:nil];
    [UIView animateWithDuration:0.25f animations:^{
        [[self measurePicker] setAlpha:1.0f];
    } completion:^(BOOL finished) {
        [[self measurePicker] setHidden:NO];
        [[self measurePicker] reloadAllComponents];
        [self setDefaultUnitSelection:[[self unitSelector] selectedSegmentIndex]];
    }];
}

- (void)selectedUnitForMeasurementIndex:(NSUInteger)measureIdx unitIndex:(NSUInteger)unitIndex
{
    NSArray *measurements = [[[self currentMeasures] allKeys] sortedArrayUsingSelector:@selector(compare:)];
    if ([measurements count] == 0) return;
    [self setSelectedMeasureKey:measurements[measureIdx]];
    NSArray *unsorted = [self currentMeasures][[self selectedMeasureKey]];
    NSArray *units = [unsorted sortedOnKey:@"unit" ascending:YES];
    if ([units count] == 0) {
        [self setSelectedMeasureKey:nil];
        return;
    }
    [self setSelectedMeasure:units[unitIndex]];
}

- (NSUInteger)calculateMeasurementIndexAfterDeletionOfUnit:(Measure *)unit
{
    NSArray *remainingUnits = [self currentMeasures][[unit measure]];
    BOOL isLastUnitInMeasure = ([remainingUnits count] == 1);
    NSArray *measures = [[[self currentMeasures] allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSUInteger measureIndexDeleted = [measures indexOfObject:[unit measure]];    
    NSUInteger nextMeasureRow = measureIndexDeleted;
    if (isLastUnitInMeasure) {
        if (measureIndexDeleted == NSNotFound || measureIndexDeleted == 0)
            nextMeasureRow = 0;
        else
            nextMeasureRow--;
        [self setSelectedMeasureKey:nil];        
    }
    return nextMeasureRow;
}

- (NSUInteger)calculateUnitIndexAtMeasurementIndex:(NSUInteger)measureIndex afterDeletionOfUnit:(Measure *)unit
{
    NSArray *remainingUnits = [self currentMeasures][[unit measure]];
    NSArray *sorted = [remainingUnits sortedOnKey:@"unit" ascending:YES];
    NSUInteger unitIndex = [sorted indexOfObject:unit];
    if (unitIndex == NSNotFound || unitIndex == 0)
        return 0;
    return MIN(unitIndex, [remainingUnits count]-2);
}


- (void)selectComponentsForMeasure:(Measure *)newMeasure
{
    NSArray *measures = [[[self currentMeasures] allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSInteger measRow = [measures findFirstIndex:^BOOL(NSString *ms) {
        return [ms isEqualToString:[newMeasure measure]];
    }];
    NSArray *unsorted = [self currentMeasures][[newMeasure measure]];
    NSArray *units = [unsorted sortedOnKey:@"unit" ascending:YES];
    NSInteger unitRow = [units findFirstIndex:^BOOL(Measure *m) {
        NSString *us = [m unit];
        return [us isEqualToString:[newMeasure unit]];
    }];
    [[self measurePicker] selectRow:measRow inComponent:emvMEASURE_COMPONENT_INDEX animated:YES];
    [[self measurePicker] selectRow:unitRow inComponent:emvUNIT_COMPONENT_INDEX animated:YES];
}


#pragma mark - text field delegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    DLog(@"did end");
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    DLog(@"should return");
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - PickerView datasource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (emvMEASURE_COMPONENT_INDEX == component)
        return [[[self currentMeasures] allKeys] count];
    
    NSArray *measurements = [[[self currentMeasures] allKeys] sortedArrayUsingSelector:@selector(compare:)];
    if ([measurements count] == 0) return 0;
    if (![self selectedMeasureKey]) {
        NSString *key = measurements[0];
        NSArray *units = [self currentMeasures][key];
        return [units count];
    }
    NSArray *units = [self currentMeasures][[self selectedMeasureKey]];
    return [units count];
}

#pragma mark - PickerView delegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSArray *componentList;
    if (emvMEASURE_COMPONENT_INDEX == component)  { // measures
        componentList = [[[self currentMeasures] allKeys] sortedArrayUsingSelector:@selector(compare:)];
        return componentList[row];
    }
    if (![self selectedMeasureKey]) {
        Measure *itemUnit = [[self item] unitOfMeasure];
        if (itemUnit) {
            [self setSelectedMeasureKey:[itemUnit measure]];
        } else {
            NSString *k = [[[self currentMeasures] allKeys] sortedArrayUsingSelector:@selector(compare:)][0];
            [self setSelectedMeasureKey:k];
        }
    }
    componentList = [self currentMeasures][[self selectedMeasureKey]];

    Measure *m = componentList[row];
    return [m unit];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSArray *units = nil;    
    if (emvMEASURE_COMPONENT_INDEX == component) {
        NSArray *measures = [[[self currentMeasures] allKeys] sortedArrayUsingSelector:@selector(compare:)];
        if ([measures count] == 0) return;
        [self setSelectedMeasureKey:measures[row]];
        DLog(@"smk: %@", [self selectedMeasureKey]);
        [[self measurePicker] reloadComponent:emvUNIT_COMPONENT_INDEX];
        units = [self currentMeasures][[self selectedMeasureKey]];
        [self setSelectedMeasure:units[0]];
        return;
    }
    if (![self selectedMeasureKey]) return;
    units = [self currentMeasures][[self selectedMeasureKey]];

    [self setSelectedMeasure:units[row]];
}

#pragma mark - Methods

- (void)loadMeasurementSet:(NSInteger)measureSet
{
    NSArray *allMeasures = [[ListMonsterAppDelegate sharedAppDelegate] cacheObjectForKey:@"measures"];
    if (!allMeasures) {
        allMeasures = [Measure allMeasuresInContext:[[self item] managedObjectContext]];
        [[ListMonsterAppDelegate sharedAppDelegate] addCacheObject:allMeasures withKey:@"measures"];
    }
    NSPredicate *byMeasurementSet = nil;
    if (measureSet == emvMETRIC_UNIT_INDEX)
        byMeasurementSet = [NSPredicate predicateWithFormat:@"self.isMetric == 1"];
    else
        byMeasurementSet = [NSPredicate predicateWithFormat:@"self.isCustom != 1 && self.isMetric != 1"];
    
    NSArray *selectedMeasures = [allMeasures filteredArrayUsingPredicate:byMeasurementSet];
    
    NSMutableDictionary *measureMap = [NSMutableDictionary dictionaryWithCapacity:0];
    [selectedMeasures forEach:^ (id m) {
        NSMutableArray *unitList = measureMap[[m measure]];
        if (!unitList) {
            unitList = [NSMutableArray arrayWithObject:m];
            measureMap[[m measure]] = unitList;
        } else {
            [unitList addObject:m];
        }
    }];
    [self setCurrentMeasures:measureMap];
}

- (void)setupUIWithDefaultMeasure:(Measure *)measure 
{
    if (!measure) {
        [[self unitSelector] setSelectedSegmentIndex:[self defaultUnitSelection]];
        return;
    }
    NSArray *measures = nil;
    NSArray *units = nil;
    if ([measure isMetricUnit]) {
        [[self unitSelector] setSelectedSegmentIndex:emvMETRIC_UNIT_INDEX];
    }
    measures = [[[self currentMeasures] allKeys] sortedArrayUsingSelector:@selector(compare:)];
    units = [self currentMeasures][[measure measure]];

    NSInteger measureRow = [measures indexOfObject:[measure measure]];
    NSInteger unitRow = [units indexOfObject:measure];
    [self setSelectedMeasureKey:[measure measure]];    
    [[self measurePicker] reloadAllComponents];
    [[self measurePicker] selectRow:measureRow inComponent:emvMEASURE_COMPONENT_INDEX animated:NO];
    [[self measurePicker] selectRow:unitRow inComponent:emvUNIT_COMPONENT_INDEX animated:NO];    
    
}


@end
