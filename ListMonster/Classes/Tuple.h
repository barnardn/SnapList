//
//  Tuple.h
//  
//
//  Created by Norm Barnard on 7/9/10.
//  Copyright 2010 clamdango.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Tuple : NSObject {
    id first;
    id second;
}

@property (nonatomic,copy) id first;
@property (nonatomic,copy) id second;

- (id)init;
- (id)initWithFirst:(id)f second:(id)s;

+ (id)tupleWithFirst:(id)f second:(id)s;
@end
