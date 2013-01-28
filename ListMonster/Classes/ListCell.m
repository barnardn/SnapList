//
//  ListCell.m
//  ListMonster
//
//  Created by Norm Barnard on 3/5/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import "ListCell.h"
#import "ListCellContentView.h"

@interface ListCell()

@property (nonatomic, weak) IBOutlet UIButton *btnShowNote;
@property (nonatomic, weak) ListCellContentView *cellContentView;
@end

@implementation ListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    CGRect cvFrame = [[self contentView] frame];
    cvFrame.size.height = 50.0f;
    ListCellContentView *cv = [[ListCellContentView alloc] initWithFrame:cvFrame];
    [[self contentView] addSubview:cv];
    [self setCellContentView:cv];
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setNoteText:(NSString *)noteText
{
    _noteText = noteText;
    [[self cellContentView] setNoteText:noteText];
    [[self cellContentView] setNeedsLayout];
    [self setNeedsLayout];
}

- (UILabel *)nameLabel
{
    return [[self cellContentView] nameLabel];
}


@end
