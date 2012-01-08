//
//  TextEntryViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 1/22/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import "ListMonsterAppDelegate.h"
#import "ListNameViewController.h"

@interface ListNameViewController()

- (BOOL)didListnameChange;

@end


@implementation ListNameViewController

@synthesize textField, theList, backgroundImageView;

- (id)initWithList:(MetaList *)aList {
    
    self = [super initWithNibName:@"ListNameView" bundle:nil];
    if (!self) return nil;
    
    [self setTheList:aList];
    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationItem] setTitle:NSLocalizedString(@"List Name", @"list name view title")];
    [[self textField] setPlaceholder:NSLocalizedString(@"Enter list name", @"list name textfield placeholder")];
    if ([[self theList] name]) 
        [[self textField] setText:[[self theList] name]];
    [[self backgroundImageView] setImage:[UIImage imageNamed:@"Backgrounds/normal"]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[self textField] becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[self textField] resignFirstResponder];
    if ([self didListnameChange]) {
        NSString *newName = [[self textField] text];
        [[self theList] setName:newName];
    }
}

- (BOOL)didListnameChange {
    
    NSString *listName = [[self theList] name];
    NSString *newName = [[self textField] text];
    return (![listName isEqualToString:newName] && (![newName isEqualToString:@""]));
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [self setTextField:nil];
    [self setBackgroundImageView:nil];
}


- (void)dealloc {
    [textField release];
    [theList release];
    [backgroundImageView release];
    [super dealloc];
}

#pragma mark -
#pragma mark UITextField delegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)txtField {
    
    [txtField resignFirstResponder];
    [[self navigationController] popViewControllerAnimated:YES];
    return YES;
}





@end
