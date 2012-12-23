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

@implementation DisplayListNoteViewController

@synthesize list, backgroundImageFilename;

- (id)initWithList:(MetaList *)aList
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (!self) return nil;
    [self setList:aList];
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    return nil;
}



- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self view] setBackgroundColor:[UIColor lightGrayColor]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return ((toInterfaceOrientation == UIInterfaceOrientationPortrait) ||
            (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown));
}

- (IBAction)dismissButtonPressed:(id)sender
{
    if ([[self parentViewController] respondsToSelector:@selector(dismissModalViewControllerAnimated:)])
        [[self parentViewController] dismissModalViewControllerAnimated:YES];
    else
        [[self presentingViewController] dismissModalViewControllerAnimated:YES];    
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    // Return the number of rows in the section.
    return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier = @"Cell";
    static NSString *ButtonCellIdentifier = @"ButtonCell";
    NSString *cellId = nil;
    UILabel *label = nil;
    
    BOOL isTextCell = ([indexPath section] == 0);
    cellId = (isTextCell) ? CellIdentifier : ButtonCellIdentifier;    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        if (isTextCell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            label = [[UILabel alloc] initWithFrame:CGRectZero];
            [label setLineBreakMode:UILineBreakModeWordWrap];
            [label setMinimumFontSize:FONT_SIZE];
            [label setNumberOfLines:0];
            [label setFont:[UIFont systemFontOfSize:FONT_SIZE]];
            [label setTag:1];
            [[cell contentView] addSubview:label];
             label = nil;
        } else {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (isTextCell) {
        NSString *text = [[self list] note];
        CGSize constraint = CGSizeMake(NOTECELL_CONTENT_WIDTH - (NOTECELL_CONTENT_WIDTH * 2), 20000.0f);
        CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        if (!label)
            label = (UILabel*)[cell viewWithTag:1];
        [label setTextColor:[UIColor blackColor]];
        if (!text) {
            text = NSLocalizedString(@"Edit the list to add a note", nil);
            [label setTextColor:[UIColor lightGrayColor]];
        }
        [label setText:text];
        [label setFrame:CGRectMake(NOTECELL_CONTENT_MARGIN, NOTECELL_CONTENT_MARGIN, NOTECELL_CONTENT_WIDTH - (NOTECELL_CONTENT_MARGIN * 2), MAX(size.height, 34.0f))];
    } else {
        UIImage *dismissButtonImage = [[UIImage imageNamed:@"blueButton.png"] stretchableImageWithLeftCapWidth:12.0f topCapHeight:0.0f];
        UIImageView *dismissBgView = [[UIImageView alloc] initWithImage:dismissButtonImage];
        [cell setBackgroundView:dismissBgView];
        [[cell textLabel] setText:NSLocalizedString(@"Dismiss", nil)];
        [[cell textLabel] setBackgroundColor:[UIColor clearColor]];
        [[cell textLabel] setTextAlignment:UITextAlignmentCenter];
        [[cell textLabel] setTextColor:[UIColor whiteColor]];
    }
    return cell;
}


#pragma mark -
#pragma Table view delegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0.0f, 320.0f, 24.0f)];
    [emptyLabel setBackgroundColor:[UIColor clearColor]];
    if (section != 0) return emptyLabel;
    
    TableHeaderView *header = [[TableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 24.0f) headerTitle:[[self list] name]];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 24.0f;
}

- (CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 1) return 34.0f;
    NSString *text = [[self list] note];
    CGSize constraint = CGSizeMake(NOTECELL_CONTENT_WIDTH - (NOTECELL_CONTENT_MARGIN * 2), 20000.0f);
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    CGFloat height = MAX(size.height, 34.0f);
    return height + (NOTECELL_CONTENT_MARGIN * 2);  
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if ([indexPath section] == 0) return;
    if ([[self parentViewController] respondsToSelector:@selector(dismissModalViewControllerAnimated:)])
        [[self parentViewController] dismissModalViewControllerAnimated:YES];
    else
        [[self presentingViewController] dismissModalViewControllerAnimated:YES];   
}


@end
