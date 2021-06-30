//
//  oscManager.m
//  iOSNode
//
//  Created by Pierluigi Dalla Rosa on 9/25/17.
//  Copyright © 2017 binaryfutures. All rights reserved.
//

#import "OscManager.h"

@implementation OscManager

+ (id)sharedManager {
    static OscManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}
- (id)init {
    _isTouchActive = NO;
    _isAttitudeActive = NO;
    
    return self;
}

-(void)toggleAttitudeState{
    _isAttitudeActive = !_isAttitudeActive;
}

-(void)toggleTouchState{
    _isTouchActive = !_isTouchActive;
}

-(void)setAttitudeState:(BOOL)newState{
    _isAttitudeActive = newState;
}
-(void)setTouchState:(BOOL)newState{
    _isTouchActive = newState;
}


@end
