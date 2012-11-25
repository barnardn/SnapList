//
//  EditTextViewController.h
//  ListMonster
//
//  Created by Norm Barnard on 2/19/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditItemViewProtocol.h"
@class MetaListItem;

@interface EditTextViewController : UIViewController <EditItemViewProtocol> {

    UITextView *textView;
    NSString *__weak viewTitle;
    NSString *backgroundImageFilename;
    MetaListItem *item;
}

@property(nonatomic,strong) IBOutlet UITextView *textView;
@property(nonatomic,weak) NSString *viewTitle;
@property(nonatomic,strong) MetaListItem *item;
@property (nonatomic, weak) id<EditItemViewDelegate> delegate;

- (id)initWithTitle:(NSString *)aTitle listItem:(MetaListItem *)anItem;

@end
