//
//  EditCategoryViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 2/27/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import "Alerts.h"
#import "Category.h"
#import "EditCategoryViewController.h"

@interface EditCategoryViewController()

- (UIBarButtonItem *)doneButton;
- (UINavigationBar *)navigationBarForModalView;
- (void)adjustTextFieldForModalView;
- (void)dismissMyself;

@end


@implementation EditCategoryViewController

@synthesize categoryNameField, category, navBar, delegate, theList;
@synthesize backgroundImageView;

- (id)initWithList:(MetaList *)aList {
    
    self = [super initWithNibName:@"EditCategoryView" bundle:nil];
    if (!self) return nil;
    [self setTheList:aList];
    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return nil;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [self setBackgroundImageView:nil];
    [self setCategoryNameField:nil];
    [self setNavBar:nil];
}


- (void)dealloc {
    [navBar release];
    [categoryNameField release];
    [category release];
    [backgroundImageView release];
    [super dealloc];
}


#pragma mark -
#pragma mark View lifecycle methods

- (void)viewDidLoad {
    [super viewDidLoad];    
    [[self backgroundImageView] setImage:[UIImage imageNamed:@"Backgrounds/normal"]];
    if (![self navigationController]) {
        [self setNavBar:[self navigationBarForModalView]];
        [[self view] addSubview:[self navBar]];
        [self adjustTextFieldForModalView];
        [[self view] setNeedsLayout];
        return;
    }
    [[self navigationItem] setRightBarButtonItem:[self doneButton]];
    [[self navigationItem] setTitle:NSLocalizedString(@"Edit Category", @"edit category nav title")];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (![[self category] name])
        [[self categoryNameField] setPlaceholder:NSLocalizedString(@"Enter a category name", @"category name field placeholder")];
    else
        [[self categoryNameField] setText:[[self category] name]];        
    [[self categoryNameField] becomeFirstResponder];
}


- (UINavigationBar *)navigationBarForModalView {
    
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    CGRect navFrame = CGRectMake(0, 0, width, 44.0f);
    UINavigationBar *nb = [[UINavigationBar alloc] initWithFrame:navFrame];
    
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"cancel button")
                                                                  style:UIBarButtonItemStylePlain 
                                                                 target:self 
                                                                 action:@selector(cancelPressed:)];
    
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:NSLocalizedString(@"Add Category", @"add category title")];
    [navItem setLeftBarButtonItem:cancelBtn];
    [navItem setRightBarButtonItem:[self doneButton]];
    [nb pushNavigationItem:navItem animated:NO];
    [cancelBtn release];
    [navItem release];
    return [nb autorelease];
}

- (UIBarButtonItem *)doneButton {
    
    return [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"done button")
                                             style:UIBarButtonItemStyleDone 
                                            target:self 
                                            action:@selector(donePressed:)] autorelease];
}

- (void)adjustTextFieldForModalView {
    
    if (![self navBar]) return;
    
    CGRect navBarFrame = [[self navBar] frame];
    CGRect tvf = [[self categoryNameField] frame];
    CGRect newFrame = CGRectMake(tvf.origin.x, navBarFrame.size.height+20.0f, tvf.size.width, tvf.size.height);
    [self categoryNameField].frame = newFrame;

}


#pragma mark -
#pragma mark Button actions

- (void)cancelPressed:(id)sender {

    [[self delegate] editCategoryViewController:self didEditCategory:nil];
    [self dismissMyself];
}

- (void)donePressed:(id)sender {
    
    NSString *newName = [[self categoryNameField] text];
    if (!newName || [newName isEqualToString:@""]) {
        [ErrorAlert showWithTitle:@"Bad Name" andMessage:@"Category names can not be empty"];
        return;
    }
    [[self category] setName:newName];
    [[self delegate] editCategoryViewController:self didEditCategory:[self category]];
    [self dismissMyself];
}

- (void)dismissMyself {
    [self resignFirstResponder];
    if (![self navigationController]) {
        if ([[self parentViewController] respondsToSelector:@selector(dismissModalViewControllerAnimated:)])
            [[self parentViewController] dismissModalViewControllerAnimated:YES];
        else
            [[self presentingViewController] dismissModalViewControllerAnimated:YES];
    }
    [[self navigationController] popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UITextField delegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self donePressed:nil];
    return YES;
    
}


@end
