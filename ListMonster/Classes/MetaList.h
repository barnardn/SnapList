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
@class Category;

@interface MetaList : NSManagedObject {

}

@property (nonatomic, retain) NSDate *dateCreated;
@property (nonatomic, retain) NSString *listID;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSSet *items;
@property (nonatomic, retain) Category *category;
@property (nonatomic, retain) NSNumber *colorCode;

@end
