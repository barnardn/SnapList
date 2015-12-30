//
//  OverdueItemTableViewCell.h
//  ListMonster
//
//  Created by Norm Barnard on 12/30/15.
//
//

#import <UIKit/UIKit.h>

@interface OverdueItemTableViewCell : UITableViewCell

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *detailText;
@property (assign, nonatomic, getter=isOverdue) BOOL overdue;

@end
