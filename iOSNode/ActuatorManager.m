//
//  ActuatorManager.m
//  iOSNode
//
//  Created by local on 5/5/16.
//  Copyright © 2016 binaryfutures. All rights reserved.
//

#import "ActuatorManager.h"
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>


@implementation ActuatorManager

-(id)init{
    self=[super init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(makeVibrate) name:@"makeVibrate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setBrightness:) name:@"setBrightness" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setLED:) name:@"setLED" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pulseLEDwith:) name:@"pulseLED" object:nil];
    
    
    _currentPulsesAlreadyDone=0;
    _isLEDOn=NO;
    return self;
}
-(void)makeVibrate{
     AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}
-(void)setBrightness:(NSNotification*)notification{
    float brightness = [[notification.userInfo valueForKey:@"b"] floatValue];
    [[UIScreen mainScreen] setBrightness:brightness];
}


- (void)setLED: (NSNotification*)notification{
    // check if flashlight available
    BOOL on = [[notification.userInfo valueForKey:@"on"] boolValue];
    float intensity = [[notification.userInfo valueForKey:@"in"] floatValue];
    intensity = CLAMP(intensity, 0.1, 1.0);
    
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && [device hasFlash]){
            
            [device lockForConfiguration:nil];
            if (on) {
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
                [device setTorchModeOnWithLevel:intensity error:NULL];
                //torchIsOn = YES; //define as a variable/property if you need to know status
            } else {
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
                //torchIsOn = NO;
            }
            [device unlockForConfiguration];
        }
    }
}
-(void)pulseLEDwith: (NSNotification*)notification{
    float duration = [[notification.userInfo valueForKey:@"d"] floatValue];
    int times     = [[notification.userInfo valueForKey:@"t"] intValue];
    float intensity = [[notification.userInfo valueForKey:@"i"] floatValue];
    _currentPulsesAlreadyDone=times*2;
    __block void (^loopingBlock)(void) = ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSDictionary* userInfo;
            if(_currentPulsesAlreadyDone>0)
            {
                _currentPulsesAlreadyDone--;
                userInfo=[NSDictionary dictionaryWithObjectsAndKeys:(_isLEDOn)?@"0":@"1",@"on",[NSNumber numberWithFloat:intensity],@"in", nil];
                _isLEDOn=!_isLEDOn;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"setLED" object:self userInfo:userInfo];
                loopingBlock();
            }
            else
            {
                _currentPulsesAlreadyDone=-1;
                userInfo=[NSDictionary dictionaryWithObjectsAndKeys:@"0",@"on",[NSNumber numberWithFloat:intensity],@"in", nil];
                _isLEDOn=NO;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"setLED" object:self userInfo:userInfo];
            }
        });
    };
    loopingBlock();
    
}
-(void)playVideo:(NSNotification *)notification
{
    //download the file in a seperate thread.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"Downloading Started");
        NSString *urlToDownload = @"http://techslides.com/demos/sample-videos/small.mp4";
        NSURL  *url = [NSURL URLWithString:urlToDownload];
        NSData *urlData = [NSData dataWithContentsOfURL:url];
        if ( urlData )
        {
            
            NSLog(@"urldata %@   ",urlData);
            NSArray   *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString  *documentsDirectory = [paths objectAtIndex:0];
            
            NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"demo2.mp4"];
            
            //saving is done on main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                [urlData writeToFile:filePath atomically:YES];
                NSLog(@"File Saved !%@",filePath);
               // _url = [NSURL URLWithString:filePath];
                
                
            });
        }
        
    });
}
@end
