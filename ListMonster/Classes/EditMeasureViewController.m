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

@interface EditMeasureViewController()

- (void)loadMeasurementSet:(NSInteger)measureSet;
- (void)setupUIWithDefaultMeasure:(Measure *)measure; 
- (void)populateCustomMeasureTextFields:(Measure *)measure;
- (void)selectComponentsForMeasure:(Measure *)newMeasure;
- (NSUInteger)calculateMeasurementIndexAfterDeletionOfUnit:(Measure *)unit;
- (NSUInteger)calculateUnitIndexAtMeasurementIndex:(NSUInteger)measureIndex afterDeletionOfUnit:(Measure *)unit;
- (void)selectedUnitForMeasurementIndex:(NSUInteger)measureIdx unitIndex:(NSUInteger)unitIndex;

@end


@implementation EditMeasureViewController

@synthesize unitSelector, measurePicker, currentMeasures, defaultUnitSelection;
@synthesize selectedMeasure, item, viewTitle;
@synthesize customMeasureView, customMeasure, customMeasureAbbrev, customMeasureName;
@synthesize addCustomMeasure, removeCustomMeasure;
@synthesize selectedMeasureKey;

- (id)initWithTitle:(id)aTitle listItem:(MetaListItem *)anItem;
{
    self = [super initWithNibName:@"EditMeasureView" bundle:nil];
    if (!self) return nil;
    [self setItem:anItem];
    [self setViewTitle:aTitle];
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", @"back button") 
                                                                style:UIBarButtonItemStylePlain 
                                                               target:nil 
                                                               action:nil];
    [[self customMeasureView] setHidden:YES];
    [[self navigationItem] setBackBarButtonItem:backBtn];
    
    [[self unitSelector] setTitle:NSLocalizedString(@"English", nil) forSegmentAtIndex:emvENGLISH_UNIT_INDEX];
    [[self unitSelector] setTitle:NSLocalizedString(@"Metric", nil) forSegmentAtIndex:emvMETRIC_UNIT_INDEX];
    [[self unitSelector] setTitle:NSLocalizedString(@"Custom", nil) forSegmentAtIndex:emvCUSTOM_UNIT_INDEX];
    [[self unitSelector] setTitle:NSLocalizedString(@"None", nil) forSegmentAtIndex:emvNONE_UNIT_INDEX];
    NSInteger measurementSet = [self defaultUnitSelection];
    if ([[[self item] unitOfMeasure] isMetricUnit])
        measurementSet = emvMETRIC_UNIT_INDEX;
    else if ([[[self item] unitOfMeasure] isCustomUnit])
        measurementSet = emvCUSTOM_UNIT_INDEX;
    [self loadMeasurementSet:measurementSet];
    [[self navigationItem] setTitleView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav-title"]]];    
    [[self navigationItem] setPrompt:NSLocalizedString(@"Select or Edit Unit of Measure", nil)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setupUIWithDefaultMeasure:[[self item] unitOfMeasure]];
    if ([[self item] unitOfMeasure])
        [self setSelectedMeasure:[[self item] unitOfMeasure]];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[self item] setUnitOfMeasure:[self selectedMeasure]];
    [[self delegate] editItemViewController:self didChangeValue:[self selectedMeasure] forItem:[self item]];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    [self setUnitSelector:nil];
    [self setMeasurePicker:nil];
    [self setCustomMeasureName:nil];
    [self setCustomMeasure:nil];
    [self setCustomMeasureAbbrev:nil];
    [self setCustomMeasureView:nil];
    [self setAddCustomMeasure:nil];
    [self setRemoveCustomMeasure:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}


#pragma mark - Actions

- (IBAction)unitSelectorTapped:(id)sender
{
    [self resignTextfieldsAsFirstResponders];    
    NSInteger measurementSet = [[self unitSelector] selectedSegmentIndex];
    if (measurementSet == emvNONE_UNIT_INDEX) {
        [self setSelectedMeasure:nil];
        [self setSelectedMeasureKey:nil];
        [UIView animateWithDuration:0.25f animations:^{
            [[self customMeasureView] setAlpha:0.0f];
            [[self measurePicker] setAlpha:0.0f];
        } completion:^(BOOL finished) {
            [[self customMeasureView] setHidden:YES];
            [[self measurePicker] setHidden:YES];
        }];
        return;
    }
    [self loadMeasurementSet:measurementSet];
    [self setSelectedMeasureKey:nil];
    [self setSelectedMeasure:nil];
    [UIView animateWithDuration:0.25f animations:^{
        [[self measurePicker] setAlpha:1.0f];
        if (measurementSet == emvCUSTOM_UNIT_INDEX)
            [[self customMeasureView] setAlpha:1.0f];        
        else
            [[self customMeasureView] setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [[self measurePicker] setHidden:NO];
        if (measurementSet == emvCUSTOM_UNIT_INDEX) {
            [[self customMeasureView] setHidden:NO];
        }
        else {
            [[self customMeasureView] setHidden:YES];
            [self populateCustomMeasureTextFields:nil];
        }
        [[self measurePicker] reloadAllComponents];
        [self setDefaultUnitSelection:[[self unitSelector] selectedSegmentIndex]];
    }];
}

- (IBAction)addCustomMeasureTapped:(UIButton *)sender
{
    [self resignTextfieldsAsFirstResponders];
    BOOL ok = YES;
    NSString *measure = [[self customMeasure] text];
    if (!measure || [measure isEmptyString]) {
        [[self customMeasure] becomeFirstResponder];
        ok = NO;
    }
    NSString *measureName = [[self customMeasureName] text];
    if (!measureName || [measureName isEmptyString]) {
        [[self customMeasureName] becomeFirstResponder];
        ok = NO;
    }
    NSString *measureAbbrev = [[self customMeasureAbbrev] text];
    if (!measureAbbrev || [measureAbbrev isEmptyString]) {
        [[self customMeasureAbbrev] becomeFirstResponder];
        ok = NO;
    }
    if (!ok) return;
    
    NSManagedObjectContext *moc = [[ListMonsterAppDelegate sharedAppDelegate] managedObjectContext];
    Measure *newMeasure = [NSEntityDescription insertNewObjectForEntityForName:@"Measure" inManagedObjectContext:moc];
    [newMeasure setMeasure:measure];
    [newMeasure setUnit:measureName];
    [newMeasure setUnitAbbreviation:measureAbbrev];
    [newMeasure setIsCustom:BOOL_OBJ(YES)];
    [newMeasure setUnitIdentifier:@([NSDate timeIntervalSinceReferenceDate])];
    [moc save:nil];
    [self setSelectedMeasure:newMeasure];
    [self setSelectedMeasureKey:measure];
    [[ListMonsterAppDelegate sharedAppDelegate] deleteCacheObjectForKey:@"measures"];
    [self loadMeasurementSet:emvCUSTOM_UNIT_INDEX];
    [[self measurePicker] reloadAllComponents];
    [self selectComponentsForMeasure:newMeasure];
}

- (IBAction)removeCustomMeasureTapped:(UIButton *)sender
{

    if (![self selectedMeasure]) return;

    // figure out which picker components we need to select after the deletion.
    NSUInteger nextMeasureRow = [self calculateMeasurementIndexAfterDeletionOfUnit:[self selectedMeasure]];
    NSUInteger nextUnitRow = [self calculateUnitIndexAtMeasurementIndex:nextMeasureRow afterDeletionOfUnit:[self selectedMeasure]];
    
    NSManagedObjectContext *moc = [[self selectedMeasure] managedObjectContext];
    [moc deleteObject:[self selectedMeasure]];
    [moc save:nil];
    [[self customMeasure] setText:nil];
    [[self customMeasureName] setText:nil];
    [[self customMeasureAbbrev] setText:nil];    
    [[ListMonsterAppDelegate sharedAppDelegate] deleteCacheObjectForKey:@"measures"];    
    [self loadMeasurementSet:emvCUSTOM_UNIT_INDEX];
    [[self measurePicker] reloadAllComponents];
    if ([[self currentMeasures] count] == 0) {
        [self setSelectedMeasureKey:nil];
        [self setSelectedMeasure:nil];
        return;        
    } 
    [self selectedUnitForMeasurementIndex:nextMeasureRow unitIndex:nextUnitRow];
    [[self measurePicker] selectRow:nextMeasureRow inComponent:emvMEASURE_COMPONENT_INDEX animated:YES];
    [[self measurePicker] selectRow:nextUnitRow inComponent:emvUNIT_COMPONENT_INDEX animated:YES];
    [self populateCustomMeasureTextFields:[self selectedMeasure]];    
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

- (void)resignTextfieldsAsFirstResponders
{
    [[self customMeasureName] resignFirstResponder];
    [[self customMeasure] resignFirstResponder];
    [[self customMeasureAbbrev] resignFirstResponder];
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
    if ([unitSelector selectedSegmentIndex] == emvCUSTOM_UNIT_INDEX) {
        NSArray *unsorted = [self currentMeasures][[self selectedMeasureKey]];
        componentList = [unsorted sortedOnKey:@"unit" ascending:YES];
    } else {
        componentList = [self currentMeasures][[self selectedMeasureKey]];
    }
    Measure *m = componentList[row];
    return [m unit];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSArray *units = nil;    
    NSInteger measurementSet = [[self unitSelector] selectedSegmentIndex];       
    if (emvMEASURE_COMPONENT_INDEX == component) {
        NSArray *measures = [[[self currentMeasures] allKeys] sortedArrayUsingSelector:@selector(compare:)];
        if ([measures count] == 0) return;
        [self setSelectedMeasureKey:measures[row]];
        DLog(@"smk: %@", [self selectedMeasureKey]);
        [[self measurePicker] reloadComponent:emvUNIT_COMPONENT_INDEX];
        if (measurementSet == emvCUSTOM_UNIT_INDEX) {
            NSArray *unsorted = [self currentMeasures][[self selectedMeasureKey]];
            units = [unsorted sortedOnKey:@"unit" ascending:YES];
        } else {
            units = [self currentMeasures][[self selectedMeasureKey]];
        }
        [self setSelectedMeasure:units[0]];
        
        if (measurementSet == emvCUSTOM_UNIT_INDEX)
            [self populateCustomMeasureTextFields:[self selectedMeasure]];
        return;
    }
    if (![self selectedMeasureKey]) return;
    
    if (measurementSet == emvCUSTOM_UNIT_INDEX) {
        NSArray *unsorted = [self currentMeasures][[self selectedMeasureKey]];
        units = [unsorted sortedOnKey:@"unit" ascending:YES];            
    } else {
        units = [self currentMeasures][[self selectedMeasureKey]];
    }
    [self setSelectedMeasure:units[row]];
    if (measurementSet == emvCUSTOM_UNIT_INDEX)
        [self populateCustomMeasureTextFields:[self selectedMeasure]];
}

- (void)populateCustomMeasureTextFields:(Measure *)measure
{
    [[self customMeasure] setText:[measure measure]];
    [[self customMeasureName] setText:[measure unit]];
    [[self customMeasureAbbrev] setText:[measure unitAbbreviation]];
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
    else if (measureSet == emvCUSTOM_UNIT_INDEX)
        byMeasurementSet = [NSPredicate predicateWithFormat:@"self.isCustom == 1"];
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
        if ([self defaultUnitSelection] == emvCUSTOM_UNIT_INDEX) {
            [UIView animateWithDuration:0.25f animations:^{
                [[self customMeasure] setAlpha:1.0f];
            } completion:^(BOOL finished) {
                [[self customMeasureView] setHidden:NO];
            }];            
        }
        return;
    }
    NSArray *measures = nil;
    NSArray *units = nil;
    if ([measure isMetricUnit])
        [[self unitSelector] setSelectedSegmentIndex:emvMETRIC_UNIT_INDEX];
    if ([measure isCustomUnit]) {
        [[self unitSelector] setSelectedSegmentIndex:emvCUSTOM_UNIT_INDEX];
        [UIView animateWithDuration:0.25f animations:^{
            [[self customMeasure] setAlpha:1.0f];
        } completion:^(BOOL finished) {
            [[self customMeasureView] setHidden:NO];
            [self populateCustomMeasureTextFields:measure];
        }];
        measures = [[[self currentMeasures] allKeys] sortedArrayUsingSelector:@selector(compare:)];
        NSArray *unsorted = [self currentMeasures][[measure measure]];
        units = [unsorted sortedOnKey:@"unit" ascending:YES];
    } else {
        measures = [[[self currentMeasures] allKeys] sortedArrayUsingSelector:@selector(compare:)];
        units = [self currentMeasures][[measure measure]];
    }
    NSInteger measureRow = [measures indexOfObject:[measure measure]];
    NSInteger unitRow = [units indexOfObject:measure];
    [self setSelectedMeasureKey:[measure measure]];    
    [[self measurePicker] reloadAllComponents];
    [[self measurePicker] selectRow:measureRow inComponent:emvMEASURE_COMPONENT_INDEX animated:NO];
    [[self measurePicker] selectRow:unitRow inComponent:emvUNIT_COMPONENT_INDEX animated:NO];    
    
}


@end
