//
//  CellButtonTableViewCell.m
//  ListMonster
//
//  Created by Norm Barnard on 12/31/15.
//
//

#import "CellButtonTableViewCell.h"
#import "ThemeManager.h"

@interface CellButtonTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation CellButtonTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.titleLabel.font = [ThemeManager fontForStandardListText];
    self.titleLabel.textColor = [ThemeManager brandColor];
    self.selectedBackgroundView = [UIView new];
    self.selectedBackgroundView.backgroundColor = [ThemeManager brandColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    UIColor *selectedColor = self.isDestructive ? [UIColor redColor] : [ThemeManager brandColor];
    self.titleLabel.textColor = (selected) ? [UIColor whiteColor] : selectedColor;
}

- (void)setDestructive:(BOOL)destructive {
    _destructive = destructive;
    self.titleLabel.textColor = (destructive) ? [UIColor redColor] : [ThemeManager brandColor];
    self.selectedBackgroundView.backgroundColor = (destructive) ? [UIColor redColor] : [ThemeManager brandColor];
}

- (NSString *)buttonTitle {
    return self.titleLabel.text;
}

- (void)setButtonTitle:(NSString *)buttonTitle {
    self.titleLabel.text = buttonTitle;
}

- (UIEdgeInsets)layoutMargins {
    return UIEdgeInsetsZero;
}

@end
