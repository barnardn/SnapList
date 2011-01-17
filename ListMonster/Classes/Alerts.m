//
//  Alerts.m
//  DsqObsvervation
//
//  Created by Norm Barnard on 8/24/10.
//  Copyright 2010 National Heritage Academies. All rights reserved.
//

#import "Alerts.h"
#import "UiHelper.h"
#import "RegexKitLite.h"

#pragma mark -
#pragma mark Modal Alert Delegate 

@interface ModalAlertDelegate: NSObject <UIAlertViewDelegate, UITextFieldDelegate>
{
    CFRunLoopRef currentLoop;
    NSInteger btnIndex;
    NSString *userText;
    UIAlertView *requestorView;
}

@property(readonly) NSInteger btnIndex;
@property(retain) NSString *userText;
@property(nonatomic,assign) UIAlertView *requestorView;

@end

@implementation ModalAlertDelegate

@synthesize btnIndex, userText, requestorView;

- (id)initWithRunloop:(CFRunLoopRef)runLoop {
    if (!(self = [super init])) {
        return nil;
    }
    requestorView = nil;
    currentLoop = runLoop;
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardWillHide:) 
                                                 name:UIKeyboardWillHideNotification 
                                               object:nil];
    
    return self;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    btnIndex = buttonIndex;
/*    UITextField *tf = (UITextField *)[alertView viewWithTag:kTEXTVIEW_TAG];
    if (tf)
        [self setUserText:[tf text]]; */
    id tf = [alertView viewWithTag:kTEXTVIEW_TAG];
    if ([tf respondsToSelector:@selector(text)]) {
        [self setUserText:[tf performSelector:@selector(text)]];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    CFRunLoopStop(currentLoop);
    
}

- (void)moveAlert:(UIAlertView *)alertView {
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (orientation == UIDeviceOrientationPortrait ||
        orientation == UIDeviceOrientationPortraitUpsideDown) {
        
        [[alertView viewWithTag:kTEXTVIEW_TAG] becomeFirstResponder];
        return;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.25f];
    
    CGPoint alertCenter;
    alertCenter = CGPointMake(alertView.center.x, 260.0f);
    [alertView setCenter:alertCenter];
    [UIView commitAnimations];
    
    [[alertView viewWithTag:kTEXTVIEW_TAG] becomeFirstResponder];
    
}

- (void)keyboardWillHide:(NSNotification *)notification {
    if ([self requestorView]) {
        [[self requestorView] dismissWithClickedButtonIndex:0 animated:YES];
    }
}

- (void)dealloc {
    [userText release];
    [super dealloc];
}


@end

#pragma mark -
#pragma mark Error Alert 

@implementation ErrorAlert

+ (void)showWithTitle:(NSString *)title andMessage:(NSString *)message {
    
    CFRunLoopRef curLoop = CFRunLoopGetCurrent();
    ModalAlertDelegate *ead = [[ModalAlertDelegate alloc] initWithRunloop:curLoop];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:ead cancelButtonTitle:@"Quit" otherButtonTitles:nil];
    [alert show];
    CFRunLoopRun();
    
    [alert release];
    [ead release];
}


@end

@implementation LoadingAlert

+ (UIAlertView *)showWithMessage:(NSString *)message {
    
    UIAlertView *loadingAlert = [[[UIAlertView alloc] initWithTitle:@"Please Wait" 
                                                            message:message 
                                                           delegate:self 
                                                  cancelButtonTitle:nil 
                                                  otherButtonTitles:nil] autorelease];
    [loadingAlert show];
    UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];    
    CGPoint aivCenter = CGPointMake(loadingAlert.bounds.size.width/2.0f, loadingAlert.bounds.size.height-40.0f);
    DLog(@"center: %6.2f, %6.2f", aivCenter.x, aivCenter.y);
    aiv.center = aivCenter;
    
    if (aiv.center.y > 0) {   // bug workaround:  sometimes the activity view is centered at 0,-40 - not sure why.. nb
        [aiv startAnimating]; // but only show the activity indicator if the center is valid
        [loadingAlert addSubview:aiv];
    }
    [aiv release];
    
    return loadingAlert;
}

@end

@implementation NumberRequestor


+ (NSNumber *)requestNumberWith:(NSString *)question prompt:(NSString *)prompt {
    
    NSString *string = [InputRequestor requestInputWith:question placeHolder:prompt keyboardType:UIKeyboardTypeNumberPad];
    NSString *match = [string stringByMatching:@"^(\\d+)|(\\d*)\\.(\\d+)$"];
    if (!match || [match isEqual:@""]) {
        [ErrorAlert showWithTitle:@"Bad Number" andMessage:@"Please enter a valid number."];
        return nil;
    } 
    NSNumber *num = [NSNumber numberWithFloat:[string floatValue]];
    return num;
}

@end


@implementation InputRequestor

+ (NSString *)requestInputWith:(NSString *)question 
                   placeHolder:(NSString *)placeHolder 
                  keyboardType:(UIKeyboardType)kbType

{


    CFRunLoopRef currentLoop = CFRunLoopGetCurrent();
    ModalAlertDelegate *mad = [[ModalAlertDelegate alloc] initWithRunloop:currentLoop];
    
    UIAlertView *inputRequestor = [[UIAlertView alloc] initWithTitle:question 
                                                             message:@"\n" 
                                                            delegate:mad 
                                                   cancelButtonTitle:@"Cancel" 
                                                   otherButtonTitles:@"OK", nil];
    [mad setRequestorView:inputRequestor];
    
    UITextField *junk = [[UITextField alloc] init];
    UIFont *tfFont = [junk font];
    [junk release];
    
    CGSize placeHolderTextSize = [placeHolder sizeWithFont:tfFont];
    CGFloat minWidth = MAX(150.0f, placeHolderTextSize.width + 50.0f);
    
    UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, minWidth, 30.0f)];
    [tf setBorderStyle:UITextBorderStyleRoundedRect];
    [tf setTag:kTEXTVIEW_TAG];
    [tf setPlaceholder:placeHolder];
    [tf setClearButtonMode:UITextFieldViewModeWhileEditing];
    [tf setKeyboardType:kbType];
    [tf setKeyboardAppearance:UIKeyboardAppearanceAlert];
    [tf setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [tf setTextAlignment:UITextAlignmentCenter];
    
    [inputRequestor show];
    while (CGRectEqualToRect(inputRequestor.bounds, CGRectZero))  // wait for view to appear
        ;        
    CGRect bounds = inputRequestor.bounds;
    CGPoint tfCenter = CGPointMake(bounds.size.width/2.0f, bounds.size.height/2.0f - 10.0f);
    [tf setCenter:tfCenter];
    [inputRequestor addSubview:tf];
    [tf release];
    
    [mad performSelector:@selector(moveAlert:) withObject:inputRequestor afterDelay:0.7f];

    CFRunLoopRun();
    NSString *userInput = nil;
    
    if ([mad btnIndex] == 0) {
        userInput = nil;
    } else {
        userInput = [mad userText];
    }
    [inputRequestor release];
    [mad release];
    return userInput;
}

@end


