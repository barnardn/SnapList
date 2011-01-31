//
//  SettingsViewController.h
//  ListMonster
//
//  Created by Norm Barnard on 1/30/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingsViewController : UITableViewController {
    
    NSDictionary *settingsMap;
    NSArray *settingsKeys;
}

@property(nonatomic,retain) NSDictionary *settingsMap;
@property(nonatomic,retain) NSArray *settingsKeys;

@end
