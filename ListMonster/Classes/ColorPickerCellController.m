//
//  ColorPickerCellController.m
//  ListMonster
//
//  Created by Norm Barnard on 12/23/12.
//
//

#import "ColorPickerCellController.h"
#import "GzColors.h"
#import "MetaList.h"
#import "SelectColorView.h"

@interface ColorPickerCellController () <SelectColorDelegate>


@end


@implementation ColorPickerCellController

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView rowHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"--colorCell--";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    
    [cell setSelectionStyle:UITableViewCellEditingStyleNone];
    SelectColorView *scv = [[SelectColorView alloc] initWithFrame:[[cell contentView] bounds]];
    [scv setDelegate:self];
    if (![[self list] tintColor]) {
        [[scv btnColorName] setBackgroundColor:[UIColor lightGrayColor]];
        [[scv lblColorName] setText:NSLocalizedString(@"None", nil)];
    } else {
        UIColor *color = [GzColors colorFromHex:[[self list] tintColor]];
        [[scv btnColorName] setBackgroundColor:color];
        [[scv lblColorName] setText:[[self list] tintColor]];
    }
    [[cell contentView] addSubview:scv];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ;
}

#pragma mark select color view delegate method

- (void)selectColorView:(SelectColorView *)colorView didSelectColor:(NSString *)colorCode;
{
    [[self list] setTintColor:colorCode];
    [[self list] save];
    UIColor *color = [GzColors colorFromHex:colorCode];
    if ([[self delegate] respondsToSelector:@selector(cellController:didSelectItem:)])
        [[self delegate] cellController:self didSelectItem:color];
}

@end
