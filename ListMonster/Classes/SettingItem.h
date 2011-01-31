//
//  SettingItem.h
//  ListMonster
//
//  Created by Norm Barnard on 1/30/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import <Foundation/Foundation.h>




@interface SettingItem : NSObject {

    NSString *itemTitle;
    NSString *detailTitle;
    Class viewControllerClass;
    NSDictionary *viewControllerInfo;
}

@property(nonatomic,copy) NSString *itemTitle;
@property(nonatomic,copy) NSString *detailTitle;
@property(nonatomic,retain) Class viewControllerClass;
@property(nonatomic,retain) NSDictionary *viewControllerInfo;

- (id)initWithItemTitle:(NSString *)title viewControllerClass:(Class)controllerClass;

@end
