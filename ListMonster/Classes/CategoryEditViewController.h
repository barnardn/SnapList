//
//  TextEntryViewController.h
//  ListMonster
//
//  Created by Norm Barnard on 2/5/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class Category;

@interface CategoryEditViewController : UIViewController {
    
    UITextField *textField;
    Category *categoryToEdit;
}

@property(nonatomic,retain) Category *categoryToEdit;
@property(nonatomic,retain) IBOutlet UITextField *textField;

- (id)initWithCategory:(Category *)theCategory;
- (void)donePressed:(id)sender;

@end
