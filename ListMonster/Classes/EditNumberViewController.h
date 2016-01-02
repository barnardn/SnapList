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

@interface EditNumberViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate,
                                                        EditItemViewProtocol> 

@property(nonatomic,strong) IBOutlet UITextField *numericTextField;
@property(nonatomic,strong) MetaListItem *item;
@property(nonatomic,strong) NSString *viewTitle;

@property (nonatomic, weak) id<EditItemViewDelegate> delegate;

- (id)initWithTitle:(NSString *)aTitle listItem:(MetaListItem *)anItem;

@end
