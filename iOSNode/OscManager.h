//
//  oscManager.h
//  iOSNode
//
//  Created by Pierluigi Dalla Rosa on 9/25/17.
//  Copyright © 2017 binaryfutures. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OscManager : NSObject

+(nonnull id)sharedManager;

@property (assign) BOOL isAttitudeActive;
@property (assign) BOOL isTouchActive;

@property (strong, nonatomic) NSString* ipAttitude;
@property (strong, nonatomic) NSString* ipTouch;

@property (assign) int portAttitude;
@property (assign) int portTouch;


-(void)setTouchState:(BOOL)newState;
-(void)setAttitudeState:(BOOL)newState;

-(void)toggleTouchState;
-(void)toggleAttitudeState;

@end
