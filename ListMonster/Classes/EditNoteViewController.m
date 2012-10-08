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

@synthesize noteTextView, theList, backgroundImageView;


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
    [self setNoteTextView:nil];
    [self setBackgroundImageView:nil];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", @"back button title")
                                                                style:UIBarButtonItemStylePlain 
                                                                target:nil 
                                                                action:nil];
    [[self navigationItem] setBackBarButtonItem:backBtn];
    [[self navigationItem] setTitle:NSLocalizedString(@"Enter Note", @"edit note view title")];
    UIBarButtonItem *clearTextButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Clear", nil) 
                                                                        style:UIBarButtonItemStylePlain 
                                                                       target:self 
                                                                       action:@selector(clearText:)];
    [[self navigationItem] setRightBarButtonItem:clearTextButton];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [[self view] addGestureRecognizer:tapRecognizer];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return ((toInterfaceOrientation == UIInterfaceOrientationPortrait) ||
            (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown));
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)clearText:(id)sender
{
    [[self noteTextView] setText:nil];
}

- (void)dismissKeyboard:(id)sender {
    [[self noteTextView] resignFirstResponder];
}



@end
