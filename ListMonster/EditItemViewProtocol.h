/*
 *  EditItemViewProtocol.h
 *  ListMonster
 *
 *  Created by Norm Barnard on 4/29/11.
 *  Copyright 2011 clamdango.com. All rights reserved.
 *
 */
@class MetaListItem;

@protocol EditItemViewProtocol

@required
-(id)initWithTitle:(NSString *)title listItem:(MetaListItem *)anItem;
@property(nonatomic,retain) NSString *backgroundImageFilename;

@end

