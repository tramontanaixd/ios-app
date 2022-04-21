//
//  TFullScreenButton.m
//  
//  AGPL-3.0-only
//  Created by Pierluigi Dalla Rosa on 9/8/17.
//
//

#import "TFullScreenButton.h"
#import "NetworkManager.h"
#import "OscManager.h"
@implementation TFullScreenButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    _numOfFingers = [event.allTouches count];
    
    [_touchesForOSC removeAllObjects];
    for(UITouch* t in event.allTouches)
    {
        [_touchesForOSC addObject:t];
    }
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    _numOfFingers = 0;
    [_touchesForOSC removeAllObjects];
    for(UITouch *touch in event.allTouches)
    {
          if(touch.phase!=UITouchPhaseEnded && touch.phase!=UITouchPhaseCancelled)
          {
            _numOfFingers ++;
            [_touchesForOSC addObject:touch];
          }
    }
   
    
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    
    //_numOfFingers = (int)[touches count];
   // NSLog(@"m%d",[touches count]);
    _numOfFingers = [event.allTouches count];
    
    [_touchesForOSC removeAllObjects];
    for(UITouch* t in event.allTouches)
    {
        [_touchesForOSC addObject:t];
    }
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesCancelled:touches withEvent:event];
    
}
-(void)startOSCTransmissionWithNumberOfFingers:(int)numFingers{
    _touchesForOSC = [[NSMutableArray alloc] init];
    //_isTouchToOSCActive = YES;
    [[OscManager sharedManager] setTouchState:YES];
    _maxNumOfFingers = numFingers;
    [self sendToOSCTouchInformation];
}
-(void)stopOSCTransmission{
    //_isTouchToOSCActive = NO;
    [[OscManager sharedManager] setTouchState:NO];
}

-(void)sendToOSCTouchInformation{
    /* TO FIX */
    ///// **   SEND VIA OSC   ** /////
    //if(_isTouchToOSCActive)
    if([[OscManager sharedManager] isTouchActive])
    {
        //NSLog(@"t %d",[_touchesForOSC count]);
        
        NSMutableArray* arr = [[NSMutableArray alloc] init];
        [arr addObject:[NSNumber numberWithInt:(int)[_touchesForOSC count]]];
        
        for(int i = 0; i<_maxNumOfFingers;i++)
        {
            
            CGPoint location;
            if(i<[_touchesForOSC count])
            {
                UITouch* singleTouch;
                singleTouch  = [_touchesForOSC objectAtIndex:i];
                location = [singleTouch locationInView:self];
                //location = CGPointMake((float)location.x, (float)location.y);
            }
            else
            {
                location = CGPointMake(-1.0, -1.0);
            }
            [arr addObject:[NSNumber numberWithFloat:location.x]];
            [arr addObject:[NSNumber numberWithFloat:location.y]];
        }
        
        OSCMessage *message = [OSCMessage to:@"/wek/inputs" with:[arr copy]];
        
        [[NetworkManager sharedManager] sendTouchMessageToOSC:message];
        
        [self performSelector:@selector(sendToOSCTouchInformation) withObject:nil afterDelay:0.05];
    }
}

@end
