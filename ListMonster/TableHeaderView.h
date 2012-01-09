//
//  TableHeaderView.h
//  ListMonster
//
//  Created by Norm Barnard on 1/8/12.
//  Copyright (c) 2012 clamdango.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableHeaderView : UIView

@property(nonatomic,retain) UILabel *titleLabel;

- (id)initWithFrame:(CGRect)frame headerTitle:(NSString *)title;

@end
