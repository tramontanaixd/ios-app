//
//  ConsoleManager.m
//
//
//  Created by Pierluigi Dalla Rosa on 3/16/16.
//  AGPL-3.0-only
//

#import "ConsoleManager.h"
#define NUM_STRINGS 3

@implementation ConsoleManager

+ (id)sharedManager {
    
    static ConsoleManager *sharedMyManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    
    _array = [[NSMutableArray alloc] initWithArray:@[@"",@"",@"",@"",@"",@""]];
    return self;
}
-(void)log:(NSString*)string{
    // NSLog(@"DEBUG: %@",string);
    for(int i=((int)[_array count])-2;i>=0;i--)
    {
        [_array replaceObjectAtIndex:i+1 withObject:([_array objectAtIndex:i])];
    }
    [_array replaceObjectAtIndex:0 withObject:[NSString stringWithFormat:@" -> %@",string]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateConsole" object:nil];
}
@end
