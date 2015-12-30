//
//  OverdueItemTableViewCell.m
//  ListMonster
//
//  Created by Norm Barnard on 12/30/15.
//
//

#import "OverdueItemTableViewCell.h"
#import "ThemeManager.h"

@implementation OverdueItemTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.textLabel.textColor = [ThemeManager standardTextColor];
    self.textLabel.highlightedTextColor = [ThemeManager highlightedTextColor];
    self.detailTextLabel.textColor = [ThemeManager textColorForListDetails];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.detailTextLabel.textColor = [ThemeManager textColorForListDetails];
}

- (UIEdgeInsets)layoutMargins {
    return UIEdgeInsetsZero;
}

#pragma mark - property overrides

- (NSString *)name {
    return self.textLabel.text;
}

- (void)setName:(NSString *)name {
    self.textLabel.text = name;
}

- (NSString *)detailText {
    return self.detailTextLabel.text;
}

- (void)setDetailText:(NSString *)detailText {
    self.detailTextLabel.text = detailText;
}

- (void)setOverdue:(BOOL)overdue {
    _overdue = overdue;
    self.detailTextLabel.textColor = (overdue) ? [ThemeManager textColorForOverdueItems] : [ThemeManager textColorForListDetails];
}



@end
