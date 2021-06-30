//
//  AppDelegate.m
//  iOSNode
//
//  Created by local on 4/29/16.
//  Copyright © 2016 binaryfutures. All rights reserved.
//

#import "AppDelegate.h"
#import "NetworkManager.h"
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>

@interface AppDelegate () /*<DBSessionDelegate, DBNetworkRequestDelegate>*/

@end


@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSString* appKey = @"wrk6twir2zpoicd";
   // NSString* appSecret = @"m4gwu6exdb91ps8";
    NSString *registeredUrlToHandle = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"][0][@"CFBundleURLSchemes"][0];
    if (!appKey || [registeredUrlToHandle containsString:@"<"]) {
       NSLog(@"no app key for dropbox");
    }
    [DBClientsManager setupWithAppKey:appKey];
    
    
    
    /*// Set these variables before launching the app
    NSString* appKey = @"wrk6twir2zpoicd";
    NSString* appSecret = @"m4gwu6exdb91ps8";
    NSString *root = kDBRootAppFolder; // Should be set to either kDBRootAppFolder or kDBRootDropbox
    // You can determine if you have App folder access or Full Dropbox along with your consumer key/secret
    // from https://dropbox.com/developers/apps
    
    // Look below where the DBSession is created to understand how to use DBSession in your app
    
    NSString* errorMsg = nil;
    if ([appKey rangeOfCharacterFromSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]].location != NSNotFound) {
        errorMsg = @"Make sure you set the app key correctly in DBRouletteAppDelegate.m";
    } else if ([appSecret rangeOfCharacterFromSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]].location != NSNotFound) {
        errorMsg = @"Make sure you set the app secret correctly in DBRouletteAppDelegate.m";
    } else if ([root length] == 0) {
        errorMsg = @"Set your root to use either App Folder of full Dropbox";
    } else {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
        NSData *plistData = [NSData dataWithContentsOfFile:plistPath];
        NSDictionary *loadedPlist =
        [NSPropertyListSerialization
         propertyListFromData:plistData mutabilityOption:0 format:NULL errorDescription:NULL];
        NSString *scheme = [[[[loadedPlist objectForKey:@"CFBundleURLTypes"] objectAtIndex:0] objectForKey:@"CFBundleURLSchemes"] objectAtIndex:0];
        if ([scheme isEqual:@"db-APP_KEY"]) {
            errorMsg = @"Set your URL scheme correctly in DBRoulette-Info.plist";
        }
    }
    
//    DBSession* session =
//    [[DBSession alloc] initWithAppKey:appKey appSecret:appSecret root:root];
//    session.delegate = self; // DBSessionDelegate methods allow you to handle re-authenticating
//    [DBSession setSharedSession:session];
//    
//    
//    [DBRequest setNetworkRequestDelegate:self];
    
    if (errorMsg != nil) {
        [[[UIAlertView alloc]
           initWithTitle:@"Error Configuring Session" message:errorMsg
           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
          
         show];
    }
    
   
//    if ([[DBSession sharedSession] isLinked]) {
//      
//      }
    
    // Add the navigation controller's view to the window and display.
  
    
    NSURL *launchURL = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
    NSInteger majorVersion =
    [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] integerValue];
    if (launchURL && majorVersion < 4) {
        // Pre-iOS 4.0 won't call application:handleOpenURL; this code is only needed if you support
        // iOS versions 3.2 or below
        [self application:application handleOpenURL:launchURL];
        return NO;
    }*/
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[NetworkManager sharedManager] closeAll];
}
//- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
//   
//    return [self handleResponseWithUrl:url];
//}
- (BOOL)application:(UIApplication *)application openURL:(nonnull NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(nonnull id)annotation {
    
    DBOAuthResult *authResult = [DBClientsManager handleRedirectURL:url];
    NSLog(@"got back from dropbox");
    if (authResult != nil) {
        if ([authResult isSuccess]) {
            NSLog(@"Success! User is logged into Dropbox.");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DBLink" object:nil];
            return YES;
        } else if ([authResult isCancel]) {
            NSLog(@"Authorization flow was manually canceled by user!");
        } else if ([authResult isError]) {
            NSLog(@"Error: %@", authResult);
        }
    }
    
    return NO;
}
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return NO;
}

//-(BOOL)handleResponseWithUrl:(NSURL*)url{
//    
//    NSLog(@"here");
//    if ([[DBSession sharedSession] handleOpenURL:url]) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"DBLink" object:nil];
//        if ([[DBSession sharedSession] isLinked]) {
//            
//        }
//        return YES;
//    }
//    return NO;
//}


#pragma mark DBSessionDelegate methods
//
//- (void)sessionDidReceiveAuthorizationFailure:(DBSession*)session userId:(NSString *)userId {
//    _relinkUserId = userId ;
//    [[[UIAlertView alloc]
//       initWithTitle:@"Dropbox Session Ended" message:@"Do you want to relink?" delegate:self
//       cancelButtonTitle:@"Cancel" otherButtonTitles:@"Relink", nil]
//      
//     show];
//}
#pragma mark DBNetworkRequestDelegate methods

static int outstandingRequests;

- (void)networkRequestStarted {
    outstandingRequests++;
    if (outstandingRequests == 1) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
}

- (void)networkRequestStopped {
    outstandingRequests--;
    if (outstandingRequests == 0) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}

@end
