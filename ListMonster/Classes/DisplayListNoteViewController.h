//
//  DisplayListNoteViewController.h
//  ListMonster
//
//  Created by Norm Barnard on 8/14/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#define FONT_SIZE 14.0f
#define NOTECELL_CONTENT_WIDTH 275.0f
#define NOTECELL_CONTENT_MARGIN 10.0f

@class MetaList;

@interface DisplayListNoteViewController : UITableViewController

@property(nonatomic, strong) MetaList *list;
@property(nonatomic,strong) NSString *backgroundImageFilename;

- (id)initWithList:(MetaList *)aList;
- (IBAction)dismissButtonPressed:(id)sender;

@end
  
