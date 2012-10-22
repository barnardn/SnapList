//
//  EditNoteViewController.h
//  ListMonster
//
//  Created by Norm Barnard on 4/8/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MetaList;

@interface EditNoteViewController : UIViewController {

    UITextView *noteTextView;
    MetaList *theList;
}

@property(nonatomic,strong) IBOutlet UITextView *noteTextView;
@property(nonatomic,strong) MetaList *theList;

- (id)initWithList:(MetaList *)list;

@end
