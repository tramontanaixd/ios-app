//
//  SensorManager.m
//  iOSNode
//
//  Created by Pierluigi Dalla Rosa on 5/5/16.
//  AGPL-3.0-only
//

#import "SensorManager.h"
#import "ConsoleManager.h"
#import "NetworkManager.h"
#import <OSCKit/OSCKit.h>
#import "OscManager.h"

#define MAGNETOMETER_MAGNITUDE_THRESHOLD @120.0
#define MAGNETOMETER_CENTRAL_VALUE 230
@implementation SensorManager


-(id)init{
    self = [super init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(touchedWithNotification:) name:@"touched" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(touchedDownWithNotification:) name:@"touchedDown" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(touchDragWithNotification:) name:@"touchDrag" object:nil];
    
    _arrayTouch         = [[NSMutableArray alloc]init];
    _arrayOrientation   = [[NSMutableArray alloc]init];
    _arrayShake         = [[NSMutableArray alloc]init];
    _arrayMagnetometer  = [[NSMutableArray alloc]init];
    _arrayAudioJack     = [[NSMutableArray alloc]init];
    _arrayPowerSource   = [[NSMutableArray alloc]init];
    _arrayDistance      = [[NSMutableArray alloc]init];
    _arrayShake         = [[NSMutableArray alloc]init];
    _arrayAttitude      = [[NSMutableArray alloc]init];
    _arrayTouchDrag     = [[NSMutableArray alloc]init];
    
    
    /** AUDIO JACK NOTIFICATION **/
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback  withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
    [audioSession setActive:YES error:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioJackWithNotification:) name:AVAudioSessionRouteChangeNotification object:nil];
    
    /** ORIENTATION NOTIFICATION **/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChangedWithNotification:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    /** MAGNETOMETER NOTIFICATION **/
    _locationManager = [[CMMotionManager alloc] init];
    _locationManager.magnetometerUpdateInterval = 0.25;
    _isMagneticFieldBiggerThanThreshold = NO;
    
    /** POWER SOURCE **/
    [UIDevice currentDevice].batteryMonitoringEnabled = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(powerSourceChanged) name:@"UIDeviceBatteryStateDidChangeNotification" object:nil];
    
    /** DISTANCE **/
    [UIDevice currentDevice].proximityMonitoringEnabled=NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(distanceChanged) name:UIDeviceProximityStateDidChangeNotification object:nil];
    
    //OSC
//    _isOSCAttitudeActive = NO;
    [[OscManager sharedManager] setAttitudeState:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startAttitudeOSC:) name:@"AttitudeToOSC" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopAttitudeOSC:) name:@"stopAttitudeToOSC" object:nil];
    
    return self;
}

//** SENSOR METHODS **//
//** GENERAL **//
-(void) registerSensor:(int)sensor withWebsocket:(PSWebSocket*)webSocket{
    
      NSDictionary*  options=[[NSDictionary alloc] init];
    [self registerSensor:sensor withWebsocket:webSocket withOptions:options];
}
-(void) registerSensor:(int)sensor withWebsocket:(PSWebSocket*)webSocket withOptions:(NSDictionary*)options{
   
    switch (sensor) {
        case ORIENTATION:
            if(![_arrayOrientation containsObject:webSocket]){
                [_arrayOrientation addObject:webSocket];
            }
            break;
        case DISTANCE:
            if(![_arrayDistance containsObject:webSocket]){
                [_arrayDistance addObject:webSocket];
                [UIDevice currentDevice].proximityMonitoringEnabled=YES;
            }
            break;
        case TOUCH:
            if(![_arrayTouch containsObject:webSocket]){
                [_arrayTouch addObject:webSocket];
                
            }
            break;
        case TOUCHDRAG:
            if(![_arrayTouchDrag containsObject:webSocket]){
                
                [_arrayTouchDrag addObject:webSocket];
                
            }
            break;
        case SHAKE:
            if(![_arrayShake containsObject:webSocket]){
                [_arrayShake addObject:webSocket];
            }
            break;
        case HEADING:
            
            break;
        case MAGNETOMER:
            if(![_arrayMagnetometer containsObject:webSocket]){
                [_arrayMagnetometer addObject:webSocket];
                
                if(!_locationManager.magnetometerActive)
                {
                    [_locationManager startMagnetometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMMagnetometerData *magnetometerData, NSError *error){
                        if(error==nil)
                        {
                            
                            _workingMagneticField=magnetometerData.magneticField;
                            _workingMagnitude = sqrt(_workingMagneticField.x*_workingMagneticField.x + _workingMagneticField.y*_workingMagneticField.y + _workingMagneticField.z*_workingMagneticField.z);
                                                        _workingFlagMagnetometer=YES;
                            if(fabsf(_workingMagnitude-MAGNETOMETER_CENTRAL_VALUE)>[MAGNETOMETER_MAGNITUDE_THRESHOLD floatValue])
                            {
                               _isMagneticFieldBiggerThanThreshold = YES;
                            }
                            else if(_isMagneticFieldBiggerThanThreshold)
                            {
                                _isMagneticFieldBiggerThanThreshold = NO;
                            }
                            else
                            {
                                _workingFlagMagnetometer=NO;
                            }
                            if(_workingFlagMagnetometer)
                            {
                                for (PSWebSocket* socketTmp in _arrayMagnetometer) {
                                    [socketTmp send:[NSString stringWithFormat:@"{\"m\":\"magnetometerUpdate\",\"t\":\"%d\",\"i\":\"%f\"}",_isMagneticFieldBiggerThanThreshold,_workingMagnitude]];
                                }
                            }
                        }
                        else
                        {
                            NSLog(@"error in updating magnetometer");
                        }
                       
                    }];
                }
            }
            break;
        case AUDIOJACK:
            if(![_arrayAudioJack containsObject:webSocket]){
                [_arrayAudioJack addObject:webSocket];
            }
            break;
        case POWERSOURCE:
            if(![_arrayPowerSource containsObject:webSocket]){
                [_arrayPowerSource addObject:webSocket];
                [UIDevice currentDevice].batteryMonitoringEnabled = YES;
            }
            break;
        case ATTITUDE:
            if(![_arrayAttitude containsObject:webSocket]){
                [_arrayAttitude addObject:webSocket];
                [self startAttitudeUpdatesWithInterval: 1/(([[options valueForKey:@"f"] floatValue]>0)?[[options valueForKey:@"f"] floatValue]:1.0) andSocket:webSocket];
            }
            break;
        default:
            break;
    }
}
-(void)startAttitudeUpdatesWithInterval:(float)f andSocket:(PSWebSocket*)socket{
        BOOL isOSC = NO;
        if(socket == nil)
        {
            //OSC
//            if(!_isOSCAttitudeActive)
            if(! [[OscManager sharedManager] isAttitudeActive])
            {
                isOSC = YES;
                [[OscManager sharedManager] setAttitudeState:YES];
//                _isOSCAttitudeActive = YES;
            }
            else{
                return;
            }
        }
    
    _locationManager.deviceMotionUpdateInterval = f;
    [_locationManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
        if(!isOSC)
        {
            if([_arrayAttitude containsObject:socket])
            {
                [socket send: [NSString stringWithFormat:@"{\"m\":\"a\",\"r\":\"%f\",\"p\":\"%f\",\"y\":\"%f\"}",motion.attitude.roll,motion.attitude.pitch,motion.attitude.yaw]];
            }
        }
        //OSC
        else
        {
            OSCMessage *message = [OSCMessage to:@"/wek/inputs" with:@[[NSNumber numberWithDouble: motion.attitude.roll],[NSNumber numberWithDouble:motion.attitude.pitch],[NSNumber numberWithDouble:motion.attitude.yaw]]];
            
            [[NetworkManager sharedManager] sendAttitudeMessageToOSC:message];
        }
    } ];

    
}
-(void)stopAttitudeUpdatesWithSocket:(PSWebSocket*)socket{
    if(socket!=nil)
    {
        [_arrayAttitude removeObject:socket];
    }
    else
    {
//        _isOSCAttitudeActive = NO;
        [[OscManager sharedManager] setAttitudeState:NO];
    }
    if([_arrayAttitude count]==0 && ![[OscManager sharedManager] isAttitudeActive])//!_isOSCAttitudeActive)
    {
        [_locationManager stopDeviceMotionUpdates];
        
    }
}


-(void) releaseSensor:(int)sensor withWebsocket:(PSWebSocket*)webSocket{
    switch (sensor) {
        case ORIENTATION:
            if([_arrayOrientation containsObject:webSocket]){
                [_arrayOrientation removeObject:webSocket];
            }
            break;
        case DISTANCE:
            
            if([_arrayDistance containsObject:webSocket]){
                [_arrayDistance removeObject:webSocket];
                if([_arrayDistance count]==0)
                {
                    [UIDevice currentDevice].proximityMonitoringEnabled=NO;
                }
            }
            break;
        case TOUCH:
            if([_arrayTouch containsObject:webSocket]){
                [_arrayTouch removeObject:webSocket];
            }
            break;
        case TOUCHDRAG:
            if([_arrayTouchDrag containsObject:webSocket]){
                [_arrayTouchDrag removeObject:webSocket];
            }
            break;
        case SHAKE:
            if([_arrayShake containsObject:webSocket]){
                [_arrayShake removeObject:webSocket];
            }
            break;
        case HEADING:
            
            break;
        case MAGNETOMER:
            if([_arrayMagnetometer containsObject:webSocket]){
                [_arrayMagnetometer removeObject:webSocket];
                if([_arrayMagnetometer count]==0 && _locationManager.magnetometerActive)
                {
                    [_locationManager stopMagnetometerUpdates];
                }
            }
            break;
        case AUDIOJACK:
            if([_arrayAudioJack containsObject:webSocket]){
                [_arrayAudioJack removeObject:webSocket];
            }
            break;
        default:
        case POWERSOURCE:
            if([_arrayPowerSource containsObject:webSocket]){
                [_arrayPowerSource removeObject:webSocket];
                if([_arrayPowerSource count]==0)
                {
                    [UIDevice currentDevice].batteryMonitoringEnabled = NO;
                }
            }
            break;
        case ATTITUDE:
            if([_arrayAttitude containsObject:webSocket]){
                [self stopAttitudeUpdatesWithSocket:webSocket];
            }
            break;
            break;
    }
}


//** ORIENTATION **//
-(void)orientationChangedWithNotification:(NSNotification*)notification{
    for (PSWebSocket* socketTmp in _arrayOrientation) {
        [socketTmp send:[NSString stringWithFormat:@"{\"m\":\"orientationChanged\",\"value\":\"%d\"}",(int)[[UIDevice currentDevice] orientation]]];
    }
}
//** DISTANCE **//
-(void)distanceChanged{

    for (PSWebSocket* socketTmp in _arrayDistance) {
        [socketTmp send:[NSString stringWithFormat:@"{\"m\":\"distanceChanged\",\"proximity\":\"%d\"}",[[UIDevice currentDevice] proximityState]]];
    }
}
//** TOUCH **//
-(void)touchedWithNotification:(NSNotification*)notification{
    for (PSWebSocket* socketTmp in _arrayTouch) {
        if([[notification.userInfo allKeys] containsObject:@"touches"])
        {
            
           
            [socketTmp send:[NSString stringWithFormat:@"{\"m\":\"touched\",\"ts\":%@}",[notification.userInfo valueForKey:@"touches"]]];
        }
        else
        {
            [socketTmp send:[NSString stringWithFormat:@"{\"m\":\"touched\",\"x\":\"%d\",\"y\":\"%d\"}",[[notification.userInfo valueForKey:@"x"]intValue],[[notification.userInfo valueForKey:@"y"]intValue]]];
        }
    }
}
-(void)touchedDownWithNotification:(NSNotification*)notification{
    for (PSWebSocket* socketTmp in _arrayTouch) {
        NSLog(@"down %@",[notification.userInfo valueForKey:@"touches"]);
        if([[notification.userInfo allKeys] containsObject:@"touches"])
        {
            
            
            [socketTmp send:[NSString stringWithFormat:@"{\"m\":\"touchedDown\",\"ts\":%@}",[notification.userInfo valueForKey:@"touches"]]];
        }
        else
        {
            [socketTmp send:[NSString stringWithFormat:@"{\"m\":\"touchedDown\",\"x\":\"%d\",\"y\":\"%d\"}",[[notification.userInfo valueForKey:@"x"]intValue],[[notification.userInfo valueForKey:@"y"]intValue]]];
        }
    }
}
-(void)touchDragWithNotification:(NSNotification*)notification{
    for (PSWebSocket* socketTmp in _arrayTouchDrag) {
        
        if([[notification.userInfo allKeys] containsObject:@"touches"])
        {
            [socketTmp send:[NSString stringWithFormat:@"{\"m\":\"drag\",\"ts\":%@}",[notification.userInfo valueForKey:@"touches"]]];
            
            
        }
        else
        {
            [socketTmp send:[NSString stringWithFormat:@"{\"m\":\"drag\",\"x\":\"%d\",\"y\":\"%d\"}",[[notification.userInfo valueForKey:@"x"]intValue],[[notification.userInfo valueForKey:@"y"]intValue]]];
        }
    }
    
    
    
}
//** SHAKE **//
-(void)shakedWithNotification:(NSNotification*)notification{
    
}

//** HEADING **//
-(void)headingWithNotification:(NSNotification*)notification{
    
}

//** MAGNETOMER **//
-(void)magnetometerWithNotification:(NSNotification*)notification{
    
}

//** POWERSOURCE **//
-(void)powerSourceChanged{
    [[ConsoleManager sharedManager] log:[NSString stringWithFormat:@"Power Source changed: %d}",(int)[UIDevice currentDevice].batteryState]];
    for (PSWebSocket* socketTmp in _arrayPowerSource) {
        [socketTmp send:[NSString stringWithFormat:@"{\"m\":\"powerSourceChanged\",\"source\":\"%d\"}",(int)[UIDevice currentDevice].batteryState]];
    }
}
//** ATTITUDE **//


//** AUDIOJACK **//
-(void)audioJackWithNotification:
(NSNotification*)notification{
    
    NSInteger routeChangeReason = [notification.userInfo[AVAudioSessionRouteChangeReasonKey] integerValue];
    __workingIsAudioJackIn = NO;
    if (routeChangeReason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
       // NSLog(@"jack disconnnetcted");
        // The old device is unavailable == headphones have been unplugged
    }
    else if(routeChangeReason == AVAudioSessionRouteChangeReasonNewDeviceAvailable)
    {
      //  NSLog(@"jack connected");
        __workingIsAudioJackIn=YES;
    }
    if(routeChangeReason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable || routeChangeReason == AVAudioSessionRouteChangeReasonNewDeviceAvailable)
    {
        for (PSWebSocket* wsTmp in _arrayAudioJack) {
            [wsTmp send:[NSString stringWithFormat:@"{\"m\":\"audioJackChanged\",\"in\":\"%d\"}",__workingIsAudioJackIn]];
        }
    }
    
   
}


/// REMOVE IF FAILS OR CLOSE
-(void)removeWebSocketFromArrays:(PSWebSocket*)websocket{
    
    if([_arrayOrientation containsObject:websocket]){
        [_arrayOrientation removeObject:websocket];
    }
    
    if([_arrayDistance containsObject:websocket]){
        [_arrayDistance removeObject:websocket];
        if([_arrayDistance count]==0)
        {
            [UIDevice currentDevice].proximityMonitoringEnabled=NO;
        }
    }
    
    if([_arrayTouch containsObject:websocket]){
        [_arrayTouch removeObject:websocket];
    }
    if([_arrayTouchDrag containsObject:websocket]){
        [_arrayTouchDrag removeObject:websocket];
    }
    if([_arrayShake containsObject:websocket]){
        [_arrayShake removeObject:websocket];
    }
    
    if([_arrayMagnetometer containsObject:websocket]){
        [_arrayMagnetometer removeObject:websocket];
        if([_arrayMagnetometer count]==0 && _locationManager.magnetometerActive)
        {
            [_locationManager stopMagnetometerUpdates];
        }
    }
    
    if([_arrayAudioJack containsObject:websocket]){
        [_arrayAudioJack removeObject:websocket];
    }
   
    if([_arrayPowerSource containsObject:websocket]){
        [_arrayPowerSource removeObject:websocket];
        if([_arrayPowerSource count]==0)
        {
            [UIDevice currentDevice].batteryMonitoringEnabled = NO;
        }
    }
    
    if([_arrayAttitude containsObject:websocket]){
        [_arrayAttitude removeObject:websocket];
        if([_arrayAttitude count]==0)
        {
            [_locationManager stopDeviceMotionUpdates];
        }
    }
}
//#pragma mark OSC
-(void)startAttitudeOSC:(NSNotification*)notification{
    
   
    [self startAttitudeUpdatesWithInterval: 1/(([[notification.userInfo objectForKey:@"f"] floatValue]>0)?[[notification.userInfo objectForKey:@"f"] floatValue]:1.0) andSocket:nil];
    
    NSLog(@"attitude start");
}

-(void)stopAttitudeOSC:(NSNotification*)notification{
    
    [self stopAttitudeUpdatesWithSocket:nil];
   
    NSLog(@"attitude stop");
}
//
//-(void)startTouchOSC:(NSNotification*)notification{
//    
//}
//
//-(void)stopTouchOSC:(NSNotification*)notification{
//    
//}

@end
