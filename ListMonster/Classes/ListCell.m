//
//  ListCell.m
//  ListMonster
//
//  Created by Norm Barnard on 3/5/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import "ListCell.h"


@implementation ListCell

@synthesize nameLabel, categoryLabel, countsLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}




@end
