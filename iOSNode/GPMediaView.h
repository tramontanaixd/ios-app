//
//  GPMediaView.h
//
//  Created by Gaurav D. Sharma & Piyush Kashyap
//  Modified by Pierluigi Dalla Rosa @binaryfutures
//
//



#if TARGET_OS_OSX
    #import <Cocoa/Cocoa.h>
    #import <AppKit/AppKit.h>
    #import <Foundation/Foundation.h>
    #import <AppKit/NSTableCellView.h>
#endif

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

#define AUDIO       1
#define VIDEO       2
#define IMAGE       3
#define IDLE        4
#define DOWNLOADING 5

#if TARGET_OS_IOS || TARGET_OS_TV
    #import <UIKit/UIKit.h>
    @interface GPMediaView : UIImageView

#elif TARGET_OS_MAC
    @interface GPMediaView : NSImageView
#endif
@property (nonatomic) BOOL isCacheImage, showActivityIndicator;

#if TARGET_OS_X
    @property (nonatomic, strong) NSImage *defaultImage;
    @property (nonatomic, strong) NSColor *backgroundColor;
#elif TARGET_OS_IOS || TARGET_OS_TV
    @property (nonatomic, strong) UIImage *defaultImage;
#endif
/* --- Img from URL --- */
+ (NSString*)getUniquePath:(NSString*)urlStr;

- (void)setImageFromURL:(NSString*)url;

- (void)setImageFromURL:(NSString*)url
  showActivityIndicator:(BOOL)isActivityIndicator
          setCacheImage:(BOOL)cacheImage;
@property(strong,nonatomic)NSString* mediaURL;


/* --- Vid from URL --- */
@property (nonatomic, strong)   AVPlayer*       videoPlayer;
@property (nonatomic,strong)    AVPlayerLayer*  videoLayer;
-(void)playVideo:(NSString*)url and:(BOOL)loop;
-(void)replayVideo;
@property (assign) BOOL isLooping;


/* --- Audio from URL --- */
-(void)playAudio:(NSString*)url andNumLoops:(int)num;
@property (nonatomic,strong) AVAudioPlayer*     audioPlayer;
@property (assign) int                          numOfLoops;

/* --- Reset --- */
-(void)resetView;


@end
