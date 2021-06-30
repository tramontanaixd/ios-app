//
//  TFullScreenButton.h
//  
//
//  Created by Pierluigi Dalla Rosa on 9/8/17.
//
//

#import <UIKit/UIKit.h>

@interface TFullScreenButton : UIButton

@property (assign)int numOfFingers;

@property(assign)int  maxNumOfFingers;
//@property(assign)BOOL isTouchToOSCActive;
@property(strong,nonatomic) NSMutableArray<UITouch *> *touchesForOSC;


-(void)startOSCTransmissionWithNumberOfFingers:(int)numFingers;
-(void)stopOSCTransmission;
-(void)sendToOSCTouchInformation;

@end
