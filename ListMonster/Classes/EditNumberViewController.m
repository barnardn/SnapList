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

@synthesize numericTextField, item, viewTitle;


- (id)initWithTitle:(NSString *)aTitle listItem:(MetaListItem *)anItem 
{
    self = [super initWithNibName:@"EditNumberView" bundle:nil];
    if (!self) return nil;
    [self setViewTitle:aTitle];
    [self setItem:anItem];
    numFormatter = [[NSNumberFormatter alloc] init];
    [numFormatter setPositiveFormat:@"#0.00"];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return ((toInterfaceOrientation == UIInterfaceOrientationPortrait) ||
            (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown));
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
        NSString *numString = [numFormatter stringFromNumber:[[self item] quantity]];
        [[self numericTextField] setText:numString];
    }
    [[self numericTextField] setKeyboardType:UIKeyboardTypeDecimalPad];
    [[self numericTextField] becomeFirstResponder];
    firstDigitEntered = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[self numericTextField] resignFirstResponder];
    NSString *enteredText = [[self numericTextField] text];
    NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:enteredText];
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@""]) return  YES;
    NSString *decimalChar = [[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator];
    if (![string isEqualToString:decimalChar]) return YES;
    NSString *text = [textField text];
    NSArray *parts = [text componentsSeparatedByString:decimalChar];
    return ([parts count] == 1);

}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [[self numericTextField] resignFirstResponder];
    [[self navigationController] popViewControllerAnimated:YES];
    return YES;
}


@end
