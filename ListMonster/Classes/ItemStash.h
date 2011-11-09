//
//  ItemStash.h
//  ListMonster
//
//  Created by Norm Barnard on 4/10/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Measure;

@interface ItemStash : NSManagedObject {

}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber *quantity;
@property (nonatomic, retain) Measure *unitOfMeasure;

+ (void)addToStash:(NSString *)itemName quantity:(NSNumber *)quantity measure:(Measure *)measure;

@end
