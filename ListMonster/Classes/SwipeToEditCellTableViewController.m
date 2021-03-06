//
//  SwipeToEditCellTableViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 11/18/12.
//
//

#import "CDOGeometry.h"
#import "SwipeToEditCellTableViewController.h"
#import "ThemeManager.h"

#define TAG_COMPLETEVIEW            9002
#define TAG_COMPLETELABEL           9003

@interface SwipeToEditCellTableViewController ()

@property (nonatomic, strong) UISwipeGestureRecognizer *leftSwipe;
@property (nonatomic, strong) UISwipeGestureRecognizer *rightSwipe;
@property (nonatomic,strong) UITableViewCell *cellForDeletionCancel;
@property (nonatomic,strong) NSArray *deleteCancelRegions;

@property (nonatomic, strong) UITapGestureRecognizer *confirmDeleteGesture;

@end

@implementation SwipeToEditCellTableViewController

- (id)init
{
    self = [super init];
    if (!self) return nil;
    
    _leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipeHandler:)];
    [_leftSwipe setDirection:UISwipeGestureRecognizerDirectionLeft];
    
    _rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipeHandler:)];
    [_rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self tableView] addGestureRecognizer:[self leftSwipe]];
    [[self tableView] addGestureRecognizer:[self rightSwipe]];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


- (void)removeSwipeActionIndicatorViewsFromCell:(UITableViewCell *)cell
{
    [[cell viewWithTag:TAG_COMPLETELABEL] removeFromSuperview];
    [[cell viewWithTag:TAG_COMPLETEVIEW] removeFromSuperview];
}


- (void)rightSwipeHandler:(UISwipeGestureRecognizer *)swipe
{
    if ([self shouldIgnoreGestureRecognizerForDirection:SwipeGestureRecognizerDirectionRight]) return;
    
    if ([self cellForDeletionCancel]) {
        [self cancelItemDelete];
        return;
    }
    NSIndexPath *indexPath = [[self tableView] indexPathForRowAtPoint:[swipe locationInView:[self tableView]]];
    UITableViewCell *swipedCell = [[self tableView] cellForRowAtIndexPath:indexPath];
    [swipedCell setAccessoryType:UITableViewCellAccessoryNone];
    CGAffineTransform xlation = CGAffineTransformMakeTranslation(320.0f, 0.0f);
    UIImage *imgBackground = [[UIImage imageNamed:@"bg-complete"] resizableImageWithCapInsets:UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f)];
    CGRect cellFrame = CDO_CGRectByReplacingOrigin([swipedCell frame], CGPointMake(-320.0f, 0.0f));
    UIImageView *ivBg = [[UIImageView alloc] initWithFrame:cellFrame];
    [ivBg setImage:imgBackground];
    [ivBg setTag:TAG_COMPLETEVIEW];
    [swipedCell addSubview:ivBg];
    
    __weak SwipeToEditCellTableViewController *weakSelf = self;
    [UIView animateWithDuration:0.25f animations:^{
        [[swipedCell textLabel] setTransform:xlation];
        [[swipedCell detailTextLabel] setTransform:xlation];
        [ivBg setTransform:xlation];
    } completion:^(BOOL finished) {
        CGPoint center = CDO_CGPointIntegral([[swipedCell contentView] center]);
        NSString *actionTitle = [weakSelf rightSwipeActionTitleForItemItemAtIndexPath:indexPath];
        [weakSelf rightSwipeUpdateAtIndexPath:indexPath];
        [swipedCell addSubview:[weakSelf swipeActionLabelWithText:actionTitle centeredAt:center]];
        [[swipedCell textLabel] setTransform:CGAffineTransformIdentity];
        [[swipedCell detailTextLabel] setTransform:CGAffineTransformIdentity];
        if ([weakSelf rightSwipeShouldDeleteRowAtIndexPath:indexPath]) {
            [weakSelf rightSwipeRemoveItemAtIndexPath:indexPath];
            NSInteger nSections = [[weakSelf tableView] numberOfSections];
            NSInteger nItemsForSection = [[weakSelf tableView] numberOfRowsInSection:[indexPath section]];
            if ((nItemsForSection == 1) && (nSections > 1))
                [[weakSelf tableView] deleteSections:[NSIndexSet indexSetWithIndex:[indexPath section]] withRowAnimation:UITableViewRowAnimationAutomatic];
            else
                [[weakSelf tableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        } else {
            [[weakSelf tableView] reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }];
}

- (UILabel *)swipeActionLabelWithText:(NSString *)text centeredAt:(CGPoint)center
{
    UILabel *lblComplete = [[UILabel alloc] init];
    [lblComplete setTag:TAG_COMPLETELABEL];
    [lblComplete setFont:[ThemeManager fontForListName]];
    [lblComplete setTextColor:[UIColor whiteColor]];
    [lblComplete setText:text];
    [lblComplete sizeToFit];
    [lblComplete setBackgroundColor:[UIColor clearColor]];
    [lblComplete setCenter:center];
    return lblComplete;
}


- (void)leftSwipeHandler:(UISwipeGestureRecognizer *)swipe
{
    DLog(@"left swipe");
    if ([self shouldIgnoreGestureRecognizerForDirection:SwipeGestureRecognizerDirectionLeft]) return;
    
    NSIndexPath *indexPath = [[self tableView] indexPathForRowAtPoint:[swipe locationInView:[self tableView]]];
    UITableViewCell *swipedCell = [[self tableView] cellForRowAtIndexPath:indexPath];
    [swipedCell setAccessoryType:UITableViewCellAccessoryNone];
    CGAffineTransform xlation = CGAffineTransformMakeTranslation(-320.0f, 0.0f);
    CGRect cellFrame = [swipedCell frame];
    
    CGRect imgFrame = CGRectMake(320.0f, 0.0f, 320.0f, cellFrame.size.height);
    UIImageView *ivBg = [[UIImageView alloc] initWithFrame:imgFrame];
    UIImage *imgBackground = [[UIImage imageNamed:@"bg-deletion"] resizableImageWithCapInsets:UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f)];
    [ivBg setImage:imgBackground];
    [ivBg setTag:TAG_COMPLETEVIEW];
    [swipedCell addSubview:ivBg];
    
    __weak SwipeToEditCellTableViewController *weakSelf = self;
    [UIView animateWithDuration:0.25f animations:^{
        [[swipedCell textLabel] setTransform:xlation];
        [[swipedCell detailTextLabel] setTransform:xlation];
        [ivBg setTransform:xlation];
    } completion:^(BOOL finished) {
        CGPoint center = CDO_CGPointIntegral([[swipedCell contentView] center]);
        [swipedCell addSubview:[weakSelf swipeActionLabelWithText:@"Delete" centeredAt:center]];

        CGRect converted = [[weakSelf view] convertRect:[swipedCell frame] fromView:[weakSelf tableView]];
        UIButton *top = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, CGRectGetMinY(converted))];
        [top setBackgroundColor:[UIColor clearColor]];

        CGRect bottomFrame = CGRectMake(0.0f, CGRectGetMaxY(converted), 320.0f, CGRectGetHeight([[weakSelf view] bounds]) - CGRectGetMaxY(converted));
        UIButton *btm = [[UIButton alloc] initWithFrame:bottomFrame];
        [btm setBackgroundColor:[UIColor clearColor]];
        [top addTarget:weakSelf action:@selector(deleteCancelRegionTapped:) forControlEvents:UIControlEventTouchUpInside];
        [btm addTarget:weakSelf action:@selector(deleteCancelRegionTapped:) forControlEvents:UIControlEventTouchUpInside];
        [[weakSelf view] addSubview:top];
        [[weakSelf view] addSubview:btm];
        [weakSelf setDeleteCancelRegions:@[top, btm]];
        [weakSelf setCellForDeletionCancel:swipedCell];
        [[swipedCell textLabel] setTransform:CGAffineTransformIdentity];
        [[swipedCell detailTextLabel] setTransform:CGAffineTransformIdentity];
        
    }];
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deletionConfirmed:)];
    [[self tableView] addGestureRecognizer:tgr];
    [self setConfirmDeleteGesture:tgr];
}


#pragma mark - cell/item deletion handlers

- (void)deletionConfirmed:(UITapGestureRecognizer *)tap
{
    NSIndexPath *indexPath = [[self tableView] indexPathForRowAtPoint:[tap locationInView:[self tableView]]];
    [[self tableView] removeGestureRecognizer:tap];
    [[self deleteCancelRegions] enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL *stop) {
        [btn removeFromSuperview];
    }];
    [self setDeleteCancelRegions:nil];
    [self setCellForDeletionCancel:nil];
    [[self tableView] removeGestureRecognizer:[self confirmDeleteGesture]];

    [[self tableView] beginUpdates];
    [self leftSwipeDeleteItemAtIndexPath:indexPath];
    
    NSInteger nSections = [[self tableView] numberOfSections];
    NSInteger nItemsForSection = [[self tableView] numberOfRowsInSection:[indexPath section]];
    if ((nItemsForSection == 1) && (nSections >= 1))
        [[self tableView] deleteSections:[NSIndexSet indexSetWithIndex:[indexPath section]] withRowAnimation:UITableViewRowAnimationAutomatic];
    else
        [[self tableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [[self tableView] endUpdates];
        
}

- (void)deleteCancelRegionTapped:(UIButton *)region
{
    [self cancelItemDelete];
}

- (void)cancelItemDelete
{
    UILabel *lbl = (UILabel *)[[self cellForDeletionCancel] viewWithTag:TAG_COMPLETELABEL];
    UIImageView *iv = (UIImageView *)[[self cellForDeletionCancel] viewWithTag:TAG_COMPLETEVIEW];
    [[self deleteCancelRegions] enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL *stop) {
        [btn removeFromSuperview];
    }];
    [self setDeleteCancelRegions:nil];
    [[self tableView] removeGestureRecognizer:[self confirmDeleteGesture]];
    [UIView animateWithDuration:0.25f animations:^{
        [lbl setAlpha:0.0f];
        [iv setAlpha:0.0f];
        [[self cellForDeletionCancel] setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    } completion:^(BOOL finished) {
        [lbl removeFromSuperview];
        [iv removeFromSuperview];
        [self setCellForDeletionCancel:nil];
    }];
}

#pragma mark - subclass accessor abstract methods

- (BOOL)shouldIgnoreGestureRecognizerForDirection:(SwipeGestureRecognizerDirection)swipeDirection
{
    return NO;
}


- (void)rightSwipeUpdateAtIndexPath:(NSIndexPath *)indexPath
{
    [NSException raise:NSInternalInconsistencyException format:@"You must implement %@ in a subclass", NSStringFromSelector(_cmd)];
}

- (NSString *)rightSwipeActionTitleForItemItemAtIndexPath:(NSIndexPath *)indexPath
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must implement %@ in a subclass",
                                           NSStringFromSelector(_cmd)] userInfo:nil];
}

- (BOOL)rightSwipeShouldDeleteRowAtIndexPath:(NSIndexPath *)indexPath
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must implement %@ in a subclass",
                                           NSStringFromSelector(_cmd)] userInfo:nil];

}

- (void)rightSwipeRemoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    [NSException raise:NSInternalInconsistencyException format:@"You must implement %@ in a subclass", NSStringFromSelector(_cmd)];    
}

- (void)leftSwipeDeleteItemAtIndexPath:(NSIndexPath *)indexPath
{
    [NSException raise:NSInternalInconsistencyException format:@"You must implement %@ in a subclass", NSStringFromSelector(_cmd)];    
}


@end
