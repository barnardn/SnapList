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

@interface EditMeasureViewController()

- (void)loadMeasurementSet:(BOOL)isMetric;
- (void)setupUIWithDefaultMeasure:(Measure *)measure; 

@end


@implementation EditMeasureViewController

@synthesize unitSelector, measurePicker, currentMeasures, defaultUnitSelection;
@synthesize backgroundImageFilename, selectedMeasure, item, viewTitle;


- (id)initWithTitle:(id)aTitle listItem:(MetaListItem *)anItem;
{
    self = [super initWithNibName:@"EditMeasureView" bundle:nil];
    if (!self) return nil;
    [self setItem:anItem];
    [self setViewTitle:aTitle];
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
    return nil;
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
    NSNumber *idxObj = [NSNumber numberWithInt:unitIdx];
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
    [[self navigationItem] setBackBarButtonItem:backBtn];
    [backBtn release];
    if ([self backgroundImageFilename]) {
        [[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:[self backgroundImageFilename]]]];
    } else {
        [[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Backgrounds/normal"]]];        
    }
    [[self unitSelector] setTitle:NSLocalizedString(@"English", nil) forSegmentAtIndex:emvENGLISH_UNIT_INDEX];
    [[self unitSelector] setTitle:NSLocalizedString(@"Metric", nil) forSegmentAtIndex:emvMETRIC_UNIT_INDEX];
    [self loadMeasurementSet:[[[self item] unitOfMeasure] isMetricUnit]];
    [self setupUIWithDefaultMeasure:[[self item] unitOfMeasure]];
    [[self navigationItem] setTitle:viewTitle];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[self item] setUnitOfMeasure:[self selectedMeasure]];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    [self setUnitSelector:nil];
    [self setMeasurePicker:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return ((toInterfaceOrientation == UIInterfaceOrientationPortrait) ||
            (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown));
}

- (void)dealloc {
    [unitSelector release];
    [measurePicker release];
    [selectedMeasure release];
    [viewTitle release];
    [item release];
    [super dealloc];
}

#pragma mark - Actions

- (IBAction)UnitSelectorTapped:(id)sender 
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    bool isMetric = (emvMETRIC_UNIT_INDEX == [[self unitSelector] selectedSegmentIndex]);
    [self loadMeasurementSet:isMetric];
    selectedMeasureKey = nil;
    selectedMeasure = nil;
    [[self measurePicker] reloadAllComponents];
    [self setDefaultUnitSelection:[[self unitSelector] selectedSegmentIndex]];
    [UIView commitAnimations];
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
    if (nil == selectedMeasureKey) {
        selectedMeasureKey = [[[self currentMeasures] allKeys] objectAtIndex:0];
    }
    NSArray *units = [[self currentMeasures] valueForKey:selectedMeasureKey];
    return [units count];
}

#pragma mark - PickerView delegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSArray *componentList;
    if (emvMEASURE_COMPONENT_INDEX == component)  { // measures
        componentList = [[self currentMeasures] allKeys];
        return [componentList objectAtIndex:row];
    }
    if (!selectedMeasureKey) {
        selectedMeasureKey = [[[self currentMeasures] allKeys] objectAtIndex:0];
    }
    componentList = [[self currentMeasures] objectForKey:selectedMeasureKey];
    Measure *m = [componentList objectAtIndex:row];
    return [m unit];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (emvMEASURE_COMPONENT_INDEX == component) {
        NSArray *measures = [[self currentMeasures] allKeys];
        selectedMeasureKey = [measures objectAtIndex:row];
        [[self measurePicker] reloadComponent:emvUNIT_COMPONENT_INDEX];
        if (0 == row) {
            selectedMeasure = nil;
        } else {        // default to the first item in the unit wheel
            NSArray *units = [[self currentMeasures] objectForKey:selectedMeasureKey];
            [self setSelectedMeasure:[units objectAtIndex:0]];
        }
        return;
    }
    ZAssert(nil != selectedMeasureKey, @"Whoa, selected measure key is nil in pickerView:didSelectRow:inComponent");
    NSArray *units = [[self currentMeasures] objectForKey:selectedMeasureKey];
    [self setSelectedMeasure:[units objectAtIndex:row]];
}


#pragma mark - Methods

- (void)loadMeasurementSet:(BOOL)isMetric
{
    NSArray *allMeasures = [[ListMonsterAppDelegate sharedAppDelegate] cacheObjectForKey:@"measures"];
    if (!allMeasures) {
        allMeasures = [[[ListMonsterAppDelegate sharedAppDelegate] fetchAllInstancesOf:@"Measure" orderedBy:@"sortOrder"] mutableCopy];
        [[ListMonsterAppDelegate sharedAppDelegate] addCacheObject:allMeasures withKey:@"measures"];
    }
    NSArray *selectedMeasures = [allMeasures filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.isMetric == %d", (isMetric) ? 1 : 0]];
    NSMutableDictionary *measureMap = [NSMutableDictionary dictionaryWithCapacity:0];
    [selectedMeasures forEach:^ (id m) {
        NSMutableArray *unitList = [measureMap objectForKey:[m measure]];
        if (!unitList) {
            unitList = [NSMutableArray arrayWithObject:m];
            [measureMap setObject:unitList forKey:[m measure]];
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
    if ([measure isMetricUnit])
        [[self unitSelector] setSelectedSegmentIndex:emvMETRIC_UNIT_INDEX];
    selectedMeasureKey = [measure measure];
    NSInteger measureRow = [[[self currentMeasures] allKeys] indexOfObject:selectedMeasureKey];
    NSInteger unitRow = [[[self currentMeasures] objectForKey:selectedMeasureKey] indexOfObject:measure];
    [[self measurePicker] selectRow:measureRow inComponent:emvMEASURE_COMPONENT_INDEX animated:YES];
    [[self measurePicker] selectRow:unitRow inComponent:emvUNIT_COMPONENT_INDEX animated:YES];
    [self setSelectedMeasure:measure];
}





@end
