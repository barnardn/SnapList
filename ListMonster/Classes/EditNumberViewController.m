//
//  EditNumberViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 4/29/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import "Alerts.h"
#import "EditNumberViewController.h"
#import "MetaListItem.h"
#import "NSNumberExtensions.h"


@implementation EditNumberViewController

@synthesize numericTextField, item, viewTitle, backgroundImageFilename;


- (id)initWithTitle:(NSString *)aTitle listItem:(MetaListItem *)anItem 
{
    self = [super initWithNibName:@"EditNumberView" bundle:nil];
    if (!self) return nil;
    [self setViewTitle:aTitle];
    [self setItem:anItem];
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
    return nil;
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
    [self setNumericTextField:nil];
}


- (void)dealloc 
{
    [backgroundImageFilename release];
    [numericTextField release];
    [item release];
    [viewTitle release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];
    [[self navigationItem] setTitle:[self viewTitle]];
    if (![[self item] quantity] || [[[self item] quantity] compare:INT_OBJ(0)] == NSOrderedSame) {
        [[self numericTextField] setPlaceholder:NSLocalizedString(@"Value", @"numeric value placeholder")];        
    }
    else {
        NSString *numString = [[[self item] quantity] stringValue];
        [[self numericTextField] setText:numString];
    }
    if ([self backgroundImageFilename]) {
        [[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:[self backgroundImageFilename]]]];
    }
    [[self numericTextField] becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[self numericTextField] resignFirstResponder];
    NSString *enteredText = [[self numericTextField] text];
    NSNumber *number = [NSNumber numberWithString:enteredText];
    if ([number compare:INT_OBJ(0)] == NSOrderedAscending) {
        NSString *errorMessage = NSLocalizedString(@"Enter a number greater than 0", @">0 error message");
        NSString *errorTitle = NSLocalizedString(@"Bad Value", @"error title");
        [ErrorAlert showWithTitle:errorTitle andMessage:errorMessage];
        [[self numericTextField] becomeFirstResponder];
        return;
    }
    [[self item] setQuantity:number];
}

#pragma mark -
#pragma mark UITextField delegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [[self numericTextField] resignFirstResponder];
    [[self navigationController] popViewControllerAnimated:YES];
    return YES;
}


@end