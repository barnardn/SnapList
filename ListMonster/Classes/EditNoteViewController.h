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

    UIImageView *backgroundImageView;
    UITextView *noteTextView;
    MetaList *theList;
}

@property(nonatomic,retain) IBOutlet UIImageView *backgroundImageView;
@property(nonatomic,retain) IBOutlet UITextView *noteTextView;
@property(nonatomic,retain) MetaList *theList;

- (id)initWithList:(MetaList *)list;

@end
