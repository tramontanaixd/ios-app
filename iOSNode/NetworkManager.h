//
//  NetworkManager.h
//  serverConnector2
//
//  Created by Pierluigi Dalla Rosa on 3/16/16.
//  AGPL-3.0-only
//

#import <Foundation/Foundation.h>
#import <PSWebSocketServer.h>
#if TARGET_OS_IOS
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>
#import "SensorManager.h"

//OSC KIT
#import <OSCKit/OSCKit.h>

#elif TARGET_OS_TV
// tvOS-specific code
#endif

#import "utilsBF.h"

@interface NetworkManager : NSObject<PSWebSocketServerDelegate>

@property (nonatomic, strong) PSWebSocketServer     *server;


#if TARGET_OS_IOS
@property (strong,nonatomic) SensorManager*         sm;


#elif TARGET_OS_TV
#endif

@property (strong,nonatomic) NSMutableArray*       __block sockets;

-(void)closeAll;
-(void)pingClients;

+(nonnull id)sharedManager;

// ** OSC **//
@property (assign)int oscAttitudePORT;
@property (assign)int oscTouchPORT;

@property (strong,nonatomic)NSString* oscTouchIP;
@property (strong,nonatomic)NSString* oscAttitudeIP;

@property (nonatomic, strong) OSCClient *oscTouchClient;
@property (nonatomic, strong) OSCClient *oscAttitudeClient;

-(void)sendAttitudeMessageToOSC:(OSCMessage*)message;
-(void)sendTouchMessageToOSC:(OSCMessage*)message;
-(void)updateTouchIP:(NSString*)ip andPort:(int)port;
-(void)updateAttitudeIP:(NSString*)ip andPort:(int)port;
@end
