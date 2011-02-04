//
//  TextEntryViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 1/22/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import "ListNameViewController.h"


@implementation ListNameViewController

@synthesize textField, viewTitle, placeholderText, returnValue;

- (id)initWithTitle:(NSString *)theTitle placeholder:(NSString *)thePlaceholder {
    
    self = [super initWithNibName:@"TextEntryView" bundle:nil];
    if (!self) return nil;
    
    [self setPlaceholderText:thePlaceholder];
    [self setViewTitle:theTitle];
    [self setReturnValue:nil];
    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    NSString *title = NSLocalizedString(@"New Item", @"untitled textentry view title");
    NSString *placeholder = NSLocalizedString(@"item name", @"untitled textentry view placeholder");
    return [self initWithTitle:title placeholder:placeholder];
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
    [[self navigationItem] setTitle:[self viewTitle]];
    [[self textField] setPlaceholder:[self placeholderText]];
    [cancelBtn release];
    [doneBtn release];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[self textField] becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[self textField] resignFirstResponder];
}

- (void)cancelPressed:(id)sender {
    [self setReturnValue:nil];
    [[self navigationController] popViewControllerAnimated:YES];
}
     
- (void)donePressed:(id)sender {
    NSString *txt = [[self textField] text];
    [self setReturnValue:txt];
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
    [placeholderText release];
    [viewTitle release];
    [returnValue release];
    [super dealloc];
}


@end
