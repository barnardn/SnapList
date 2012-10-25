//
//  EditCategoryViewController.h
//  ListMonster
//
//  Created by Norm Barnard on 2/27/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@protocol EditCategoryDelegate;
@class ListCategory;
@class MetaList;

@interface EditCategoryViewController : UIViewController <UITextFieldDelegate> {

    UIImageView *backgroundImageView;
    UITextField *categoryNameField; 
    ListCategory *category;
    MetaList *theList;
    UINavigationBar *navBar;        // for use when presented modally
    id<EditCategoryDelegate>__weak delegate;
    
}

@property(nonatomic,strong) IBOutlet UIImageView *backgroundImageView;
@property(nonatomic,strong) IBOutlet UITextField *categoryNameField;
@property(nonatomic,strong) ListCategory *category;
@property(nonatomic,strong) UINavigationBar *navBar;
@property(nonatomic,weak) id<EditCategoryDelegate> delegate;
@property(nonatomic,strong) MetaList *theList;

- (id)initWithList:(MetaList *)aList;

@end


@protocol EditCategoryDelegate

// category nil on cancel
- (void)editCategoryViewController:(EditCategoryViewController *)editCategoryViewController didEditCategory:(ListCategory *)category;

@end