//
//  LeftDetailTableViewCell.m
//  ListMonster
//
//  Created by Norm Barnard on 12/31/15.
//
//

#import "LeftDetailTableViewCell.h"
#import "ThemeManager.h"

@implementation LeftDetailTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.detailTextLabel.font = [ThemeManager fontForListNote];
    self.textLabel.font = [ThemeManager fontForListName];
}

- (NSString *)titleText {
    return self.textLabel.text;
}

- (void)setTitleText:(NSString *)titleText {
    self.textLabel.text = titleText;
}

- (NSString *)detailText {
    return self.detailTextLabel.text;
}

- (void)setDetailText:(NSString *)detailText {
    self.detailTextLabel.text = detailText;
}

@end
