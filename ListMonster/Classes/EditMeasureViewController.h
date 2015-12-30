//
//  EditMeasureViewController.h
//  ListMonster
//
//  Created by Norm Barnard on 10/26/11.
//  Copyright (c) 2011 clamdango.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditItemViewProtocol.h"

@class Measure;
@class MetaListItem;

#define emvENGLISH_UNIT_INDEX       0
#define emvMETRIC_UNIT_INDEX        1
#define emvCUSTOM_UNIT_INDEX        2
#define emvNONE_UNIT_INDEX          3

#define emvMEASURE_COMPONENT_INDEX  0
#define emvUNIT_COMPONENT_INDEX     1

@interface EditMeasureViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, EditItemViewProtocol, UITextFieldDelegate>

@property (strong, nonatomic) NSString *selectedMeasureKey;
@property (weak, nonatomic) IBOutlet UISegmentedControl *unitSelector;
@property (weak, nonatomic) IBOutlet UIPickerView *measurePicker;
@property (weak, nonatomic) IBOutlet UIView *customMeasureView;
@property (weak, nonatomic) IBOutlet UITextField *customMeasure;
@property (weak, nonatomic) IBOutlet UITextField *customMeasureName;
@property (weak, nonatomic) IBOutlet UITextField *customMeasureAbbrev;
@property (weak, nonatomic) IBOutlet UIButton *addCustomMeasure;
@property (weak, nonatomic) IBOutlet UIButton *removeCustomMeasure;

@property (strong, nonatomic) NSMutableDictionary *currentMeasures;
@property (strong, nonatomic) Measure *selectedMeasure;
@property (strong, nonatomic) MetaListItem *item;
@property (strong, nonatomic) NSString *viewTitle;
@property (assign) NSInteger defaultUnitSelection;

@property (nonatomic, weak) id<EditItemViewDelegate> delegate;


- (IBAction)unitSelectorTapped:(id)sender;
- (IBAction)addCustomMeasureTapped:(UIButton *)sender;
- (IBAction)removeCustomMeasureTapped:(UIButton *)sender;

@end
