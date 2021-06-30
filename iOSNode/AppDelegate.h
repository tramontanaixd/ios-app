//
//  AppDelegate.h
//  iOSNode
//
//  Created by local on 4/29/16.
//  Copyright © 2016 binaryfutures. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong,nonatomic)NSString *relinkUserId;
@property(nonatomic) BOOL authSuccessful;

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url;
@end

