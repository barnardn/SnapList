//
//  ListCell.m
//  ListMonster
//
//  Created by Norm Barnard on 3/5/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import "ListCell.h"
#import "ThemeManager.h"

@interface ListCell()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@end

@implementation ListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.tintColor = [ThemeManager brandColor];
    self.selectionStyle = UITableViewCellSelectionStyleGray;
    self.nameLabel.font = [ThemeManager fontForListName];
    self.nameLabel.textColor = [ThemeManager standardTextColor];
    self.nameLabel.highlightedTextColor = [ThemeManager highlightedTextColor];
    self.detailLabel.font = [ThemeManager fontForListDetails];
    self.detailLabel.textColor = [ThemeManager textColorForListDetails];
}

- (UIEdgeInsets)layoutMargins {
    return UIEdgeInsetsZero;
}

- (void)setName:(NSString *)name {
    self.nameLabel.text = name;
    [self setNeedsUpdateConstraints];
}

- (NSString *)name {
    return self.nameLabel.text;
}

- (NSString *)detailText {
    return self.detailLabel.text;
}

- (void)setDetailText:(NSString *)detailText {
    self.detailLabel.text = detailText;
    [self setNeedsUpdateConstraints];
}

- (void)setListCompleted:(BOOL)listCompleted {
    self.nameLabel.textColor = (listCompleted) ? [ThemeManager ghostedTextColor] : [ThemeManager standardTextColor];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.nameLabel.textColor = [ThemeManager standardTextColor];
}
@end
