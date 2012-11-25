/*
 *  EditItemViewProtocol.h
 *  ListMonster
 *
 *  Created by Norm Barnard on 4/29/11.
 *  Copyright 2011 clamdango.com. All rights reserved.
 *
 */
@class MetaListItem;


@protocol EditItemViewDelegate

@required

- (void)editItemViewController:(UIViewController *)editViewController didChangeValue:(id)updatedValue forItem:(MetaListItem *)item;

@end


@protocol EditItemViewProtocol

@required

@property (nonatomic, weak) id<EditItemViewDelegate> delegate;

-(id)initWithTitle:(NSString *)title listItem:(MetaListItem *)anItem;


@end



