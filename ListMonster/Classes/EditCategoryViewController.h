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
@class Category;
@class MetaList;

@interface EditCategoryViewController : UIViewController <UITextFieldDelegate> {

    UIImageView *backgroundImageView;
    UITextField *categoryNameField; 
    Category *category;
    MetaList *theList;
    UINavigationBar *navBar;        // for use when presented modally
    id<EditCategoryDelegate>delegate;
    
}

@property(nonatomic,retain) IBOutlet UIImageView *backgroundImageView;
@property(nonatomic,retain) IBOutlet UITextField *categoryNameField;
@property(nonatomic,retain) Category *category;
@property(nonatomic,retain) UINavigationBar *navBar;
@property(nonatomic,assign) id<EditCategoryDelegate> delegate;
@property(nonatomic,retain) MetaList *theList;

- (id)initWithList:(MetaList *)aList;

@end


@protocol EditCategoryDelegate

// category nil on cancel
- (void)editCategoryViewController:(EditCategoryViewController *)editCategoryViewController didEditCategory:(Category *)category;

@end