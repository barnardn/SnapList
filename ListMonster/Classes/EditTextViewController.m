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
#import "MetaListItem.h"


@implementation EditTextViewController

@synthesize textView, viewTitle, item;

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

- (void)viewDidUnload 
{
    [super viewDidUnload];
    [self setTextView:nil];
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
    [[self navigationItem] setTitle:[self viewTitle]];
    if (![self item] || ![[self item] name])
        [[self textView] setText:@""];        
    else 
        [[self textView] setText:[[self item] name]];
    UIBarButtonItem *clearTextButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Clear", nil) 
                                                                        style:UIBarButtonItemStylePlain 
                                                                       target:self 
                                                                       action:@selector(clearText:)];
    [[self navigationItem] setRightBarButtonItem:clearTextButton];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [[self view] addGestureRecognizer:tapRecognizer];
    [[self textView] becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated 
{
    [super viewWillDisappear:animated];
    [[self textView] resignFirstResponder];
    NSString *text = [[self textView] text];
    if (!text || [text isEqualToString:@""]) 
        return;
    [[self item] setName:text];
    [[self delegate] editItemViewController:self didChangeValue:text forItem:[self item]];
}

- (void)clearText:(id)sender
{
    [[self textView] setText:nil];
}

- (void)dismissKeyboard:(id)sender {
    [[self textView] resignFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return ((toInterfaceOrientation == UIInterfaceOrientationPortrait) ||
            (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown));
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}




@end
