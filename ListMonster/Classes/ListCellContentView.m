//
//  ListCellContentView.m
//  ListMonster
//
//  Created by Norm Barnard on 1/27/13.
//
//

#import "DisplayListNoteViewController.h"
#import "ListCellContentView.h"
#import "WEPopoverController.h"

@interface ListCellContentView()

@property (nonatomic, strong) WEPopoverController *popover;

@end


@implementation ListCellContentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ListCellContentView" owner:self options:nil];
    [self addSubview:[nib objectAtIndex:0]];
    
    [_btnShowNote addTarget:self action:@selector(btnShowNoteTapped:) forControlEvents:UIControlEventTouchUpInside];
    return self;
}

- (void)layoutSubviews
{
    CGRect labelFrame = [[self nameLabel] frame];
    if ([[self noteText] length] == 0) {
        labelFrame.origin.x = 8.0f;
        [[self nameLabel] setFrame:labelFrame];
        [[self btnShowNote] setHidden:YES];
        return;
    }
    labelFrame.origin.x = 34.0f;
    [[self nameLabel] setFrame:labelFrame];
    [[self btnShowNote] setHidden:NO];
}

- (IBAction)btnShowNoteTapped:(UIButton *)sender
{
    if ([[self popover] isPopoverVisible])
        [[self popover] dismissPopoverAnimated:YES];
    
    DisplayListNoteViewController *vcNoteDisplay = [[DisplayListNoteViewController alloc] initWithNoteText:[self noteText]];
    WEPopoverController *pvc = [[WEPopoverController alloc] initWithContentViewController:vcNoteDisplay];
    [self setPopover:pvc];
    [pvc presentPopoverFromRect:[[self btnShowNote] frame] inView:[self btnShowNote] permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
}


@end
