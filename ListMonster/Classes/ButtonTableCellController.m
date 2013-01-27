//
//  ButtonTableCellController.m
//  ListMonster
//
//  Created by Norm Barnard on 1/26/13.
//
//

#import "ButtonTableCellController.h"

@interface ButtonTableCellController()

@property (nonatomic, strong) UIButton *btnDelete;

@end


@implementation ButtonTableCellController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"--buttonCell--";
    UITableViewCell *cell = [[self tableView] dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell setBackgroundView:nil];
        CGRect btnFrame = CGRectMake(0.0f, 4.0f, 300.0f, 38.0f);
        _btnDelete = [[UIButton alloc] initWithFrame:btnFrame];
        UIImage *deleteBg = [[UIImage imageNamed:@"redButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(5.0f, 12.0f, 20.0f, 12.0f)];
        [[self btnDelete] setBackgroundImage:deleteBg forState:UIControlStateNormal];
        [[self btnDelete] setTitle:NSLocalizedString(@"Delete", nil) forState:UIControlStateNormal];
        [[self btnDelete] addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [[cell contentView] addSubview:[self btnDelete]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView rowHeight];
}


- (IBAction)buttonTapped:(id)sender
{
    UITableViewCell *cell = (UITableViewCell *)[sender superview];
    NSIndexPath *indexPath = [[self tableView] indexPathForCell:cell];
    [[self delegate] buttonCellController:self buttonTappedForRowAtIndexPath:indexPath];
}


@end
