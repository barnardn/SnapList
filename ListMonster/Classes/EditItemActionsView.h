//
//  EditItemActionsView.h
//  ListMonster
//
//  Created by Norm Barnard on 12/5/12.
//
//

#import <UIKit/UIKit.h>

@class MetaListItem;

@protocol EditItemActionsViewDelegate;

@interface EditItemActionsView : UIView

@property (nonatomic, weak) id<EditItemActionsViewDelegate> delegate;

- (id)initWithItem:(MetaListItem *)item frame:(CGRect)frame;

@end

@protocol EditItemActionsViewDelegate <NSObject>

- (void)deleteRequestedFromEditItemActionsView:(EditItemActionsView *)view;
- (void)markCompleteRequestedFromEditItemActionsView:(EditItemActionsView *)view;

@end
