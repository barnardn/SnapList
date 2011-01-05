//
//  Schedule.h
//  ListMonster
//
//  Created by Norm Barnard on 12/27/10.
//  Copyright 2010 clamdango.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MetaList;

@interface Schedule : NSManagedObject {

}

@property (nonatomic, retain) NSNumber *monday;
@property (nonatomic, retain) NSNumber *tuesday;
@property (nonatomic, retain) NSNumber *wednesday;
@property (nonatomic, retain) NSNumber *thursday;
@property (nonatomic, retain) NSNumber *friday;
@property (nonatomic, retain) NSNumber *saturday;
@property (nonatomic, retain) NSNumber *sunday;
@property (nonatomic, retain) MetaList* list;
@property (nonatomic, retain) NSNumber *period;

@end
