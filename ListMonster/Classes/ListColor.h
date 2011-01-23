//
//  ListColor.h
//  ListMonster
//
//  Created by Norm Barnard on 1/22/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import <CoreData/CoreData.h>

#define lcRED_MASK      0x00ff0000
#define lcGREEN_MASK    0x0000ff00
#define lcBLUE_MASK     0x000000ff

@class MetaList;

@interface ListColor :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber *rgbValue;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *swatchFilename;
@property (nonatomic, retain) NSSet *list;

- (UIColor *)uiColor;

@end


