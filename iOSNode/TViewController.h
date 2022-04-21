//
//  ViewController.h
//  iOSNode
//  
//  Created by Pierluigi Dalla Rosa on 4/29/16.
//  AGPL-3.0-only
//

#import <UIKit/UIKit.h>
#import "ActuatorManager.h"
#import "SensorManager.h"
#import "utilsBF.h"
#import "GPMediaView.h"
#import <PSWebSocketServer.h>
#import "DBManager.h"
#import "TFullScreenButton.h"
#import "TViewML.h"

#define INIT    0
#define CONSOLE 1
#define RUNNING 2
#define ERROR   3

#define TRANSITION_ACTIVE   1
#define TRANSITION_INACTIVE 2
#define TRANSITION_STOP     3
#define TRANSITION_RESTART  4


@interface TViewController : UIViewController </*DBRestClientDelegate,*/ UIImagePickerControllerDelegate>

@property NSString *temp;

@property (strong,nonatomic)IBOutlet UIView*                        viewInit;
@property (strong,nonatomic)IBOutlet UILabel*                       labelIPAddress;
@property (strong,nonatomic)IBOutlet UIButton*                      buttonStart;
@property (nonatomic,strong)IBOutletCollection(UILabel) NSArray*    labelsConsole;
@property (nonatomic,strong)IBOutlet UIButton*                      buttonClose;
@property (strong,nonatomic)IBOutlet UIView*                        viewConsole;
@property (assign) int                                              currentState;
@property (strong,nonatomic)ActuatorManager*                        am;

@property (strong,nonatomic)GPMediaView*                            viewMedia;
@property (strong,nonatomic)IBOutlet TFullScreenButton*             touchButton;
@property (strong,nonatomic)NSString*                               lastURL;

@property (strong,nonatomic)PSWebSocket*                            websocketMedia;
@property (strong,nonatomic)IBOutlet DBManager*                     dbm;
@property (strong,nonatomic)AVCaptureStillImageOutput*              stillImageOutput;

@property (strong,nonatomic)IBOutlet TViewML*                        viewWekinator;

//@property (nonatomic, strong) DBRestClient *restClient;
@property (assign) BOOL pictureTaking;

@property (assign) BOOL multiTouchEnabledForWS;
@property (assign) BOOL multiTouchEnabledForOSC;

@property (nonatomic,strong) NSDate* timeOfLastEvent;

#if TARGET_OS_IOS
    //** WEBVIEW **//
    @property (strong, nonatomic) IBOutlet UIWebView*                   webView;

#endif


@property(strong,nonatomic) AVCaptureSession *avs;
-(IBAction)startButtonPressed:(_Nullable id)sender;
-(IBAction)closeButtonPressed:(_Nullable id)sender;
-(void)updateLabelIP;




#pragma mark STATEMACHINE
-(void)changeState:(int)newState;

#pragma mark INTERFACE
@property (assign) int transitionState;
@property (nonnull,strong)UIColor* nextColor;

-(void)setColor:(nullable NSNotification*) notification;
-(void)transitionColors:(nullable NSNotification*)notification;
-(void)takePicture:(NSNotification* _Nullable)notification;

//**PICKER CONTROLLER**//
@property (nonatomic) UIImagePickerController *imagePickerController;


//** RUNTIME ACTIONS **//
-(IBAction)touched:(nullable id)sender forEvent:(UIEvent* _Nullable)event;
-(IBAction)touchDown:(nullable id)sender forEvent:(UIEvent* _Nullable)event;
-(IBAction)touchDrag:(nullable id)sender forEvent:(UIEvent* _Nullable)event;
- (UIImage * _Nullable)imageWithImage:(UIImage * _Nullable)image scaledToSize:(CGSize )newSize;
-(void)enableMultitouch:(nullable NSNotification*)notification;
-(void)disabledMultitouch:(nullable NSNotification*)notification;

//** OSC **//
@property(assign)int  maxNumOfFingers;
//@property(assign)BOOL isTouchToOSCActive;
@property(strong,nonatomic) NSMutableArray<UITouch *> *touchesForOSC;

-(void)sendToOSCTouchInformation;
-(void)enableTouchToOSC:(NSNotification*)notification;

//** WEKINATOR VIEW **//
-(IBAction)presentViewWekinator:(id)sender;

@end

