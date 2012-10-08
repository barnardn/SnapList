//
//  TableHeaderView.m
//  ListMonster
//
//  Created by Norm Barnard on 1/8/12.
//  Copyright (c) 2012 clamdango.com. All rights reserved.
//

#import "TableHeaderView.h"

@implementation TableHeaderView

@synthesize titleLabel;


- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame headerTitle:@""];
}

- (id)initWithFrame:(CGRect)frame headerTitle:(NSString *)title
{
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    UIFont *headerFont = [UIFont fontWithName:@"Helvetica-Bold" size:18.0f];
    //CGFloat yPos = (frame.size.height - textSize.height) / 2.0f;
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 0, frame.size.width, frame.size.height)];
    [lbl setText:title];
    [lbl setFont:headerFont];
    [lbl setTextColor:[UIColor whiteColor]];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setShadowOffset:CGSizeMake(1.0f, 1.0f)];
    [lbl setShadowColor:[UIColor blackColor]];
    [self addSubview:lbl];
    [self setTitleLabel:lbl];
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
