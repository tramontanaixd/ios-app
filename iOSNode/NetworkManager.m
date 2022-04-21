//
//  NetworkManager.m
//  serverConnector2
//
//  Created by Pierluigi Dalla Rosa on 3/16/16.
//  AGPL-3.0-only
//

#define PORT 9092
#import "NetworkManager.h"
#import "ConsoleManager.h"
#if TARGET_OS_IOS
    #import <DropboxSDK/DropboxSDK.h>
#elif TARGET_OS_TV
// tvOS-specific code
#endif


@implementation NetworkManager

+ (id)sharedManager {
    static NetworkManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    _server = [PSWebSocketServer serverWithHost:nil port:PORT];
    _server.delegate = self;
    [_server start];
#if TARGET_OS_IOS
_sm = [[SensorManager alloc]init];
#elif TARGET_OS_TV
    // tvOS-specific code
#endif
    
    _sockets =[[NSMutableArray alloc]init];
    
    [self pingClients];
    
    /// OSC ///
    _oscTouchIP   = @"";
    _oscTouchPORT = 9093;
    
    _oscAttitudeIP   = @"";
    _oscAttitudePORT = 9094;
    
    _oscTouchClient = [[OSCClient alloc] init];
    _oscAttitudeClient = [[OSCClient alloc] init];
    return self;
}

-(void)pingClients{
    
    for (PSWebSocket* wsTmp in _sockets) {
#if TARGET_OS_IOS
        [wsTmp send:@"{\"m\":\"xm\"}"];
#elif TARGET_OS_TV
        [wsTmp send:@"{\"m\":\"xt\"}"];
#endif
        
    
    }
    [self performSelector:@selector(pingClients) withObject:nil afterDelay:5.0];
}
#pragma mark - PSWebSocketServerDelegate

- (void)serverDidStart:(PSWebSocketServer *)server {
    NSLog(@"Server did start…");
    [[ConsoleManager sharedManager] log:@"server started"];
}
- (void)serverDidStop:(PSWebSocketServer *)server {
    NSLog(@"Server did stop…");
    [[ConsoleManager sharedManager] log:@"server stopped"];
}
- (void)server:(PSWebSocketServer *)server didFailWithError:(NSError *)error {
    NSLog(@"Server Failed");
    [[ConsoleManager sharedManager] log:@"server failed"];
    
}
- (BOOL)server:(PSWebSocketServer *)server acceptWebSocketWithRequest:(NSURLRequest *)request {
    // NSLog(@"Server should accept request: %@", request);
    return YES;
}
#pragma mark -
- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didReceiveMessage:(id)message {
    
    NSLog(@"Server websocket did receive message: %@", message);
    
#if false
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(RAND_FROM_TO(1.0,2.0) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970];
        printf("%f", timeInMiliseconds);
        [webSocket send:@"{\"m\":\"test\"}"];
        
        
    });
#endif
    
    NSError *error = nil;
    NSData* data = [message dataUsingEncoding:NSUTF8StringEncoding];
    id object = [NSJSONSerialization
                 JSONObjectWithData:data
                 options:0
                 error:&error];
    
    if(error) {
        /* JSON was malformed*/
        [webSocket send:@"{\"error\":\"BAD JSON\"}"];
    }
    
    // the originating poster wants to deal with dictionaries;
    // assuming you do too then something like this is the first
    // validation step:
    if([object isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *results = object;
       
        if([[results allKeys] containsObject:@"m"])
        {
            NSString* keyDirective      = [results valueForKey:@"m"];
            
            NSLog(@"received %@",keyDirective);
             [[ConsoleManager sharedManager] log:[NSString stringWithFormat:@"-> received message:%@",keyDirective]];
            //**** ACTUATE ****//
            #pragma mark ACTUATE
            if([keyDirective isEqualToString:@"makeVibrate"])
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:keyDirective object:nil];
            }
            else if([keyDirective isEqualToString:@"setColor"])
            {
            #if TARGET_OS_OSX
                 NSColor* colTmp = [NSColor colorWithRed:[[results valueForKey:@"r"] floatValue] green:[[results valueForKey:@"g"] floatValue] blue:[[results valueForKey:@"b"] floatValue] alpha:1.0];
            #else
                UIColor* colTmp = [UIColor colorWithRed:[[results valueForKey:@"r"] floatValue] green:[[results valueForKey:@"g"] floatValue] blue:[[results valueForKey:@"b"] floatValue] alpha:1.0];
            #endif
                
                NSNumber* alpha = [NSNumber numberWithFloat:[[results valueForKey:@"a"] floatValue]];
                NSDictionary* userInfo=[NSDictionary dictionaryWithObjectsAndKeys:colTmp,@"color",alpha,@"alpha", nil];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:keyDirective object:self userInfo:userInfo];
            }
            else if([keyDirective isEqualToString:@"transitionColors"])
            {
                #if TARGET_OS_OSX
                NSColor* col1Tmp = [NSColor colorWithRed:[[results valueForKey:@"r1"] floatValue] green:[[results valueForKey:@"g1"] floatValue] blue:[[results valueForKey:@"b1"] floatValue] alpha:[[results valueForKey:@"a1"] floatValue]];
                NSColor* col2Tmp = [NSColor colorWithRed:[[results valueForKey:@"r2"] floatValue] green:[[results valueForKey:@"g2"] floatValue] blue:[[results valueForKey:@"b2"] floatValue] alpha:[[results valueForKey:@"a2"] floatValue]];
                #else
                UIColor* col1Tmp = [UIColor colorWithRed:[[results valueForKey:@"r1"] floatValue] green:[[results valueForKey:@"g1"] floatValue] blue:[[results valueForKey:@"b1"] floatValue] alpha:[[results valueForKey:@"a1"] floatValue]];
                UIColor* col2Tmp = [UIColor colorWithRed:[[results valueForKey:@"r2"] floatValue] green:[[results valueForKey:@"g2"] floatValue] blue:[[results valueForKey:@"b2"] floatValue] alpha:[[results valueForKey:@"a2"] floatValue]];
                #endif
                NSNumber* duration = [NSNumber numberWithFloat:[[results valueForKey:@"duration"] floatValue]];
                NSNumber* alpha1 = [NSNumber numberWithFloat:[[results valueForKey:@"a1"] floatValue]];
                NSNumber* alpha2 = [NSNumber numberWithFloat:[[results valueForKey:@"a2"] floatValue]];
                NSDictionary* userInfo=[NSDictionary dictionaryWithObjectsAndKeys:col1Tmp,@"color1",col2Tmp,@"color2",alpha1,@"alpha1",alpha2,@"alpha2",duration,@"duration", nil];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:keyDirective object:self userInfo:userInfo];
            }
            else if([keyDirective isEqualToString:@"setBrightness"])
            {
                NSNumber* brightnessTmp = [NSNumber numberWithFloat:[[results valueForKey:@"b"] floatValue]];
                NSDictionary* userInfo=[NSDictionary dictionaryWithObjectsAndKeys:brightnessTmp,@"b", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:keyDirective object:self userInfo:userInfo];
            }
            else if([keyDirective isEqualToString:@"setLED"])
            {
                NSDictionary* userInfo=[NSDictionary dictionaryWithObjectsAndKeys:[results valueForKey:@"value"],@"on",[results valueForKey:@"in"],@"in", nil];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:keyDirective object:self userInfo:userInfo];
            }
            else if([keyDirective isEqualToString:@"pulseLED"])
            {
                NSDictionary* userInfo=[NSDictionary dictionaryWithObjectsAndKeys:[results valueForKey:@"t"],@"t",[results valueForKey:@"i"],@"i",[results valueForKey:@"d"],@"d", nil];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:keyDirective object:self userInfo:userInfo];
            }
            else if([keyDirective isEqualToString:@"getBattery"])
            {
#if TARGET_OS_IOS
                [UIDevice currentDevice].batteryMonitoringEnabled = YES;
                [webSocket send:[NSString stringWithFormat:@"{\"m\":\"battery\",\"v\":\"%.01f\"}",[UIDevice currentDevice].batteryLevel]];
                [UIDevice currentDevice].batteryMonitoringEnabled = NO;

#elif TARGET_OS_TV
                // tvOS-specific code
#endif
                            }
            #pragma mark MEDIA
            else if([keyDirective isEqualToString:@"playAudio"])
            {
                if([[results allKeys] containsObject:@"url"] && ![((NSString*)[results valueForKey:@"url"]) isEqualToString:@""] )
                {
                    int numOfLoops=0;
                    if([[results allKeys] containsObject:@"loops"])
                    {
                        numOfLoops=[[results valueForKey:@"loops"] intValue];
                    }
                    NSDictionary* userInfo=[NSDictionary dictionaryWithObjectsAndKeys:[results valueForKey:@"url"],@"url",[NSNumber numberWithInt:numOfLoops],@"l", nil];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:keyDirective object:self userInfo:userInfo];
                    
                }
            }
            else if([keyDirective isEqualToString:@"showImage"])
            {
                if([[results allKeys] containsObject:@"url"] && ![((NSString*)[results valueForKey:@"url"]) isEqualToString:@""] )
                {
                    NSDictionary* userInfo=[NSDictionary dictionaryWithObjectsAndKeys:[results valueForKey:@"url"],@"url", nil];
                  
                    [[NSNotificationCenter defaultCenter] postNotificationName:keyDirective object:self userInfo:userInfo];
                    
                }
            }
            else if([keyDirective isEqualToString:@"setVolume"])
            {
                NSNumber* volumeTmp = [NSNumber numberWithFloat:[[results valueForKey:@"v"] floatValue]];
                NSDictionary* userInfo=[NSDictionary dictionaryWithObjectsAndKeys:volumeTmp,@"v", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:keyDirective object:self userInfo:userInfo];
            }
            else if([keyDirective isEqualToString:@"playGIF"])
            {
                
            }
            else if([keyDirective isEqualToString:@"playVideo"])
            {
                if([[results allKeys] containsObject:@"url"] && ![((NSString*)[results valueForKey:@"url"]) isEqualToString:@""] )
                {
                    NSDictionary* userInfo=[NSDictionary dictionaryWithObjectsAndKeys:[results valueForKey:@"url"],@"url",@"NO",@"loop",webSocket,@"socket", nil];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:keyDirective object:self userInfo:userInfo];
                    
                }
            }
            else if([keyDirective isEqualToString:@"loopVideo"])
            {
                if([[results allKeys] containsObject:@"url"] && ![((NSString*)[results valueForKey:@"url"]) isEqualToString:@""] )
                {
                    
                    NSDictionary* userInfo=[NSDictionary dictionaryWithObjectsAndKeys:[results valueForKey:@"url"],@"url",@"YES",@"loop",webSocket,@"socket", nil];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"playVideo" object:self userInfo:userInfo];
                    
                }
            }
            else if([keyDirective isEqualToString:@"takePicture"])
            {
#if TARGET_OS_IOS
                BOOL pickerInterfaceNeeded=NO;
                NSNumber *n=[NSNumber numberWithInteger:0];
                if([[results allKeys] containsObject:@"c"] && ![((NSString*)[results valueForKey:@"c"]) isEqualToString:@""] )
                {
                    @try {
                        n=[NSNumber numberWithInteger:[[results valueForKey:@"c"] intValue]];
                    } @catch (NSException *exception) {
                        n=[NSNumber numberWithInteger:0];
                    } @finally {
                        
                    }
                    
                }
                
                if([[results allKeys] containsObject:@"i"] && ![((NSString*)[results valueForKey:@"i"]) isEqualToString:@""] )
                {
                    NSString *stringTmp=[NSString stringWithFormat:@"%@",[results valueForKey:@"i"]];
                    if([[NSString stringWithFormat:@"ui"] isEqualToString:stringTmp])
                    {
                        pickerInterfaceNeeded=YES;
                    }
                }
                if(pickerInterfaceNeeded)
                {
                    NSDictionary* userInfo=[NSDictionary dictionaryWithObjectsAndKeys:n,@"c",webSocket,@"socket",@"ui",@"i", nil];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:keyDirective object:self userInfo:userInfo];
                }
                else
                {
                    //DROPBOX
                    if ([DBClientsManager authorizedClient]!=NULL) {
                        
                       
                        NSDictionary* userInfo=[NSDictionary dictionaryWithObjectsAndKeys:n,@"c",webSocket,@"socket",@"-",@"i", nil];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:keyDirective object:self userInfo:userInfo];
                        
                    }
                }
                
#endif
            }

            //**** OSC ****//
#if TARGET_OS_IOS
            #pragma mark OSC
            else if([keyDirective isEqualToString:@"st2w"]){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"stopTouchToOSC" object:self];
            }
            else if([keyDirective isEqualToString:@"t2w"])
            {
                int numTouchesToOSC = 1;
                if(([[results allKeys] containsObject:@"n"]))
                {
                    numTouchesToOSC =[[results objectForKey:@"n"] intValue];
                }

                NSDictionary* userInfo=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:numTouchesToOSC],@"num", nil];
                _oscTouchIP   = [results objectForKey:@"i"];
                _oscTouchPORT = [[results objectForKey:@"p"] intValue];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"touchToOSC" object:self userInfo:userInfo];
               
            }
            else if([keyDirective isEqualToString:@"a2w"] && [[results allKeys] containsObject:@"f"])
            {
                //send accelerometer to OSC
                _oscAttitudeIP   = [results objectForKey:@"i"];
                _oscAttitudePORT = [[results objectForKey:@"p"] intValue];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"AttitudeToOSC" object:self userInfo:@{@"f":[results objectForKey:@"f"]}];
            }
            else if([keyDirective isEqualToString:@"sa2w"])
            {
                //stop sending accelerometer to OSC
                [[NSNotificationCenter defaultCenter] postNotificationName:@"stopAttitudeToOSC" object:self ];
            }
            //**** SENSE ****//
            #pragma mark SENSE
            else if([keyDirective isEqualToString:@"registerTouch"])
            {
                
                if(([[results allKeys] containsObject:@"multi"]))
                {
                    if(([[results valueForKey:@"multi"] intValue]==1))
                    {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"multitouchEnabled" object:nil userInfo:@{@"WSM":@YES}];
                    }
                    else{
                       
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"multitouchDisabled" object:nil userInfo:@{@"WSM":@NO}];
                    }
                }
                [_sm registerSensor:TOUCH withWebsocket:webSocket];
            }
            else if([keyDirective isEqualToString:@"registerTouchDrag"])
            {
                
                if(([[results allKeys] containsObject:@"multi"]))
                {
                    if(([[results valueForKey:@"multi"] intValue]==1))
                    {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"multitouchEnabled" object:nil userInfo:@{@"WSM":@YES}];
                    }
                    else{
                       [[NSNotificationCenter defaultCenter] postNotificationName:@"multitouchDisabled" object:nil userInfo:@{@"WSM":@NO}];
                    }
                }
                [_sm registerSensor:TOUCHDRAG withWebsocket:webSocket];
            }
            else if([keyDirective isEqualToString:@"releaseTouch"])
            {
                [_sm releaseSensor:TOUCH withWebsocket:webSocket];
            }
            else if([keyDirective isEqualToString:@"releaseTouchDrag"])
            {
                [_sm releaseSensor:TOUCHDRAG withWebsocket:webSocket];
            }
            else if([keyDirective isEqualToString:@"registerOrientation"])
            {
                [_sm registerSensor:ORIENTATION withWebsocket:webSocket];
            }
            else if([keyDirective isEqualToString:@"releaseOrientation"])
            {
                [_sm releaseSensor:ORIENTATION withWebsocket:webSocket];
            }
            else if([keyDirective isEqualToString:@"registerShaked"])
            {
                
            }
            else if([keyDirective isEqualToString:@"releaseShaked"])
            {
                
            }
            else if([keyDirective isEqualToString:@"registerMagnetometer"])
            {
                [_sm registerSensor:MAGNETOMER withWebsocket:webSocket];
            }
            else if([keyDirective isEqualToString:@"releaseMagnetometer"])
            {
                [_sm releaseSensor:MAGNETOMER withWebsocket:webSocket];
            }
            else if([keyDirective isEqualToString:@"registerAttitude"])
            {
                
                    [_sm registerSensor:ATTITUDE withWebsocket:webSocket withOptions:@{@"f":(([[results allKeys] containsObject:@"f"])?[results valueForKey:@"f"]:@1.0)}];
            }
            else if([keyDirective isEqualToString:@"releaseAttitude"])
            {
                [_sm releaseSensor:ATTITUDE withWebsocket:webSocket];
            }
            else if([keyDirective isEqualToString:@"registerAudioJack"])
            {
                [_sm registerSensor:AUDIOJACK withWebsocket:webSocket];
            }
            else if([keyDirective isEqualToString:@"releaseAudioJack"])
            {
                [_sm releaseSensor:AUDIOJACK withWebsocket:webSocket];
            }
            else if([keyDirective isEqualToString:@"registerPowerSource"])
            {
                [_sm registerSensor:POWERSOURCE withWebsocket:webSocket];
            }
            else if([keyDirective isEqualToString:@"releasePowerSource"])
            {
                [_sm releaseSensor:POWERSOURCE withWebsocket:webSocket];
            }
            else if([keyDirective isEqualToString:@"registerDistance"])
            {
                [_sm registerSensor:DISTANCE withWebsocket:webSocket];
            }
            else if([keyDirective isEqualToString:@"releaseDistance"])
            {
                [_sm releaseSensor:DISTANCE withWebsocket:webSocket];
            }
            else if([keyDirective isEqualToString:@"registerAccelerometer"])
            {
                
            }
            else if([keyDirective isEqualToString:@"registerAccelerometer"])
            {
                
            }
#endif
            
        }
        
        else{
            [[ConsoleManager sharedManager] log:@"received wrong message"];
            [webSocket send:@"{\"m\":\"error\",\"type\":\"missing MESSAGE\"}"];
            return;
        }
        /* proceed with results as you like; the assignment to
         an explicit NSDictionary * is artificial step to get
         compile-time checking from here on down (and better autocompletion
         when editing). You could have just made object an NSDictionary *
         in the first place but stylistically you might prefer to keep
         the question of type open until it's confirmed */
    }
    else
    {
        /* there's no guarantee that the outermost object in a JSON
         packet will be a dictionary; if we get here then it wasn't,
         so 'object' shouldn't be treated as an NSDictionary; probably
         you need to report a suitable error condition */
    }
    
}
- (void)server:(PSWebSocketServer *)server webSocketDidOpen:(PSWebSocket *)webSocket {
   if(![_sockets containsObject:webSocket])
   {
       [_sockets addObject:webSocket];
   }
    [[ConsoleManager sharedManager] log:[NSString stringWithFormat:@"socket open"]];
    
}
- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
     NSLog(@"Server websocket did close with code: %@, reason: %@, wasClean: %@", @(code), reason, @(wasClean));
    if([_sockets containsObject:webSocket])
    {
        [_sockets removeObject:webSocket];
        [_sm removeWebSocketFromArrays:webSocket];
    }
    [[ConsoleManager sharedManager] log:[NSString stringWithFormat:@"socket closed"]];
}
- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"Server websocket did fail with error: %@", error);
    if([_sockets containsObject:webSocket])
    {
        [_sockets removeObject:webSocket];
        [_sm removeWebSocketFromArrays:webSocket];
    }
    [[ConsoleManager sharedManager] log:[NSString stringWithFormat:@"socket failed"]];
}
- (void)closeAll{
    for (PSWebSocket* socket in _sockets) {
        [socket closeWithCode:122 reason:@"app closing"];
    }
}
#pragma mark OSC
-(void)updateTouchIP:(NSString*)ip andPort:(int)port{
    _oscTouchIP = ip;
    _oscTouchPORT = port;
}
-(void)updateAttitudeIP:(NSString*)ip andPort:(int)port{
    _oscAttitudeIP = ip;
    _oscAttitudePORT = port;
}
-(void)sendAttitudeMessageToOSC:(OSCMessage*)message{
    if(![_oscAttitudeIP isEqualToString: @""])
    {
        [_oscAttitudeClient sendMessage:message to:[NSString stringWithFormat:@"udp://%@:%d",_oscAttitudeIP,_oscAttitudePORT ]];
    }
}
-(void)sendTouchMessageToOSC:(OSCMessage*)message{
    if(![_oscTouchIP isEqualToString: @""])
    {
        [_oscTouchClient sendMessage:message to:[NSString stringWithFormat:@"udp://%@:%d",_oscTouchIP,_oscTouchPORT ]];
    }
}
@end
