//
//  ListCell.h
//  ListMonster
//
//  Created by Norm Barnard on 3/5/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ListCell : UITableViewCell 

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *detailText;
@property (assign, nonatomic, getter=isListCompleted) BOOL listCompleted;
@end
