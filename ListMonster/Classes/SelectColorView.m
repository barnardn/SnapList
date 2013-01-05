//
//  SelectColorView.m
//  ListMonster
//
//  Created by Norm Barnard on 12/23/12.
//
//

#import "ColorViewController.h"
#import "GzColors+HexToName.h"
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
    [self setBackgroundColor:[UIColor clearColor]];
    [[self btnColorName] setTitle:NSLocalizedString(@"Select",nil) forState:UIControlStateNormal];
    [[self btnColorName] setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [[[self btnColorName] layer] setBorderColor:[UIColor blackColor].CGColor];
    [[[self btnColorName] layer] setBorderWidth:1.0f];
    [[[self btnColorName] layer] setCornerRadius:4.0f];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = [[self btnColorName] bounds];
    gradient.colors = [NSArray arrayWithObjects:(id)[ [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.25] CGColor], (id)[[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0]  CGColor], nil];
    [[[self btnColorName] layer] insertSublayer:gradient atIndex:0];
    
    return self;
}

- (IBAction)btnColorNameTapped:(UIButton *)sender
{
    if (![self popoverController]) {
		
		ColorViewController *contentViewController = [[ColorViewController alloc] init];
        contentViewController.delegate = self;
		WEPopoverController *poc = [[WEPopoverController alloc] initWithContentViewController:contentViewController];
		[poc setDelegate:self];
		[poc presentPopoverFromRect:[sender frame]
                             inView:self
           permittedArrowDirections:(UIPopoverArrowDirectionUp|UIPopoverArrowDirectionDown)
                           animated:YES];
        [self setPopoverController:poc];
        [[poc view] setClipsToBounds:YES];
        
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
    NSString *colorName = [GzColors colorNameFromHexString:hexColor];
    [[self lblColorName] setText:colorName];
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
