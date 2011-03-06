//
//  ListCell.h
//  ListMonster
//
//  Created by Norm Barnard on 3/5/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ListCell : UITableViewCell {
    UILabel *nameLabel;
    UILabel *categoryLabel;
    UILabel *countsLabel;
}

@property(nonatomic,retain) IBOutlet UILabel *nameLabel;
@property(nonatomic,retain) IBOutlet UILabel *categoryLabel;
@property(nonatomic,retain) IBOutlet UILabel *countsLabel;


@end
