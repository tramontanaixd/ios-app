//
//  ViewController.m
//  iOSNode
//  
//  Created by Pierluigi Dalla Rosa on 4/29/16.
//  AGPL-3.0-only
//

#import "TViewController.h"
#import "ConsoleManager.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import "NetworkManager.h"
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>
#import "OscManager.h"


@interface TViewController ()

@end

@implementation TViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //make sure iPhone doesn't go to sleep
    [[UIApplication sharedApplication]setIdleTimerDisabled:YES];
    
    //change state to INIT
    [self changeState:INIT];
    
    //Initialize media view
    _viewMedia = [[GPMediaView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [_viewMedia setBackgroundColor:[UIColor clearColor]];
    [self.view setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    
    [_touchButton setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [self.view addSubview:_viewMedia];
    _pictureTaking=NO;
    
    
    _am=[[ActuatorManager alloc] init];
    
    //**REGISTER TO INTERFACE EVENT**//
    //** INIT - CONSOLE**//
    [self updateLabelIP];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateConsole) name:@"updateConsole" object:nil];
    
    //** RUNTIME EVENTS **//
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setColor:) name:@"setColor" object:(NetworkManager*)[NetworkManager sharedManager]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transitionColors:) name:@"transitionColors" object:(NetworkManager*)[NetworkManager sharedManager]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showImageWith:) name:@"showImage" object:(NetworkManager*)[NetworkManager sharedManager]];
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideo:) name:@"playVideo" object:(NetworkManager*)[NetworkManager sharedManager]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playAudio:) name:@"playAudio" object:(NetworkManager*)[NetworkManager sharedManager]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(takePicture:) name:@"takePicture" object:(NetworkManager*)[NetworkManager sharedManager]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableMultitouch:) name:@"multitouchEnabled" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disabledMultitouch:) name:@"multitouchDisabled" object:nil];

    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[ConsoleManager sharedManager] log:@"init"];
    });
    
    //self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    //self.restClient.delegate = self;
    
    _multiTouchEnabledForWS = NO;
    [_touchButton setMultipleTouchEnabled:NO];
     _timeOfLastEvent = [NSDate date];
    
    ///  OSC ///
    _maxNumOfFingers = 1;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableTouchToOSC:) name:@"touchToOSC" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disableTouchToOSC:) name:@"stopTouchToOSC" object:nil];
    
    [[OscManager sharedManager] setTouchState:NO];
    _touchesForOSC = [[NSMutableArray alloc] init];
}
-(void)enableMultitouch:(nullable NSNotification*)notification{
    if(!_touchButton.isMultipleTouchEnabled)
    {
        
        [_touchButton setMultipleTouchEnabled:YES];
    }
    _multiTouchEnabledForWS = YES;
}
-(void)disabledMultitouch:(nullable NSNotification*)notification{

    if(_touchButton.isMultipleTouchEnabled && !_multiTouchEnabledForOSC)
    {
         [_touchButton setMultipleTouchEnabled:NO];
    }
    _multiTouchEnabledForWS = NO;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark INIT
-(IBAction)startButtonPressed:(id)sender
{
    [NetworkManager sharedManager];
    
    [_viewConsole setFrame:CGRectMake(0, _viewConsole.frame.origin.y, _viewConsole.frame.size.width, _viewConsole.frame.size.height)];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_buttonStart setHidden:YES];
        [self.view bringSubviewToFront:_buttonStart];
        [[ConsoleManager sharedManager] log:@"init"];
    });
    
}
-(IBAction)closeButtonPressed:(id)sender{
    if(sender!=nil)
    {
        [NetworkManager sharedManager];
#if false
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"" message:@"The setting view it's visible just when you open the app." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];


        [av show];
#endif
    }
    if(_currentState==INIT)
    {
        [self changeState:RUNNING];
        [UIView animateWithDuration:0.6 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            [_viewInit setAlpha:0.0];
            
        } completion:^(BOOL finished){
            [_viewInit removeFromSuperview];
        }];
    }
}
#pragma mark INTERFACE
-(void)updateLabelIP{
    [_labelIPAddress setText:[self getIPAddress]];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(_currentState==INIT)
        {
            [self updateLabelIP];
        }
    });
}
-(IBAction)presentViewWekinator:(id)sender{
    if(![_viewWekinator isVisible])
    {
        _viewWekinator.alpha = 0.0;
        [self.view addSubview:_viewWekinator];
        [UIView animateWithDuration:0.3
                              delay: 0.0
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             
                             _viewWekinator.alpha = 1.0;
                         }
                         completion:^(BOOL finished){
                             
                             
                             // Wait one second and then fade in the view
                         }];
        
    }
}
#pragma mark OSC
-(void)enableTouchToOSC:(NSNotification*)notification{
    _maxNumOfFingers = [[notification.userInfo objectForKey:@"num"] intValue];
    
    //CLAMP
    if(_maxNumOfFingers<1)
    {
        _maxNumOfFingers=1;
            }
    else if(_maxNumOfFingers>10)
    {
        _maxNumOfFingers = 10;
        
    }
    
    ///CHECK IF MULTITOUCH
    if(_maxNumOfFingers<=1)
    {
        _multiTouchEnabledForOSC = NO;

    }
    else{
        _multiTouchEnabledForOSC = YES;
        if(!_touchButton.isMultipleTouchEnabled)
        {
            [_touchButton setMultipleTouchEnabled:YES];
        }
    }
    //_isTouchToOSCActive = YES;
    [[OscManager sharedManager] setTouchState:YES];

    [_touchButton startOSCTransmissionWithNumberOfFingers:_maxNumOfFingers];
}

-(void)disableTouchToOSC:(NSNotification*)notification{
//    _isTouchToOSCActive = NO;
     [[OscManager sharedManager] setTouchState:NO];
    [_touchButton stopOSCTransmission];
    _multiTouchEnabledForOSC = NO;
    
}
#pragma mark UTILS
// Get IP Address
- (NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
}
-(void)updateConsole{
    for (int i=0; i<[_labelsConsole count]; i++) {
        [((UILabel*)[_labelsConsole objectAtIndex:i]) setText:[[[ConsoleManager sharedManager] array] objectAtIndex: i ]];
    }
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}
#pragma mark STATE MACHINE
-(void)changeState:(int)newState{
    switch (newState) {
        case RUNNING:
            
            break;
            
        default:
            break;
    }
    
    _currentState=newState;
    
}
#pragma mark INTERFACE EVENTS
-(void)setColor:(NSNotification *)notification
{
    [self closeButtonPressed:nil];
    [_viewMedia resetView];
    
    [self.view.layer removeAllAnimations];
    UIColor* color = [notification.userInfo valueForKey:@"color"];
   
    float alpha = [[notification.userInfo valueForKey:@"alpha"] floatValue];
    [[UIScreen mainScreen] setBrightness: alpha];
    [self.view setBackgroundColor:color];
    
    if(_transitionState==TRANSITION_ACTIVE)
    {
        _transitionState = TRANSITION_STOP;
         _nextColor = [UIColor colorWithCGColor:color.CGColor];
    }
}

-(void)transitionColors:(NSNotification *)notification
{
    [_viewMedia resetView];
     [self closeButtonPressed:nil];
    [self.view.layer removeAllAnimations];
    
    UIColor* color1 = [notification.userInfo valueForKey:@"color1"];
    UIColor* color2 = [notification.userInfo valueForKey:@"color2"];

    float duration  = [[notification.userInfo valueForKey:@"duration"] floatValue];
    [self.view setBackgroundColor:color1];
    
    
    
    
    __block void (^loopingBlock)(void) = ^{
    
        [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            self.view.layer.backgroundColor = color2.CGColor;
           
        } completion:^(BOOL finished){
            if(_transitionState == TRANSITION_STOP)
            {
                self.view.layer.backgroundColor = _nextColor.CGColor;
                return;
            }
            else if(_transitionState == TRANSITION_INACTIVE)
            {
                return;
            }
            
            [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                self.view.layer.backgroundColor = color1.CGColor;
               
            } completion:^(BOOL finished){
                if(_transitionState == TRANSITION_ACTIVE)
                {
                    loopingBlock();
                }
                else if(_transitionState == TRANSITION_STOP)
                {
                    self.view.layer.backgroundColor = _nextColor.CGColor;
                }
            }];
        }];
    };
    
    if(_transitionState==TRANSITION_ACTIVE)
    {
        _transitionState = TRANSITION_RESTART;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if(_transitionState==TRANSITION_RESTART)
            {
                _transitionState=TRANSITION_ACTIVE;
                loopingBlock();
            }
        });
    }
    else
    {
        _transitionState=TRANSITION_ACTIVE;
        loopingBlock();
    }
    
    
   
}
-(IBAction)touched:(nullable id)sender forEvent:(UIEvent*)event{
    
    UIView *button = (UIView *)sender;
    NSArray<UITouch *> *touches = [[event touchesForView:button] allObjects];
    
    if(!_multiTouchEnabledForWS)
    {
        
        UITouch *touch = [[event touchesForView:button] anyObject];
        CGPoint location = [touch locationInView:button];
        
        NSDictionary* userInfo=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:location.x],@"x",[NSNumber numberWithInt:location.y],@"y", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"touched" object:self userInfo:userInfo];
    }
    else
    {
       
        int index = 0;
        NSString * msgTmp = @"[";
        
       
        for(UITouch* singleTouch in touches)
        {
            CGPoint location = [singleTouch locationInView:button];
            msgTmp = [NSString stringWithFormat:@"%@%@{\"x\":\"%d\",\"y\":\"%d\"}",msgTmp,(index==0)?@"":@",",(int)location.x,(int)location.y];
            index ++;
        }
         msgTmp = [NSString stringWithFormat:@"%@]",msgTmp];
        
        
        NSDictionary* userInfo=[NSDictionary dictionaryWithObjectsAndKeys:msgTmp,@"touches", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"touched" object:self userInfo:userInfo];
    }
    _touchesForOSC = [NSMutableArray arrayWithArray:[[event touchesForView: (UIView *)sender] allObjects]];
    BOOL ended = YES;
    
    for(UITouch *st in touches)
    {
         if([st phase] != UITouchPhaseEnded)
         {
            
             ended = NO;
         }
        else
        {
             [_touchesForOSC removeObject:st];
        }
       
    }
    if(ended || [touches count]<=1)
    {
        _touchesForOSC = [[NSMutableArray alloc] init];
    }
    ///NSLog(@"%d",_touchButton.numOfFingers);
    
}
-(IBAction)touchDown:(nullable id)sender forEvent:(UIEvent*)event{
    //NSLog(@"%d",_touchButton.numOfFingers);

    if(!_multiTouchEnabledForWS)
    {
        UIView *button = (UIView *)sender;
        UITouch *touch = [[event touchesForView:button] anyObject];
        CGPoint location = [touch locationInView:button];
        
        NSDictionary* userInfo=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:location.x],@"x",[NSNumber numberWithInt:location.y],@"y", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"touchedDown" object:self userInfo:userInfo];
    }
    else
    {
        UIView *button = (UIView *)sender;
        NSArray<UITouch *> *touches = [[event touchesForView:button] allObjects];
        int index = 0;
        NSString * msgTmp = @"[";
        
        
        for(UITouch* singleTouch in touches)
        {
            CGPoint location = [singleTouch locationInView:button];
            msgTmp = [NSString stringWithFormat:@"%@%@{\"x\":\"%d\",\"y\":\"%d\"}",msgTmp,(index==0)?@"":@",",(int)location.x,(int)location.y];
            index ++;
        }
        msgTmp = [NSString stringWithFormat:@"%@]",msgTmp];
        
        
        NSDictionary* userInfo=[NSDictionary dictionaryWithObjectsAndKeys:msgTmp,@"touches", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"touchedDown" object:self userInfo:userInfo];
        
    }
    
     _touchesForOSC = [[[event touchesForView: (UIView *)sender] allObjects] copy];
    
    
}

-(IBAction)touchDrag:(nullable id)sender forEvent:(UIEvent* _Nullable)event{
    if([[NSDate date] timeIntervalSinceDate:_timeOfLastEvent]>0.05)
    {
        _timeOfLastEvent = [NSDate date];
       
        if(!_multiTouchEnabledForWS)
        {
            UIView *button = (UIView *)sender;
            UITouch *touch = [[event touchesForView:button] anyObject];
            
            CGPoint location = [touch locationInView:button];
            
            NSDictionary* userInfo=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:location.x],@"x",[NSNumber numberWithInt:location.y],@"y", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"touchDrag" object:self userInfo:userInfo];
        }
        else
        {
            UIView *button = (UIView *)sender;
            NSArray<UITouch *> *touches = [[event touchesForView:button] allObjects];
            int index = 0;
            NSString * msgTmp = @"[";
            
            
            for(UITouch* singleTouch in touches)
            {
                CGPoint location = [singleTouch locationInView:button];
                msgTmp = [NSString stringWithFormat:@"%@%@{\"x\":\"%d\",\"y\":\"%d\"}",msgTmp,(index==0)?@"":@",",(int)location.x,(int)location.y];
                index ++;
            }
            msgTmp = [NSString stringWithFormat:@"%@]",msgTmp];
            
            
            NSDictionary* userInfo=[NSDictionary dictionaryWithObjectsAndKeys:msgTmp,@"touches", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"touchDrag" object:self userInfo:userInfo];
     
        }
    }
}


-(void)showImageWith:(NSNotification*)notification{
    [_viewMedia resetView];
     [self closeButtonPressed:nil];
    NSString* url = [notification.userInfo valueForKey:@"url"];
    [_viewMedia setImageFromURL:url showActivityIndicator:NO setCacheImage:YES];
    
}
-(void)playAudio:(NSNotification*)notification{
    
    NSString* url = [notification.userInfo valueForKey:@"url"];
    int numOfLoops = [[notification.userInfo valueForKey:@"l"] intValue];
    [_viewMedia playAudio:url andNumLoops:numOfLoops];
}
-(void)playVideo:(NSNotification*)notification{
     [self closeButtonPressed:nil];
    _lastURL = [notification.userInfo valueForKey:@"url"];
    _websocketMedia = [notification.userInfo valueForKey:@"socket"];
    [_viewMedia playVideo:_lastURL and:([[notification.userInfo valueForKey:@"loop"] isEqualToString:@"YES"])?YES:NO ];
}
-(void)itemDidFinishPlaying:(NSNotification*)notification{
    if(_viewMedia.isLooping)
    {
        //[_viewMedia playVideo:_lastURL and:YES];
        [_viewMedia replayVideo];
    }
    else
    {
        [_websocketMedia send:[NSString stringWithFormat:@"{\"m\":\"videoEnded\"}"]];
    }
}

#pragma mark TAKE PICTURE
-(void)takePicture:(NSNotification*)notification{
    if(_pictureTaking)
    {
        return;
    }
    BOOL pickerUI=[@"ui" isEqualToString:[notification.userInfo valueForKey:@"i"]];
    int cameraId=[[notification.userInfo valueForKey:@"c"] intValue];
    if(pickerUI)
    {
        [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    else
    {
    
        _avs = [[AVCaptureSession alloc] init];
        _pictureTaking=YES;
        
       if([_avs isRunning])
       {
           return;
       }
        _avs.sessionPreset = AVCaptureSessionPresetPhoto;
        
        
        AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer    alloc] initWithSession:_avs];
        [self.view.layer addSublayer:captureVideoPreviewLayer];
        
        NSError *error = nil;
        AVCaptureDevice *device = [self selectCamera:cameraId];
        [device lockForConfiguration:nil];
        [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        [device unlockForConfiguration];
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
       // device.
        if (!input) {
            // Handle the error appropriately.
            NSLog(@"ERROR: trying to open camera: %@", error);
        }
        [_avs addInput:input];
        
        self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
        [self.stillImageOutput setOutputSettings:outputSettings];
        
        [_avs addOutput:self.stillImageOutput];
        @try {
             [_avs startRunning];
        } @catch (NSException *exception) {
            NSLog(@"error in starting session:\n%@",exception);
            return;
        } @finally {
           
        }
       
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            @try {
                [self captureNow];
            } @catch (NSException *exception) {
                NSLog(@"error in capture:\n%@",exception);
                return;
            } @finally {
                
            }
            
        
        
        });
    }
    
    
}

/////////////////////////////////////////////////
////
//// Utility to find front camera
////
/////////////////////////////////////////////////
-(AVCaptureDevice *) selectCamera:(int)camera{
    
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *captureDevice = nil;
    
    camera=(camera==0)?AVCaptureDevicePositionBack:AVCaptureDevicePositionFront;
    
    for (AVCaptureDevice *device in videoDevices){
        
        if (device.position == camera){
            
            captureDevice = device;
            break;
        }
    }
    
    //  couldn't find one on the front, so just get the default video device.
    if (!captureDevice){
        
        captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    
    return captureDevice;
}
/////////////////////////////////////////////////
////
//// UIPickerController
//// 
////
/////////////////////////////////////////////////
- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    imagePickerController.modalPresentationStyle =
    (sourceType == UIImagePickerControllerSourceTypeCamera) ? UIModalPresentationFullScreen : UIModalPresentationPopover;
    
    if (sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        imagePickerController.showsCameraControls = YES;
    }
    
    _imagePickerController = imagePickerController; // we need this for later
    
    [self presentViewController:self.imagePickerController animated:YES completion:^{
        
    }];
}
/////////////////////////////////////////////////
////
//// UIIMagePickerController delegate methods
////
////
/////////////////////////////////////////////////
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<NSString *,
                               id> *)info
{
    [self uploadImageToDB:(UIImage*)[info valueForKey:@"UIImagePickerControllerOriginalImage"] ];
    [picker dismissModalViewControllerAnimated:YES];
    
}
/////////////////////////////////////////////////
////
//// Method to capture Still Image from
//// Video Preview Layer
////
/////////////////////////////////////////////////
-(void) captureNow {
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.stillImageOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    
    NSLog(@"about to request a capture from: %@", self.stillImageOutput);
    __weak typeof(self) weakSelf = self;
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
        UIImage *image = [[UIImage alloc] initWithData:imageData];
        [self uploadImageToDB:image];
        [_avs stopRunning];
        _avs=nil;
        _pictureTaking=NO;
    }];
}
-(void)uploadImageToDB:(UIImage*)image
{
    DBUserClient *client = [DBClientsManager authorizedClient];
    if(client!=NULL)
    {
        //PREVIOUS MODE - PREPARE TO UPLOAD
        image=[self imageWithImage:image scaledToSize:CGSizeMake(image.size.width/4,image.size.height/4)];
        
        //UPLOAD to drobox
        NSDate *date = [NSDate date];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitSecond) fromDate:date];
        
        NSString *fileName = [NSString stringWithFormat:@"%d_%d__%d_%d_%d.jpg",(int)[components day],(int)[components month],(int)[components hour],(int)[components minute],(int)[components second]];
        //NSString *tempDir = NSTemporaryDirectory();
        //NSString *imagePath = [tempDir stringByAppendingPathComponent:fileName];
        
        //[UIImagePNGRepresentation(image) writeToFile:imagePath atomically:YES];
        
        //UNTIL HERE
        
        //NSData *fileData = [@"file data example" dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
        
        // For overriding on upload
        DBFILESWriteMode *mode = [[DBFILESWriteMode alloc] initWithOverwrite];
        
        
        [[[client.filesRoutes uploadData:[NSString stringWithFormat:@"/%@",fileName]
                                    mode:mode
                              autorename:@(YES)
                          clientModified:nil
                                    mute:@(NO)
                               inputData:UIImagePNGRepresentation(image)]
          setResponseBlock:^(DBFILESFileMetadata *result, DBFILESUploadError *routeError, DBRequestError *networkError) {
              if (result) {
                  NSLog(@"%@\n", result);
              } else {
                  NSLog(@"%@\n%@\n", routeError, networkError);
              }
          }] setProgressBlock:^(int64_t bytesUploaded, int64_t totalBytesUploaded, int64_t totalBytesExpectedToUploaded) {
              //NSLog(@"\n%lld\n%lld\n%lld\n", bytesUploaded, totalBytesUploaded, totalBytesExpectedToUploaded);
          }];
    }
    /*if (![[DBSession sharedSession] isLinked]) {
        NSLog(@"DB not linked");
        return;
    }
    image=[self imageWithImage:image scaledToSize:CGSizeMake(image.size.width/3,image.size.height/3)];
    
    //UPLOAD to drobox
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitSecond) fromDate:date];
    
    NSString *fileName = [NSString stringWithFormat:@"%d_%d__%d_%d_%d.jpg",(int)[components day],(int)[components month],(int)[components hour],(int)[components minute],(int)[components second]];
    NSString *tempDir = NSTemporaryDirectory();
    NSString *imagePath = [tempDir stringByAppendingPathComponent:fileName];
    
    [UIImagePNGRepresentation(image) writeToFile:imagePath atomically:YES];
    if(_restClient == nil){
        _restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        [_restClient setDelegate:self];
    }
    [_restClient uploadFile:fileName toPath:@"/" withParentRev:nil fromPath:imagePath];*/
}


#pragma mark DB Delegate

//- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath
//              from:(NSString *)srcPath metadata:(DBMetadata *)metadata {
//    NSLog(@"File uploaded successfully to path: %@", metadata.path);
//}
//
//- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {
//    NSLog(@"File upload failed with error: %@", error);
//}
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
@end

@implementation UILabel (Border)

- (void)addTopBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth {
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    
    border.frame = CGRectMake(0, 0, self.frame.size.width, borderWidth);
    [self.layer addSublayer:border];
}

- (void)addBottomBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth {
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    
    border.frame = CGRectMake(0, self.frame.size.height - borderWidth, self.frame.size.width, borderWidth);
    [self.layer addSublayer:border];
}

- (void)addLeftBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth {
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    
    border.frame = CGRectMake(0, 0, borderWidth, self.frame.size.height);
    [self.layer addSublayer:border];
}

- (void)addRightBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth {
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    
    border.frame = CGRectMake(self.frame.size.width - borderWidth, 0, borderWidth, self.frame.size.height);
    [self.layer addSublayer:border];
}


@end

