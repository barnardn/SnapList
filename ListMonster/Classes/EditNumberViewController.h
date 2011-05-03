//
//  EditNumberViewController.h
//  ListMonster
//
//  Created by Norm Barnard on 4/29/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditItemViewProtocol.h"

@class MetaListItem;

@interface EditNumberViewController : UIViewController <UITextFieldDelegate,
                                                        EditItemViewProtocol> {

    UITextField *numericTextField;
    MetaListItem *item;
    NSString *viewTitle;
    NSString *backgroundImageFilename;
}

@property(nonatomic,retain) IBOutlet UITextField *numericTextField;
@property(nonatomic,retain) MetaListItem *item;
@property(nonatomic,retain) NSString *viewTitle;

- (id)initWithTitle:(NSString *)aTitle listItem:(MetaListItem *)anItem;

@end
