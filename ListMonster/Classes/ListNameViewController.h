//
//  TextEntryViewController.h
//  ListMonster
//
//  Created by Norm Barnard on 1/22/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class MetaList;

@interface ListNameViewController : UIViewController {

    IBOutlet UITextField *textField;
    MetaList *theList;
}

@property(nonatomic,retain) UITextField *textField;
@property(nonatomic,retain) MetaList *theList;

-(id)initWithList:(MetaList *)aList;

@end
