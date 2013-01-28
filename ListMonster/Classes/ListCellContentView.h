//
//  ListCellContentView.h
//  ListMonster
//
//  Created by Norm Barnard on 1/27/13.
//
//

#import <UIKit/UIKit.h>

@interface ListCellContentView : UIView

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UIButton *btnShowNote;
@property (nonatomic, strong) NSString *noteText;

@end
