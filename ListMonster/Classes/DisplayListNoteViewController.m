//
//  DisplayListNoteViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 8/14/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import "DisplayListNoteViewController.h"
#import "MetaList.h"
#import "TableHeaderView.h"
#import "ThemeManager.h"

@implementation DisplayListNoteViewController

- (id)initWithNoteText:(NSString *)noteText;
{
    self = [super init];
    if (!self) return nil;
    _noteText = noteText;
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (CGSize)contentSizeForViewInPopover
{
    return CGSizeMake(240.0f, 200.0f);
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self view] setBackgroundColor:[UIColor colorWithRed:1.0f green:(234.0f/255.0f) blue:0 alpha:1.0f]];
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 240.0f, 200.0f)];
    [textView setText:[self noteText]];
    [textView setEditable:NO];
    [textView setBackgroundColor:[UIColor clearColor]];
    [textView setFont:[ThemeManager fontForListNote]];
    [[self view] addSubview:textView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}


@end
