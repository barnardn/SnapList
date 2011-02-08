//
//  TextEntryViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 1/22/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import "ListMonsterAppDelegate.h"
#import "ListNameViewController.h"


@implementation ListNameViewController

@synthesize textField, theList;

- (id)initWithList:(MetaList *)aList {
    
    self = [super initWithNibName:@"TextEntryView" bundle:nil];
    if (!self) return nil;
    
    [self setTheList:aList];
    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"cancel button")
                                                                  style:UIBarButtonItemStyleDone 
                                                                 target:self 
                                                                 action:@selector(cancelPressed:)];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"done button")
                                                                style:UIBarButtonItemStyleDone 
                                                               target:self 
                                                               action:@selector(donePressed:)];
    [[self navigationItem] setLeftBarButtonItem:cancelBtn];
    [[self navigationItem] setRightBarButtonItem:doneBtn];
    [cancelBtn release];
    [doneBtn release];
    
    [[self navigationItem] setTitle:NSLocalizedString(@"List Name", @"list name view title")];
    [[self textField] setPlaceholder:NSLocalizedString(@"Enter list name", @"list name textfield placeholder")];
    if ([[self theList] name]) 
        [[self textField] setText:[[self theList] name]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[self textField] becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[self textField] resignFirstResponder];
}

- (void)cancelPressed:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}
     
- (void)donePressed:(id)sender {
    NSString *newName = [[self textField] text];
    [[self theList] setName:newName];
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [self setTextField:nil];
}


- (void)dealloc {
    [textField release];
    [theList release];
    [super dealloc];
}


@end
