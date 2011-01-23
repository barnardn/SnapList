// 
//  ListColor.m
//  ListMonster
//
//  Created by Norm Barnard on 1/22/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import "ListColor.h"
#import "MetaList.h"

@implementation ListColor 

@dynamic rgbValue;
@dynamic name;
@dynamic swatchFilename;
@dynamic list;


- (UIColor *)uiColor {
    
    NSInteger colorInt = [[self rgbValue] intValue];
    NSInteger redPart = (colorInt & lcRED_MASK) >> 16;
    NSInteger greenPart = (colorInt & lcGREEN_MASK) >> 8;
    NSInteger bluePart = (colorInt & lcBLUE_MASK);
    return [UIColor colorWithRed:(redPart/255.0f) green:(greenPart/255.0f) blue:(bluePart/255.0f) alpha:1.0f];
}



@end
