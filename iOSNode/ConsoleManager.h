#import <Foundation/Foundation.h>

#if TARGET_OS_MAC

#endif

#if TARGET_OS_IOS || TARGET_OS_TVOS
    #import <UIKit/UIKit.h>
#else
    #import <AppKit/AppKit.h>
#endif

#import "utilsBF.h"

@interface ConsoleManager : NSObject

@property (strong,nonatomic)NSMutableArray* array;

+(id)sharedManager;
-(void)log:(NSString*)string;

@end
