//
//  SelectColorView.m
//  ListMonster
//
//  Created by Norm Barnard on 12/23/12.
//
//

#import "ColorViewController.h"
#import "GzColors.h"
#import "SelectColorView.h"
#import "WEPopoverController.h"

@interface SelectColorView() <WEPopoverControllerDelegate, UIPopoverControllerDelegate, ColorViewControllerDelegate>

@property (nonatomic, strong) WEPopoverController *popoverController;

@end

@implementation SelectColorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SelectColorView" owner:self options:nil];
    UIView *v = (UIView *)[nib objectAtIndex:0];
    [self addSubview:v];    
    return self;
}

- (IBAction)btnColorNameTapped:(UIButton *)sender
{
    if (![self popoverController]) {
		
		ColorViewController *contentViewController = [[ColorViewController alloc] init];
        contentViewController.delegate = self;
		WEPopoverController *poc = [[WEPopoverController alloc] initWithContentViewController:contentViewController];
		[poc setDelegate:self];
		//self.popoverController.passthroughViews = [NSArray arrayWithObject:self.navigationController.navigationBar];
		[poc presentPopoverFromRect:[sender frame]
                             inView:self
           permittedArrowDirections:(UIPopoverArrowDirectionUp|UIPopoverArrowDirectionDown)
                           animated:YES];
        [self setPopoverController:poc];
        
	} else {
        [[self popoverController] dismissPopoverAnimated:YES];
        [self setPopoverController:nil];
	}
}

#pragma mark - color popover delegate methods

-(void) colorPopoverControllerDidSelectColor:(NSString *)hexColor
{
    UIColor *color = [GzColors colorFromHex:hexColor];
    [[self delegate] selectColorView:self didSelectColor:hexColor];
    [[self btnColorName] setBackgroundColor:color];
    
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [self setPopoverController:nil];
}

- (BOOL)popoverControllerShouldDismissPopover:(WEPopoverController *)popoverController
{
    return YES;
}


@end
