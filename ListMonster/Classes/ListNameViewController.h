//
//  TextEntryViewController.h
//  ListMonster
//
//  Created by Norm Barnard on 1/22/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class MetaList;

@interface ListNameViewController : UIViewController <UITextFieldDelegate> {

    UITextField *textField;
    UIImageView *backgroundImageView;
    MetaList *theList;
}

@property(nonatomic,strong) IBOutlet UITextField *textField;
@property(nonatomic,strong) MetaList *theList;

-(id)initWithList:(MetaList *)aList;

@end
