//
//  EditItemActionsView.h
//  ListMonster
//
//  Created by Norm Barnard on 12/5/12.
//
//

#import <UIKit/UIKit.h>

enum {
    EditItemActionsAll     = 0,
    EditItemActionsDelete  = 1 << 0,
    EditItemActionsMark    = 1 << 1
};
typedef NSUInteger EditItemActionOptions;


@class MetaListItem;

@protocol EditItemActionsViewDelegate;

@interface EditItemActionsView : UIView

@property (nonatomic, weak) id<EditItemActionsViewDelegate> delegate;

- (id)initWithItem:(MetaListItem *)item frame:(CGRect)frame activeButtons:(EditItemActionOptions)options;
- (id)initWithItem:(MetaListItem *)item frame:(CGRect)frame;

@end

@protocol EditItemActionsViewDelegate <NSObject>

- (void)deleteRequestedFromEditItemActionsView:(EditItemActionsView *)view;
- (void)markCompleteRequestedFromEditItemActionsView:(EditItemActionsView *)view;

@end
