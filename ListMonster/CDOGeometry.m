//
//  CDOGeometry.m
//  ListMonster
//
//  Created by Norm Barnard on 11/16/12.
//
//

#import "CDOGeometry.h"

CGPoint CDO_CGPointIntegral(CGPoint floatPoint)
{
    return CGPointMake(floorf(floatPoint.x), floorf(floatPoint.y));
}


CGRect CDO_CGRectByReplacingOrigin(CGRect rect, CGPoint origin)
{
    CGRect xrect = CGRectMake(origin.x, origin.y, rect.size.width, rect.size.height);
    return xrect;
}

CGRect CDO_CGRectCenteredInRect(CGRect outerRect, CGFloat width, CGFloat height)
{
    if (width > outerRect.size.width || height > outerRect.size.height) return CGRectZero;
    CGFloat dx = (outerRect.size.width - width) / 2.0f;
    CGFloat dy = (outerRect.size.height - height) / 2.0f;
    return CGRectInset(outerRect, dx, dy);
}