//
//  EditNumberViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 4/29/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import "EditNumberViewController.h"
#import "MetaListItem.h"
#import "ThemeManager.h"

@interface EditNumberViewController()

@property (assign, nonatomic) BOOL firstDigitEntered;
@property (strong, nonatomic) NSNumberFormatter *numFormatter;

@end

@implementation EditNumberViewController


- (id)initWithTitle:(NSString *)aTitle listItem:(MetaListItem *)anItem 
{
    self = [super init];
    if (!self) return nil;
    [self setViewTitle:aTitle];
    [self setItem:anItem];
    _numFormatter = [[NSNumberFormatter alloc] init];
    [_numFormatter setPositiveFormat:@"#0.00"];
    return self;
}

- (NSString *)nibName {
    return @"EditNumberView";
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return ((toInterfaceOrientation == UIInterfaceOrientationPortrait) ||
            (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown));
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];
    self.view.backgroundColor = [ThemeManager appBackgroundColor];
    if (![[self item] quantity] || [[[self item] quantity] compare:INT_OBJ(0)] == NSOrderedSame) {
        [[self numericTextField] setPlaceholder:NSLocalizedString(@"Value", @"numeric value placeholder")];        
    }
    else {
        NSString *numString = [self.numFormatter stringFromNumber:[[self item] quantity]];
        [[self numericTextField] setText:numString];
    }
    [[self numericTextField] setKeyboardType:UIKeyboardTypeDecimalPad];
    [[self numericTextField] becomeFirstResponder];
    self.firstDigitEntered = NO;
}

- (NSString *)title {
    return NSLocalizedString(@"Edit Quantity", @"quantity view controller title");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[self numericTextField] resignFirstResponder];
    NSString *enteredText = [[self numericTextField] text];
    NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:enteredText];
    if ([number compare:INT_OBJ(0)] == NSOrderedAscending) {
        return;
    }
    [[self item] setQuantity:number];
    [[self delegate] editItemViewController:self didChangeValue:number forItem:[self item]];
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
