//
//  ListItemCell.h
//  ListMonster
//
//  Created by Norm Barnard on 10/6/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MetaListItem;

#define FONT_SIZE 14.0f
#define CELL_CONTENT_WIDTH 255.0f
#define CELL_CONTENT_MARGIN 5.0f

@interface ListItemCell : UITableViewCell

@property(nonatomic,retain) UIImage *editModeImage;
@property(nonatomic,retain) UIImage *normalModeImage;


@end
