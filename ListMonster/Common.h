/*
 *  Common.h
 *  ListMonster
 *
 *  Created by Norm Barnard on 12/28/2010.
 *  Copyright 2010 clamdango.com. All rights reserved.
 *
 */

#ifdef DEBUG
    #define DLog(...) NSLog(@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__])
    #define ALog(...) [[NSAssertionHandler currentHandler] handleFailureInFunction:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding] file:[NSString stringWithCString:__FILE__ encoding:NSUTF8StringEncoding] lineNumber:__LINE__ description:__VA_ARGS__]
#else
    #define DLog(...) do { } while (0)
    #ifndef NS_BLOCK_ASSERTIONS
        #define NS_BLOCK_ASSERTIONS
    #endif
    #define ALog(...) NSLog(@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__])
#endif

#define ZAssert(condition, ...) do { if (!(condition)) { ALog(__VA_ARGS__); }} while(0)

#define APP_DELEGATE(TYPE) (TYPE *)[UIApplication sharedApplication].delegate	
#define INT_OBJ(A)     ([NSNumber numberWithInt:(A)])
#define BOOL_OBJ(A)    ([NSNumber numberWithBool:(A)])
#define YES_OBJ        ([NSNumber numberWithBool:YES])
#define NO_OBJ         ([NSNumber numberWithBool:NO])


#define NOTICE_LIST_UPDATE  @"updatelist"
#define NOTICE_LIST_COUNTS  @"countchange"
