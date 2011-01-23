//
//  ColorSelectViewController.h
//  ListMonster
//
//  Created by Norm Barnard on 1/23/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ListColor;

@interface ColorSelectViewController : UITableViewController {
    
    NSArray *allColors;
    ListColor *defaultColor;
}

@property(nonatomic,retain) NSArray *allColors;
@property(nonatomic,retain) ListColor *defaultColor;

- (id)initWithColor:(ListColor *)color;
- (ListColor *)returnValue;


@end
