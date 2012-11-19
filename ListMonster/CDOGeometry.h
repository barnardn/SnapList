//
//  CDOGeometry.h
//  ListMonster
//
//  Created by Norm Barnard on 11/16/12.
//
//

#import <Foundation/Foundation.h>

#define CDO_GEOMETRY_NO_SIZE      -1.0f


/*
 * returns the smallest point that results form converting the coordinates to integers
 */
CGPoint CDO_CGPointIntegral(CGPoint floatPoint);

/*
 * returns a cgrect with the same size and as the passed in rect but with
 * a new origin at point "origin"
 */
CGRect CDO_CGRectByReplacingOrigin(CGRect rect, CGPoint origin);

/* 
 * returns a new rect with the same center as outer rect with dimensions
 * widht and height.  if either widge or height are larger than the containing
 * rect, a zero rect is returned.
 */
CGRect CDO_CGRectCenteredInRect(CGRect outerRect, CGFloat width, CGFloat height);

/*
 * functions to return an objects width or height. 
 */
CGFloat CDO_CGSizeGetWidth(id obj);
CGFloat CDO_CGSizeGetHeight(id obj);

