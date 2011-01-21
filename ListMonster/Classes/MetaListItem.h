//
//  ListItem.h
//  ListMonster
//
//  Created by Norm Barnard on 12/27/10.
//  Copyright 2010 clamdango.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef enum mlListColors {
    Black,
    Red,
    Green,
    Blue,
    Gold,
    Turquoise,
    Orange,
    Megenta
};

@class MetaList;

@interface MetaListItem : NSManagedObject {

}

@property (nonatomic, retain) NSNumber *isChecked;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *quantity;
@property (nonatomic, retain) MetaList *list;

@end
