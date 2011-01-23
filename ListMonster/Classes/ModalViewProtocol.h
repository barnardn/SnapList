/*
 *  ModalViewProtocol.h
 *  ListMonster
 *
 *  Created by Norm Barnard on 1/23/11.
 *  Copyright 2011 clamdango.com. All rights reserved.
 *
 */

@protocol ModalViewProtocol 
    
    -(void)modalViewCancelPressed;
    -(void)modalViewDonePressedWithReturnValue:(id)returnValue;

@end