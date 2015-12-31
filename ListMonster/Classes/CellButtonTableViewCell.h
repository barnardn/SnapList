//
//  CellButtonTableViewCell.h
//  ListMonster
//
//  Created by Norm Barnard on 12/31/15.
//
//

#import <UIKit/UIKit.h>

@interface CellButtonTableViewCell : UITableViewCell


@property (nonatomic) NSString *buttonTitle;
@property (assign, nonatomic, getter=isDestructive) BOOL destructive;

@end
