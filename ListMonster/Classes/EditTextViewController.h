//
//  EditTextViewController.h
//  ListMonster
//
//  Created by Norm Barnard on 2/19/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditItemViewProtocol.h"
@class MetaListItem;

@interface EditTextViewController : UIViewController <UITextFieldDelegate, EditItemViewProtocol> {

    UITextField *textField;
    NSString *viewTitle;
    NSString *backgroundImageFilename;
    MetaListItem *item;
}


@property(nonatomic,retain) IBOutlet UITextField *textField;
@property(nonatomic,assign) NSString *viewTitle;
@property(nonatomic,retain) MetaListItem *item;


- (id)initWithTitle:(NSString *)aTitle listItem:(MetaListItem *)anItem;

@end
