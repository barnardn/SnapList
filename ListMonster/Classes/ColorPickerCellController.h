//
//  ColorPickerCellController.h
//  ListMonster
//
//  Created by Norm Barnard on 12/23/12.
//
//

#import <Foundation/Foundation.h>
#import "BaseTableCellController.h"

@class MetaList;

@interface ColorPickerCellController : BaseTableCellController

@property (nonatomic, strong) MetaList *list;

@end
