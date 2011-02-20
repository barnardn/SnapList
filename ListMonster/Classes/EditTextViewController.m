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

@synthesize textField, returnString, numericEntryMode, viewTitle, editText;


- (id)initWithViewTitle:(NSString *)aTitle editText:(NSString *)text {
    self = [super initWithNibName:@"EditTextView" bundle:nil];
    if (!self) return nil;
    [self setViewTitle:viewTitle];
    [self setEditText:text];
    [self setReturnString:nil];
    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithViewTitle:@"New Item" editText:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationItem] setTitle:[self viewTitle]];
    if (editText) 
        [[self textField] setText:[self editText]];
    else
        [[self textField] setPlaceholder:NSLocalizedString(@"Value", "@empty text placeholder")];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"done button") 
                                                                style:UIBarButtonItemStyleDone 
                                                               target:self 
                                                               action:@selector(doneBtnPressed:)];
    [[self navigationItem] setRightBarButtonItem:doneBtn];
    [doneBtn release];
    if ([self numericEntryMode]) {
        [[self textField] setTextAlignment:UITextAlignmentRight];
        [[self textField] setKeyboardType:UIKeyboardTypeNumberPad];
    }
    [[self textField] becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [[self textField] resignFirstResponder];
}

- (void)doneBtnPressed:(id)sender {
    
    [[self textField] resignFirstResponder];
    NSString *text = [[self textField] text];
    if (!text || [text isEqualToString:@""])
        [[self navigationController] popViewControllerAnimated:YES];
    
    if ([self numericEntryMode]) {
        NSNumber *numberValue = [NSNumber numberWithString:text];
        if (!numberValue || [numberValue compare:INT_OBJ(0)] == NSOrderedAscending) {
            NSString *errorMessage = NSLocalizedString(@"Enter a number greater than 0", @">0 error message");
            NSString *errorTitle = NSLocalizedString(@"Bad Value", @"error title");
            [ErrorAlert showWithTitle:errorTitle andMessage:errorMessage];
            [[self textField] becomeFirstResponder];
            return;
        }
    }
    [self setReturnString:text];
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [textField release];
    [returnString release];
    [super dealloc];
}


@end
