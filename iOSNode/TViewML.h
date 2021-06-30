//
//  TViewML.h
//  iOSNode
//
//  Created by Pierluigi Dalla Rosa on 9/21/17.
//  Copyright © 2017 binaryfutures. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SaveAndLoadTextField.h"

@interface TViewML : UIView <UITextFieldDelegate>

@property (strong,nonatomic) IBOutlet SaveAndLoadTextField* attitudeIp;
@property (strong,nonatomic) IBOutlet SaveAndLoadTextField* attitudePort;
@property (strong,nonatomic) IBOutlet SaveAndLoadTextField* attitudeFrequency;

@property (strong,nonatomic) IBOutlet SaveAndLoadTextField* touchIp;
@property (strong,nonatomic) IBOutlet SaveAndLoadTextField* touchPort;
@property (strong,nonatomic) IBOutlet SaveAndLoadTextField* touchFingerNum;

@property (strong,nonatomic) IBOutlet UIButton* attitudeButton;
@property (strong,nonatomic) IBOutlet UIButton* touchButton;


@property (assign) int  keyboardHeight;
@property (assign) int  originalYPosition;
@property (assign) int  textFieldYPos;
@property (assign) int  textFieldHeight;
@property (assign) BOOL isKeyboardOut;

@property (assign) BOOL isVisible;

-(IBAction)attitudeButtonTriggered:(id)sender;
-(IBAction)touchButtonTriggered:(id)sender;

-(void)changeAttitudeState:(BOOL)newAttitudeState andTouch:(BOOL)newTouchState;

-(void)updateLabelsAttitudeWithNotification:(NSNotification*)notification;
-(void)updateLabelTouchWithNotification:(NSNotification*)notification;

-(IBAction)dismissView:(id)sender;

@end
