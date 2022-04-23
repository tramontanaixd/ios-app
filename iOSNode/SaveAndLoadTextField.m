//
//  SaveAndLoadTextField.m
//
//  Created by Pierluigi Dalla Rosa on 4/18/17.
//  Copyright © 2017 pierdr. All rights reserved.
//

#import "SaveAndLoadTextField.h"

@implementation SaveAndLoadTextField
@synthesize name;

-(void)didMoveToSuperview{
    [self setDelegate:self];
    if(name)
    {
        if([[NSUserDefaults standardUserDefaults] objectForKey:name]!=nil)
        {
            [self setText:[[NSUserDefaults standardUserDefaults]valueForKey:name]];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setValue:[self text] forKey:name];
        }
    }
}
- (void)controlTextDidChange:(NSNotification *)aNotification {
    //NSLog(@"text entry, %@",[self stringValue]);
    if(name)
    {
        [[NSUserDefaults standardUserDefaults] setValue:[self text] forKey:name];
    }
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
