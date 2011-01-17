//
//  ListEditViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 1/16/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import "ListEditViewController.h"
#import "MetaList.h"

@interface ListEditViewController()

- (void)setupUiFromList;

@end


@implementation ListEditViewController

@synthesize nameField, colorSelector, addCategoryButton, categoryPicker;
@synthesize colorLabel, categoryLabel, theList;
@synthesize navigationBar, delegate;

- (id)initWithList:(MetaList *)aList {
    if (!(self = [super initWithNibName:@"ListEditView" bundle:nil]))
        return nil;
    [self setTheList:aList];
    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithList:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", "@cancel bar button")
                                                                   style:UIBarButtonItemStylePlain 
                                                                  target:self 
                                                                  action:@selector(cancelButtonPressed:)];
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", "save button item")
                                                                 style:UIBarButtonItemStylePlain 
                                                                target:self 
                                                                action:@selector(saveButtonPressed:)];
    UINavigationItem *navItem = [[self navigationBar] topItem];
    NSString *title = (![self theList]) ? NSLocalizedString(@"New List", @"new list title") : NSLocalizedString(@"Edit List", @"edit list title");
    [navItem setTitle:title];
    [navItem setLeftBarButtonItem:cancelItem];
    [navItem setRightBarButtonItem:saveItem];
    [cancelItem release];
    [saveItem release];
    [self setupUiFromList];
    
}

- (void)setupUiFromList {
    if (![self theList])
        return;

    NSString *theName = [[self theList] name];
    [[self nameField] setText:theName];
    NSInteger colorIdx = [[[self theList] colorCode] intValue];
    [[self colorSelector] setSelectedSegmentIndex:colorIdx];
    //
    // read categories from datamodel
    //
    
    
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [self setNameField:nil];
    [self setColorSelector:nil];
    [self setAddCategoryButton:nil];
    [self setCategoryPicker:nil];
    [self setColorLabel:nil];
    [self setCategoryLabel:nil];
    [self setNavigationBar:nil];
}


- (void)dealloc {
    [nameField release];
    [colorSelector release];
    [addCategoryButton release];
    [categoryPicker release];
    [colorLabel release];
    [categoryLabel release];
    [navigationBar release];
    [super dealloc];
}


#pragma mark -
#pragma mark Actions

- (IBAction)addCategoryButtonPressed:(id)sender {
    
}

- (IBAction)colorSelectorSegmentPressed:(id)sender {
    
}

- (void)cancelButtonPressed:(id)sender {
    [[self delegate] didFinishEditingList:nil];
}

- (void)saveButtonPressed:(id)sender {
    [[self delegate] didFinishEditingList:theList];
}


@end
