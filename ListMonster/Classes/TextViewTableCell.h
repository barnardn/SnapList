//
//  TextViewTableCell.h
//  ListMonster
//
//  Created by Norm Barnard on 12/20/12.
//
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

extern const NSInteger kTextViewTag;

@interface TextViewTableCell : UITableViewCell

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, weak) id<UITextViewDelegate> delegate;

@end
