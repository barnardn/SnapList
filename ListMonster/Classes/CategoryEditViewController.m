//
//  TextEntryViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 2/5/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import "Category.h"
#import "CategoryEditViewController.h"
#import "ListMonsterAppDelegate.h"

@interface CategoryEditViewController()

- (void)performContextSave;

@end

@implementation CategoryEditViewController

@synthesize textField, categoryToEdit;

#pragma mark -
#pragma mark View lifecycle

- (id)initWithCategory:(Category *)theCategory {
    
    if (!(self = [super initWithNibName:@"CategoryEditView" bundle:nil])) 
        return nil;
    
    [self setCategoryToEdit:theCategory];
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithCategory:nil];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"done button")
                                                                   style:UIBarButtonItemStyleDone 
                                                                  target:self 
                                                                  action:@selector(donePressed:)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"cancel button")
                                                                     style:UIBarButtonItemStyleDone 
                                                                    target:self 
                                                                    action:@selector(cancelPressed:)];
    [[self navigationItem] setRightBarButtonItem:doneButton];
    [[self navigationItem] setLeftBarButtonItem:cancelButton];
    [doneButton release];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationItem] setTitle:NSLocalizedString(@"Edit Category", @"category edit view title")];
    [[self textField] setText:[[self categoryToEdit] name]];
}

- (IBAction)donePressed:(id)sender {
    
    Category *category = [self categoryToEdit];
    if (!category) {
        NSManagedObjectContext *moc = [[ListMonsterAppDelegate sharedAppDelegate] managedObjectContext];
        NSEntityDescription *categoryEntity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:moc];
        category = [[Category alloc] initWithEntity:categoryEntity insertIntoManagedObjectContext:moc];
    }
    [category setName:[[self textField] text]];
    [self performContextSave];
    [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)cancelPressed:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)performContextSave {
    NSManagedObjectContext *moc = [[ListMonsterAppDelegate sharedAppDelegate] managedObjectContext];
    NSError *error = nil;
    [moc save:&error];
    if (error) {
        DLog(@"Unable to save category: %@", [error localizedDescription]);
    }
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [textField release];
    [categoryToEdit release];
    [super dealloc];
}


@end

