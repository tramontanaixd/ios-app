//
//  TViewML.m
//  iOSNode
//
//  Created by Pierluigi Dalla Rosa on 9/21/17.
//  AGPL-3.0-only
//

#import "TViewML.h"
#import "NetworkManager.h"
#import "OscManager.h"

@implementation TViewML


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)layoutSubviews{
    [super layoutSubviews];
   
    [_attitudeIp setDelegate:self];
    [_attitudePort setDelegate:self];
    [_attitudeFrequency setDelegate:self];
    
    [_touchIp setDelegate:self];
    [_touchPort setDelegate:self];
    [_touchFingerNum setDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLabelTouchWithNotification:) name:@"touchToOSC" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLabelTouchWithNotification:) name:@"stopTouchToOSC" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLabelsAttitudeWithNotification:) name:@"stopAttitudeToOSC" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLabelsAttitudeWithNotification:) name:@"AttitudeToOSC" object:nil];
    
    // init your parameters here, like set up fonts, colors, etc...
    _keyboardHeight = 0;
    
    _isVisible = YES;
    
    self.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width/2)-(self.frame.size.width/2), ([UIScreen mainScreen].bounds.size.height/2)-(self.frame.size.height/2), self.frame.size.width, self.frame.size.height);
     _originalYPosition = self.frame.origin.y;
}


-(void)updateLabelsAttitudeWithNotification:(NSNotification*)notification{
    [_attitudeIp setText:[[NetworkManager sharedManager] oscAttitudeIP]];
    [_attitudePort setText:[NSString stringWithFormat:@"%d",[[NetworkManager sharedManager] oscAttitudePORT] ]];
    if([notification.name isEqualToString:@"AttitudeToOSC"])
    {
        [_attitudeFrequency setText:[NSString stringWithFormat:@"%f", [[[notification userInfo] valueForKey:@"f"] doubleValue] ]];
    }
    if([[OscManager sharedManager] isAttitudeActive])
    {
        [_attitudeButton setTitle:@"Stop Attitude To OSC" forState:UIControlStateNormal];
        [_attitudeIp setUserInteractionEnabled:NO];
        [_attitudePort setUserInteractionEnabled:NO];
        [_attitudeFrequency setUserInteractionEnabled:NO];
        [_attitudeIp setAlpha:0.5];
        [_attitudePort setAlpha:0.5];
        [_attitudeFrequency setAlpha:0.5];
        
    }
    else{
        [_attitudeButton setTitle:@"Broadcast Attitude To OSC" forState:UIControlStateNormal];
        [_attitudeIp setUserInteractionEnabled:YES];
        [_attitudePort setUserInteractionEnabled:YES];
         [_attitudeFrequency setUserInteractionEnabled:YES];
        [_attitudeIp setAlpha:1.0];
        [_attitudePort setAlpha:1.0];
        [_attitudeFrequency setAlpha:1.0];
    }
    
}
-(void)updateLabelTouchWithNotification:(NSNotification*)notification{
    [_touchIp setText:[[NetworkManager sharedManager] oscTouchIP] ];
    [_touchPort setText:[NSString stringWithFormat:@"%d",[[NetworkManager sharedManager] oscTouchPORT] ]];
    
    if([notification.name isEqualToString:@"touchToOSC"])
    {
        [_touchFingerNum setText:[NSString stringWithFormat:@"%d", [[[notification userInfo] valueForKey:@"num"] intValue] ]];
    }
    if([[OscManager sharedManager] isTouchActive])
    {
        [_touchButton setTitle:@"Stop Touch To OSC" forState:UIControlStateNormal];
        [_touchIp setUserInteractionEnabled:NO];
        [_touchPort setUserInteractionEnabled:NO];
        [_touchFingerNum setUserInteractionEnabled:NO];
        
        [_touchIp setAlpha:0.5];
        [_touchPort setAlpha:0.5];
        [_touchFingerNum setAlpha:0.5];
    }
    else
    {
        [_touchButton setTitle:@"Broadcast Touch To OSC" forState:UIControlStateNormal];
        [_touchIp setUserInteractionEnabled:YES];
        [_touchPort setUserInteractionEnabled:YES];
        [_touchFingerNum setUserInteractionEnabled:YES];
        [_touchIp setAlpha:1.0];
        [_touchPort setAlpha:1.0];
        [_touchFingerNum setAlpha:1.0];
    }
}

-(IBAction)attitudeButtonTriggered:(id)sender{
    //BROADCAST ATTITUDE TO OSC
    if([[OscManager sharedManager] isAttitudeActive])
    {
        //stop broadcasting attitude osc
         [[NSNotificationCenter defaultCenter] postNotificationName:@"stopAttitudeToOSC" object:nil ];
    }
    else
    {
        //start broadcasting attitude osc
        [[NetworkManager sharedManager] updateAttitudeIP:[_attitudeIp text] andPort:[[_attitudePort text] intValue]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AttitudeToOSC" object:self userInfo:@{@"f":[_attitudeFrequency text]}];
    }
    [self textFieldShouldReturn:nil];
    
}
-(IBAction)touchButtonTriggered:(id)sender{
    //BROADCAST TOUCH TO OSC
    if([[OscManager sharedManager] isTouchActive])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopTouchToOSC" object:self];
    }
    else
    {
        int numTouchesToOSC = [[_touchFingerNum text] intValue];
        NSDictionary* userInfo=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:numTouchesToOSC],@"num", nil];
        [[NetworkManager sharedManager] updateTouchIP:[_touchIp text] andPort:[[_touchPort text] intValue]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"touchToOSC" object:self userInfo:userInfo];
    }
    //[[OscManager sharedManager] toggleTouchState];
     [self textFieldShouldReturn:nil];
}

//-(void)changeAttitudeState:(BOOL)newAttitudeState{
//    if(newAttitudeState)
//    {
//
//    }
//    else
//    {
//
//    }
//    //_isAttitudeActive = newAttitudeState;
//}
//
//-(void)changeTouchState:(BOOL)newTouchState{
//    if(newTouchState)
//    {
//        [_touchButton setTitle:@"Stop Touch To OSC" forState:UIControlStateNormal];
//    }
//    else{
//
//    }
//   // _isTouchActive = newTouchState;
//}

#pragma mark TEXTFIELD DELEGATE
-(void) keyboardWillShow:(NSNotification *)note{
    
    CGRect keyboardBounds;
    
    if(note!=nil)
    {
        [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
        
        // Need to translate the bounds to account for rotation.
        
        keyboardBounds = [self convertRect:keyboardBounds toView:nil];
        _keyboardHeight= keyboardBounds.size.height;
    }
    else
    {
        if(_keyboardHeight==0)
        {
            NSLog(@"this should never happen");
        }
    }
    _isKeyboardOut = YES;
   // _originalYPosition = self.bounds.origin.y;
    
    [UIView animateWithDuration:0.2
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         int offsetY = 0;
                         if( (_textFieldYPos+_originalYPosition+_textFieldHeight+10)>([[UIScreen mainScreen] bounds].size.height)-_keyboardHeight)
                         {
                            
                             //offsetY = _originalYPosition - _textFieldYPos;
                             offsetY = _originalYPosition  - (((_textFieldYPos+_originalYPosition+_textFieldHeight+10)- ([[UIScreen mainScreen] bounds].size.height -_keyboardHeight)) );
                            
                         }
                         [self setFrame:CGRectMake(self.frame.origin.x, offsetY,self.bounds.size.width,self.bounds.size.height)];
                     }
                     completion:^(BOOL finished){
                         // Wait one second and then fade in the view
                     }];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
   
    _textFieldYPos = textField.frame.origin.y;
    _textFieldHeight = textField.frame.size.height;
    [self keyboardWillShow:nil];
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [_attitudePort resignFirstResponder];
    [_attitudeFrequency resignFirstResponder];
    [_attitudeIp resignFirstResponder];
    
    [_touchIp resignFirstResponder];
    [_touchPort resignFirstResponder];
    [_touchFingerNum resignFirstResponder];
    
    _isKeyboardOut = NO;
    [UIView animateWithDuration:0.2
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         [self setFrame:CGRectMake(self.frame.origin.x, _originalYPosition,self.bounds.size.width,self.bounds.size.height)];
                     }
                     completion:^(BOOL finished){
                         // Wait one second and then fade in the view
                     }];
    return NO;
}
-(IBAction)dismissView:(id)sender{
    [self textFieldShouldReturn:nil];
    [UIView animateWithDuration:0.3
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         self.alpha = 0.0;
                     }
                     completion:^(BOOL finished){
                         [self removeFromSuperview];
                         _isVisible = NO;
                         // Wait one second and then fade in the view
                     }];
    
    
}

@end
