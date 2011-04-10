//
//  EditNoteViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 4/8/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import "EditNoteViewController.h"
#import "MetaList.h"


@implementation EditNoteViewController

@synthesize noteTextView, theList;


- (id)initWithList:(MetaList *)list {
    
    self = [super initWithNibName:@"EditNoteView" bundle:nil];
    if (!self) return nil;
    [self setTheList:list];
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return nil;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [theList release];
    [noteTextView release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", @"back button title")
                                                                style:UIBarButtonItemStylePlain 
                                                                target:nil 
                                                                action:nil];
    [[self navigationItem] setBackBarButtonItem:backBtn];
    [backBtn release];
    [[self navigationItem] setTitle:NSLocalizedString(@"Enter Note", @"edit note view title")];
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [[self view] addGestureRecognizer:tapRecognizer];
    [tapRecognizer release];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([[self theList] note])
        [[self noteTextView] setText:[[self theList] note]];
    [[self noteTextView] becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[self noteTextView] resignFirstResponder];
    NSString *noteText = [[self noteTextView] text];
    if (!noteText || [noteText length] == 0)
        [[self theList] setNote:nil];
    else
        [[self theList] setNote:noteText];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)dismissKeyboard:(id)sender {
    [[self noteTextView] resignFirstResponder];
}



@end
