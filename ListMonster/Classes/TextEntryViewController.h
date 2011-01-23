//
//  TextEntryViewController.h
//  ListMonster
//
//  Created by Norm Barnard on 1/22/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TextEntryViewController : UIViewController {

    IBOutlet UITextField *textField;
    NSString *viewTitle;
    NSString *placeholderText;
    NSString *returnValue;
}

@property(nonatomic,retain) UITextField *textField;
@property(nonatomic,copy) NSString *viewTitle;
@property(nonatomic,copy) NSString *placeholderText;
@property(nonatomic,copy) NSString *returnValue;

-(id)initWithTitle:(NSString *)theTitle placeholder:(NSString *)thePlaceholder;


@end
