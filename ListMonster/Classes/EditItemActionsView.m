//
//  EditItemActionsView.m
//  ListMonster
//
//  Created by Norm Barnard on 12/5/12.
//
//

#import "EditItemActionsView.h"
#import "MetaListItem.h"
#import "ThemeManager.h"

@interface EditItemActionsView()

@property (nonatomic, strong) MetaListItem *item;
@property (nonatomic, weak) IBOutlet UIButton *btnMarkComplete;
@property (nonatomic, weak) IBOutlet UIButton *btnDelete;

@end


@implementation EditItemActionsView

- (id)initWithItem:(MetaListItem *)item frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    _item = item;
    if (!self) return nil;
    [self setBackgroundColor:[UIColor clearColor]];
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"EditItemActionsView" owner:self options:nil];
    [self addSubview:nib[0]];
    
    UIImage *deleteBg = [[UIImage imageNamed:@"redButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(5.0f, 12.0f, 20.0f, 12.0f)];
    [[self btnDelete] setBackgroundImage:deleteBg forState:UIControlStateNormal];
    [[self btnDelete] setTitle:NSLocalizedString(@"Delete", nil) forState:UIControlStateNormal];
    
    UIImage *markBg = [[UIImage imageNamed:@"blueButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(5.0f, 12.0f, 20.0f, 12.0f)];
    [[self btnMarkComplete] setBackgroundImage:markBg forState:UIControlStateNormal];
    NSString *title = ([_item isComplete]) ? NSLocalizedString(@"Mark As Not Done", nil) : NSLocalizedString(@"Mark As Done", nil);
    [[self btnMarkComplete] setTitle:title forState:UIControlStateNormal];
    
    return self;
}

- (IBAction)btnMarkCompleteTapped:(UIButton *)sender
{
    NSString *title = ([_item isComplete]) ? NSLocalizedString(@"Mark As Done", nil) : NSLocalizedString(@"Mark As Not Done", nil);
    [[self btnMarkComplete] setTitle:title forState:UIControlStateNormal];    
    [[self delegate] markCompleteRequestedFromEditItemActionsView:self];
}

- (IBAction)btnDeleteTapped:(UIButton *)sender
{
    [[self delegate] deleteRequestedFromEditItemActionsView:self];
}

@end
