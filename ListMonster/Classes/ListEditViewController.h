//
//  ListEditViewController.h
//  ListMonster
//
//  Created by Norm Barnard on 1/16/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class MetaList;

@protocol ListEditProtocol

- (void)didFinishEditingList:(MetaList *)aList;

@end



@interface ListEditViewController : UIViewController {

    IBOutlet UITextField *nameField;
    IBOutlet UISegmentedControl *colorSelector;
    IBOutlet UIButton *addCategoryButton;
    IBOutlet UIPickerView *categoryPicker;
    IBOutlet UILabel *colorLabel;
    IBOutlet UILabel *categoryLabel;
    IBOutlet UINavigationBar *navigationBar;
    MetaList *theList;
    id<ListEditProtocol> delegate;

}

@property(nonatomic,retain) UITextField *nameField;
@property(nonatomic,retain) UISegmentedControl *colorSelector;
@property(nonatomic,retain) UIButton *addCategoryButton;
@property(nonatomic,retain) UIPickerView *categoryPicker;
@property(nonatomic,retain) UILabel *colorLabel;
@property(nonatomic,retain) UILabel *categoryLabel;
@property(nonatomic,retain) MetaList *theList;
@property(nonatomic,retain) UINavigationBar *navigationBar;
@property(nonatomic,assign) id<ListEditProtocol> delegate;

- (IBAction)addCategoryButtonPressed:(id)sender;
- (IBAction)colorSelectorSegmentPressed:(id)sender;

- (id)initWithList:(MetaList *)aList;

@end
