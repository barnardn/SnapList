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

@synthesize textView, viewTitle,backgroundImageFilename, item;

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

- (void)dealloc 
{
    [textView release];
    [item release];
    [super dealloc];
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
    [[self navigationItem] setTitle:[self viewTitle]];
    if (![self item] || ![[self item] name])
        [[self textView] setText:@""];        
    else 
        [[self textView] setText:[[self item] name]];
    if ([self backgroundImageFilename]) {
        [[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:[self backgroundImageFilename]]]];
    }
    UIBarButtonItem *clearTextButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Clear", nil) 
                                                                        style:UIBarButtonItemStylePlain 
                                                                       target:self 
                                                                       action:@selector(clearText:)];
    [[self navigationItem] setRightBarButtonItem:clearTextButton];
    [clearTextButton release];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [[self view] addGestureRecognizer:tapRecognizer];
    [tapRecognizer release];
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
}

- (void)clearText:(id)sender
{
    [[self textView] setText:nil];
}

- (void)dismissKeyboard:(id)sender {
    [[self textView] resignFirstResponder];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}




@end
