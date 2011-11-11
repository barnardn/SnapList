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

#define emvMEASURE_COMPONENT_INDEX  0
#define emvUNIT_COMPONENT_INDEX     1

@interface EditMeasureViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, EditItemViewProtocol>
{
    NSString *selectedMeasureKey;
    NSInteger defaultUnitSelection;
}


@property (retain, nonatomic) IBOutlet UISegmentedControl *unitSelector;
@property (retain, nonatomic) IBOutlet UIPickerView *measurePicker;

@property (retain, nonatomic) NSMutableDictionary *currentMeasures;
@property (retain, nonatomic) Measure *selectedMeasure;
@property (retain, nonatomic) MetaListItem *item;
@property (retain, nonatomic) NSString *viewTitle;
@property (assign) NSInteger defaultUnitSelection;

- (IBAction)UnitSelectorTapped:(id)sender;


@end
