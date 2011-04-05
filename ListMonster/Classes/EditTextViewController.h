//
//  EditTextViewController.h
//  ListMonster
//
//  Created by Norm Barnard on 2/19/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface EditTextViewController : UIViewController <UITextFieldDelegate> {

    UITextField *textField;
    NSString *returnString;
    NSString *viewTitle;
    NSString *editText;
    UIColor *backgroundColor;
    BOOL numericEntryMode;
}


@property(nonatomic,retain) IBOutlet UITextField *textField;
@property(nonatomic,retain) NSString *returnString;
@property(nonatomic,assign) NSString *viewTitle;
@property(nonatomic,assign) NSString *editText;
@property(nonatomic,assign) BOOL numericEntryMode;
@property(nonatomic,retain) UIColor *backgroundColor;


- (id)initWithViewTitle:(NSString *)aTitle editText:(NSString *)text;


@end
