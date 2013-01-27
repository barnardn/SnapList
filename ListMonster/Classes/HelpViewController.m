//
//  HelpViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 1/27/13.
//
//

#import "HelpViewController.h"

@interface HelpViewController ()

@property (nonatomic, weak) IBOutlet UIButton *btnDismiss;

@end

@implementation HelpViewController

- (id)init
{
    self = [super init];
    if (!self) return nil;
    return self;
}

- (NSString *)nibName
{
    return @"HelpView";
}


- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIModalTransitionStyle)modalTransitionStyle
{
    return UIModalTransitionStyleFlipHorizontal;
}

#pragma mark - actions

- (IBAction)btnDismissTapped:(UIButton *)sender
{
    [[self delegate] dismissHelpView];
}

@end
