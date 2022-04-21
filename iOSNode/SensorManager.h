//
//  SensorManager.h
//  iOSNode
//
//  Created by Pierluigi Dalla Rosa on 5/5/16.
//  AGPL-3.0-only
//

#import <Foundation/Foundation.h>
#import <PSWebSocketServer.h>
@import AVFoundation;
#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import "utilsBF.h"

#define ORIENTATION     1
#define DISTANCE        2
#define TOUCH           3
#define SHAKE           4
#define HEADING         5
#define MAGNETOMER      6
#define POWERSOURCE     7
#define AUDIOJACK       8

@interface SensorManager : NSObject


@property (strong,nonatomic)NSMutableArray*         arrayTouch;
@property (strong,nonatomic)NSMutableArray*         arrayTouchDrag;
@property (strong,nonatomic)NSMutableArray*         arrayOrientation;
@property (strong,nonatomic)NSMutableArray*         arrayDistance;
@property (strong,nonatomic)NSMutableArray*         arrayShake;
@property (strong,nonatomic)NSMutableArray*         arrayHeading;
@property (strong,nonatomic)NSMutableDictionary*    dictionaryHeading;
@property (strong,nonatomic)NSMutableArray*         arrayMagnetometer;
@property (strong,nonatomic)NSMutableArray*         arrayAudioJack;
@property (strong,nonatomic)NSMutableArray*         arrayPowerSource;
@property (strong,nonatomic)NSMutableArray*         arrayAttitude;
@property (nonatomic,retain)CMMotionManager*        locationManager;

-(id)init;

//** SENSOR METHODS **//
//** GENERAL **//
-(void) registerSensor:(int)sensor withWebsocket:(PSWebSocket*)webSocket withOptions:(NSDictionary*)options;
-(void) registerSensor:(int)sensor withWebsocket:(PSWebSocket*)webSocket;
-(void) releaseSensor:(int)sensor withWebsocket:(PSWebSocket*)webSocket;

#define ORIENTATION     1
#define DISTANCE        2
#define TOUCH           3
#define SHAKE           4
#define HEADING         5
#define MAGNETOMER      6
#define POWERSOURCE     7
#define AUDIOJACK       8
#define ATTITUDE        9
#define TOUCHDOWN       10
#define TOUCHDRAG       11

//** ORIENTATION **//
-(void)orientationChangedWithNotification:(NSNotification*)notification;

//** DISTANCE **//
-(void)distanceChanged;

//** TOUCH **//
@property(assign)BOOL isMultitouchEnabled;
-(void)touchedWithNotification:(NSNotification*)notification;
-(void)touchedDownWithNotification:(NSNotification*)notification;
-(void)touchDragWithNotification:(NSNotification*)notification;

//** SHAKE **//
-(void)shakedWithNotification:(NSNotification*)notification;

//** HEADING **//
-(void)headingWithNotification:(NSNotification*)notification;

//** MAGNETOMER **//
@property (assign) CMMagneticField                  workingMagneticField;
@property (assign) CGFloat                          workingMagnitude;
@property (assign) BOOL                             isMagneticFieldBiggerThanThreshold;
@property (assign) BOOL                             workingFlagMagnetometer;
@property (nonatomic,strong)NSMutableDictionary*    dictionaryMagnetometerIntensity;

-(void)magnetometerWithNotification:(NSNotification*)notification;

//** POWERSOURCE **//
-(void)powerSourceChanged;

//** AUDIOJACK **//
-(void)audioJackWithNotification:(NSNotification*)notification;
@property (assign) BOOL _workingIsAudioJackIn;

//** ATTITUDE **//
-(void)startAttitudeUpdates;
-(void)stopAttitudeUpdates;


////** OSC **//
//@property(assign)BOOL isOSCAttitudeActive;
-(void)startAttitudeOSC:(NSNotification*)notification;
-(void)stopAttitudeOSC:(NSNotification*)notification;

//@property(assign)BOOL isOSCTouchActive;
//

//-(void)startTouchOSC:(NSNotification*)notification;
//
//-(void)stopTouchOSC:(NSNotification*)notification;

//** UTILS **//
-(void)removeWebSocketFromArrays:(PSWebSocket*)websocket;


@end
