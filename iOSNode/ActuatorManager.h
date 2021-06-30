//
//  ActuatorManager.h
//  iOSNode
//
//  Created by local on 5/5/16.
//  Copyright © 2016 binaryfutures. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <UIKit/UIKit.h>
#import "utilsBF.h"

@interface ActuatorManager : NSObject


-(id)init;
-(void)setBrightness:(NSNotification*)notification;
-(void)makeVibrate;


//** LED **//
-(void)setLED: (NSNotification*)notification;
@property (assign)int currentPulsesAlreadyDone;
@property (assign)BOOL isLEDOn;
-(void)pulseLEDwith: (NSNotification*)notification;

@end
