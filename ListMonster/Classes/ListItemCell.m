//
//  ListItemCell.m
//  ListMonster
//
//  Created by Norm Barnard on 10/6/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import "ListItemCell.h"
#import "MetaListItem.h"

@interface ListItemCell()

- (void)adjustNameLabel:(UILabel *)nameLabel isEditing:(BOOL)editing;

@end


@implementation ListItemCell

@synthesize editModeImage, normalModeImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [self setNeedsLayout];
}

- (void)setNeedsLayout
{
    //[UIView beginAnimations:nil context:nil];
    //[UIView setAnimationBeginsFromCurrentState:YES];
    
    [super layoutSubviews];
    
    UITableView *parentView = (UITableView *)[self superview];
    if ([parentView isEditing])
    {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self setAccessoryType:UITableViewCellAccessoryNone];
        [[self imageView] setImage:[self editModeImage]];
        CGRect contentFrame = [self contentView].frame;
        contentFrame.origin.x = CELL_ORIGIN_X; 
        [self contentView].frame = contentFrame;
    }
    else
    {
        [self setSelectionStyle:UITableViewCellSelectionStyleBlue];
        [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [[self imageView] setImage:[self normalModeImage]];
        CGRect contentFrame = [self contentView].frame;
        contentFrame.origin.x = CELL_ORIGIN_X; 
        [self contentView].frame = contentFrame;
    }
    UILabel *nameLabel = (UILabel *)[self viewWithTag:1];;
    [self adjustNameLabel:nameLabel isEditing:[parentView isEditing]];
    //[UIView commitAnimations];
}


- (void)adjustNameLabel:(UILabel *)nameLabel isEditing:(BOOL)editing
{
    NSString *name = [nameLabel text];
    CGFloat contentMargin = CELL_CONTENT_MARGIN;
    CGFloat lblStart = CELL_ORIGIN_X; 
    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (contentMargin * 2), 20000.0f);
    CGSize size = [name sizeWithFont:[UIFont systemFontOfSize:CELL_FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    [nameLabel setText:name];
    [nameLabel setFrame:CGRectMake(lblStart, contentMargin, CELL_CONTENT_WIDTH - (contentMargin * 2), MAX(size.height, 34.0f))];	
}

@end
