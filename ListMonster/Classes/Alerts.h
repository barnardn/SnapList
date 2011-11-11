//
//  Alerts.h
//  DsqObsvervation
//
//  Created by Norm Barnard on 8/24/10.
//  Copyright 2010 National Heritage Academies. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kTEXTVIEW_TAG 99

@interface ErrorAlert : NSObject 

+ (void)showWithTitle:(NSString *)title andMessage:(NSString *)message;

@end

@interface ConfirmationAlert : NSObject

+ (BOOL)showMessage:(NSString *)message withTitle:(NSString *)title;

@end

@interface ViewDetailsAlert : NSObject

+ (BOOL)showWithTitle:(NSString *)title message:(NSString *)message;

@end

@interface LoadingAlert : NSObject <UIAlertViewDelegate>

+ (UIAlertView *)showWithMessage:(NSString *)message;

@end

@interface NumberRequestor : NSObject

+ (NSNumber *)requestNumberWith:(NSString *)question prompt:(NSString *)prompt;

@end

@interface InputRequestor : NSObject

+ (NSString *)requestInputWith:(NSString *)question 
                   placeHolder:(NSString *)placeHolder
                  keyboardType:(UIKeyboardType)kbType;

@end