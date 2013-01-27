//
//  ButtonTableCellController.h
//  ListMonster
//
//  Created by Norm Barnard on 1/26/13.
//
//

#import "BaseTableCellController.h"


@protocol ButtonTableCellControllerDelegate;

@interface ButtonTableCellController : BaseTableCellController

@property (nonatomic, weak) id<TableCellControllerDelegate, ButtonTableCellControllerDelegate> delegate;

@end

@protocol ButtonTableCellControllerDelegate <NSObject>

- (void)buttonCellController:(ButtonTableCellController *)cellController buttonTappedForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
