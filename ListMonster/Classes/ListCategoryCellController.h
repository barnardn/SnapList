//
//  ListCategoryCellController.h
//  ListMonster
//
//  Created by Norm Barnard on 12/26/12.
//
//

#import "BaseTableCellController.h"

@class ListCategory;

@interface ListCategoryCellController : BaseTableCellController

@property (nonatomic, strong) ListCategory *category;
@property (nonatomic, weak) UINavigationController *navController;


@end
