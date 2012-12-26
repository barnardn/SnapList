//
//  SelectColorView.h
//  ListMonster
//
//  Created by Norm Barnard on 12/23/12.
//
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@protocol SelectColorDelegate;

@interface SelectColorView : UIView

@property (nonatomic, weak) IBOutlet UILabel *lblColorName;
@property (nonatomic, weak) IBOutlet UIButton *btnColorName;
@property (nonatomic, weak) id<SelectColorDelegate> delegate;

@end

@protocol SelectColorDelegate <NSObject>

- (void)selectColorView:(SelectColorView *)colorView didSelectColor:(NSString *)colorCode;

@end
