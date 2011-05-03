//
//  EditTextViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 2/19/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import "Alerts.h"
#import "EditTextViewController.h"
#import "NSNumberExtensions.h"


@implementation EditTextViewController

@synthesize textField, viewTitle,backgroundImageFilename, item;

- (id)initWithTitle:(NSString *)aTitle listItem:(MetaListItem *)anItem 
{
    self = [super initWithNibName:@"EditTextView" bundle:nil];
    if (!self) return nil;
    [self setViewTitle:aTitle];
    [self setItem:anItem];
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
    return nil;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [self setTextField:nil];
}

- (void)dealloc {
    [textField release];
    [super dealloc];
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
    [[self navigationItem] setTitle:[self viewTitle]];
    if (![self item] || ![[self item] name]) {
        [[self textField] setPlaceholder:NSLocalizedString(@"Item", @"text value placeholder")];        
    }
    else {
        [[self textField] setText:[[self item] name]];
    }
    if ([self backgroundImageFilename]) {
        [[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:[self backgroundImageFilename]]]];
    }
    [[self textField] becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated 
{
    [super viewWillDisappear:animated];
    [[self textField] resignFirstResponder];
    NSString *text = [[self textField] text];
    if (!text || [text isEqualToString:@""]) {
        [self setReturnString:nil];
        return;
    }    
    [[self item] setName:text];
}

#pragma mark -
#pragma mark UITextField delegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField 
{    
    [[self textField] resignFirstResponder];
    [[self navigationController] popViewControllerAnimated:YES];
    return YES;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}




@end
