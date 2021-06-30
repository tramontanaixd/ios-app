//
//  GPMediaView.m
//
//  Created by Gaurav D. Sharma & Piyush Kashyap
//  Modified by Pierluigi Dalla Rosa @binaryfutures
//
//

#import "GPMediaView.h"

#ifdef TARGET_OS_IOS || TARGET_OS_MAC
    #define TMP [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#elif TARGET_OS_TV
    #define TMP  [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]
#endif

@implementation GPMediaView
{
    
    NSMutableData* mediaData;
    int mediaType;
    int status;
    bool videoIsPlaying;
    
}
@synthesize isCacheImage, showActivityIndicator;

@synthesize defaultImage, videoPlayer;


+ (NSString*)getUniquePath:(NSString*)  urlStr
{
    NSMutableString *tempImgUrlStr=[NSMutableString stringWithString:urlStr];
    BOOL localResource = YES;
    
    if([urlStr rangeOfString:@"http"].location != NSNotFound || [urlStr rangeOfString:@"www"].location != NSNotFound)
    {
        tempImgUrlStr = [NSMutableString stringWithString:[urlStr substringFromIndex:7]];
    
        localResource=NO;
    }
    [tempImgUrlStr replaceOccurrencesOfString:@"/" withString:@"-" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tempImgUrlStr length])];
    
    
    
    // Generate a unique path to a resource representing the image you want
    NSString *filename = [NSString stringWithFormat:@"%@",tempImgUrlStr] ;
    
    // [[something unique, perhaps the image name]];
    NSString *uniquePath = [TMP stringByAppendingPathComponent: filename];
    
    return uniquePath;
}

#if TARGET_OS_OSX
    - (void)drawRect:(NSRect)dirtyRect {
        [_backgroundColor setFill];
        NSRectFill(dirtyRect);
        [super drawRect:dirtyRect];
        
        
        // Drawing code here.
    }
#endif
#pragma mark IMAGE
- (void)setImageFromURL:(NSString*)url
{
    [self setImageFromURL:url
    showActivityIndicator:showActivityIndicator
            setCacheImage:isCacheImage];
}


- (void)setImageFromURL:(NSString*)url
  showActivityIndicator:(BOOL)isActivityIndicator
          setCacheImage:(BOOL)cacheImage
{
    
    _mediaURL = [GPMediaView getUniquePath:url];
    
    showActivityIndicator = isActivityIndicator;
    
    isCacheImage = cacheImage;
    
    if (isCacheImage && [[NSFileManager defaultManager] fileExistsAtPath:_mediaURL])
    {
        /* --- Set Cached Image --- */
        mediaData = [[NSMutableData alloc] initWithContentsOfFile:_mediaURL];
        #if TARGET_OS_OSX
        [self setImage:[[NSImage alloc] initWithData:mediaData]];
        #else
        
        [self setImage:[[UIImage alloc] initWithData:mediaData]];
        #endif
    }
    /* --- Download Image from URL --- */
    else
    {
        if (showActivityIndicator) {
            
            /*UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            
            activityIndicator.tag = 786;
            
            [activityIndicator startAnimating];
            
            [activityIndicator setHidesWhenStopped:YES];
            
            CGRect myRect = self.frame;
            
            CGRect newRect = CGRectMake(myRect.size.width/2 -12.5f,myRect.size.height/2 - 12.5f, 25, 25);
            
            [activityIndicator setFrame:newRect];
            
            [self addSubview:activityIndicator];*/
            
        }
        
        /* --- set Default image Until Image will not load --- */
        if (defaultImage) {
            [self setImage:defaultImage];
        }
        
        /* --- Switch to main thread If not in main thread URLConnection wont work --- */
        [self downloadMediaWithUrl:url andMediaType:IMAGE];
    }
    
}
#pragma mark VIDEO

-(void)playVideo:(NSString*)url and:(BOOL)loop{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setVolume:) name:@"setVolume" object:nil];
    
    if(videoPlayer!=nil)
    {
        [videoPlayer pause];
        videoIsPlaying = false;
    }
     _isLooping = loop;
    if(url!=nil)
    {
        _mediaURL = [GPMediaView getUniquePath:url];
        
    }
    else
    {
        _mediaURL = [GPMediaView getUniquePath:_mediaURL];
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:_mediaURL])
    {
        /* --- Set Cached Video --- */
        NSURL* tmpUrl = [NSURL fileURLWithPath:_mediaURL];
        if(videoPlayer==nil)
        {
            videoPlayer = [[AVPlayer alloc] initWithURL:tmpUrl];
            _videoLayer = [AVPlayerLayer playerLayerWithPlayer:videoPlayer];
            videoPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
            
            #if TARGET_OS_OSX
            _videoLayer.frame = CGRectMake(0, 0, [NSScreen mainScreen].frame.size.width, [NSScreen mainScreen].frame.size.height);
            #else
            _videoLayer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
            
            #endif
//            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        }
        else
        {
            [videoPlayer cancelPendingPrerolls];
            AVPlayerItem* itemTmp = [[AVPlayerItem alloc] initWithURL:tmpUrl];
            [videoPlayer replaceCurrentItemWithPlayerItem:itemTmp];
        }
        
        if(![self.layer.sublayers containsObject:_videoLayer])
        {
            [self.layer addSublayer: _videoLayer];
        }
        [videoPlayer play];
         videoIsPlaying = true;
       
    }
    /* --- Download Image from URL --- */
    else
    {
        /* --- Switch to main thread If not in main thread URLConnection wont work --- */
        [self downloadMediaWithUrl:url andMediaType:VIDEO];
    }
}
-(void)replayVideo{
    if(videoPlayer!=nil)
    {
        [videoPlayer seekToTime:kCMTimeZero];
        [videoPlayer play];
         videoIsPlaying = true;
    }
}

#pragma mark AUDIO
-(void)playAudio:(NSString*)url andNumLoops:(int)num{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setVolume:) name:@"setVolume" object:nil];
    if(_audioPlayer!=nil)
    {
        [_audioPlayer stop];
    }
    if(url!=nil)
    {
        _mediaURL = [GPMediaView getUniquePath:url];
    }
    else
    {
        _mediaURL = [GPMediaView getUniquePath:_mediaURL];
    }
    if(num!=INFINITY)
    {
       _numOfLoops=num;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:_mediaURL])
    {
        /* --- Set Cached Video --- */
        NSURL* tmpUrl = [NSURL fileURLWithPath:_mediaURL];
        if(_audioPlayer==nil)
        {
            _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:tmpUrl
                                                                           error:nil];
        }
            _audioPlayer.numberOfLoops = (num==INFINITY)?_numOfLoops:num; //-1 Continued loop
        
            [_audioPlayer play];

        
        
    }
    /* --- Download Image from URL --- */
    else
    {
        /* --- Switch to main thread If not in main thread URLConnection wont work --- */
        [self downloadMediaWithUrl:url andMediaType:AUDIO];
        
    }
    
        }
-(void)setVolume:(NSNotification*)notification{
    float volume = [[notification.userInfo valueForKey:@"v"] floatValue];
    if(volume <= 1.0 && volume >= 0)
    {
        if(_audioPlayer != nil)
        {
            if(_audioPlayer.isPlaying)
            {
                _audioPlayer.volume = volume;
            }
        }
        if(videoPlayer != nil)
        {
            if(videoIsPlaying)
            {
                videoPlayer.volume = volume;
            }
        }
    }
}
#pragma mark GENERAL
-(void)downloadMediaWithUrl:(NSString*)url andMediaType:(int)type
{
    if(status==DOWNLOADING)
    {
        return;
    }
    mediaType = type;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        _mediaURL = url;
        
        NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
        
        NSURLConnection *con = [[NSURLConnection alloc] initWithRequest:req
                                                               delegate:self
                                                       startImmediately:NO];
        
        [con scheduleInRunLoop:[NSRunLoop currentRunLoop]
                       forMode:NSRunLoopCommonModes];
        
        [con start];
        status = DOWNLOADING;
        if (con) {
            mediaData = [NSMutableData new];
        }
        else {
            NSLog(@"GPImageView Image Connection is NULL");
        }
    });
}

#pragma mark - NSURLConnection delegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [mediaData setLength:0];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [mediaData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    NSLog(@"Error downloading");
    
    mediaData = nil;
    status = IDLE;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    /* --- hide activity indicator --- */
    if (showActivityIndicator)
    {
        #ifndef TARGET_OS_MAC
        UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView*)[self viewWithTag:786];
        
        [activityIndicator stopAnimating];
        
        [activityIndicator removeFromSuperview];
        #endif
    }
    switch (mediaType) {
        case IMAGE:
            /* --- set Image Data --- */
            #if TARGET_OS_OSX
                [self setImage:[[NSImage alloc] initWithData:mediaData]];
            #else
                [ self setImage:[UIImage imageWithData:mediaData]];
            
            #endif
            /* --- Get Cache Image --- */
            if (isCacheImage) {
                NSLog(@"%@",[GPMediaView getUniquePath:_mediaURL]);
                [mediaData writeToFile:[GPMediaView getUniquePath:_mediaURL]
                            atomically:YES];
            }

            break;
        case VIDEO:
            [mediaData writeToFile:[GPMediaView getUniquePath:_mediaURL]
                        atomically:YES];
            [self playVideo:nil and:_isLooping];
            break;
        case AUDIO:
            [mediaData writeToFile:[GPMediaView getUniquePath:_mediaURL]
                        atomically:YES];
            [self playAudio:nil andNumLoops:INFINITY];
            break;
        default:
            break;
    }
    status = IDLE;
    mediaData = nil;
    
}
#pragma mark RESET
-(void)resetView{
    self.image = nil;
    #if TARGET_OS_OSX
    _backgroundColor = [NSColor clearColor];
    #endif
    
    [videoPlayer pause];
    [_videoLayer removeFromSuperlayer];
    
    [self setNeedsDisplay];
   
}

@end
