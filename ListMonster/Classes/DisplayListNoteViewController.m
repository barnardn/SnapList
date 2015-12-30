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

@interface DisplayListNoteViewController()

@property (weak, nonatomic) UITextView *textView;
@property (strong, nonatomic) MetaList *list;

@end


@implementation DisplayListNoteViewController

- (instancetype)initWithList:(MetaList *)list; {
    self = [super init];
    if (!self) return nil;
    _list = list;
    return self;
}

- (NSString *)title {
    return NSLocalizedString(@"Notes", @"list notes navigation bar title");
}

- (CGSize)contentSizeForViewInPopover {
    return CGSizeMake(240.0f, 200.0f);
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self view] setBackgroundColor:[UIColor whiteColor]];
    UITextView *textView = [[UITextView alloc] init];
    [textView setText:self.list.note];
    [textView setBackgroundColor:[UIColor clearColor]];
    [textView setFont:[ThemeManager fontForListNote]];
    [textView setEditable:NO];
    self.textView = textView;
    [[self view] addSubview:textView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(_doneButtonTapped:)];
}

- (void)viewDidLayoutSubviews {
    self.textView.frame = self.view.bounds;
}

- (IBAction)_doneButtonTapped:(UIBarButtonItem *)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
