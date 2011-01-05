//
//  List.h
//  ListMonster
//
//  Created by Norm Barnard on 12/27/10.
//  Copyright 2010 clamdango.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MetaListItem;
@class Schedule;

@interface MetaList : NSManagedObject {

}

@property (nonatomic, retain) NSDate *dateCreated;
@property (nonatomic, retain) NSString *listID;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSSet *items;
@property (nonatomic, retain) Schedule *schedule;
@property (nonatomic, retain) NSString *category;

@end
