//
//  AppDelegate.h
//  iOSNode
//  
//  Created by Pierluigi Dalla Rosa on 4/29/16.
//  AGPL-3.0-only
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong,nonatomic)NSString *relinkUserId;
@property(nonatomic) BOOL authSuccessful;

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url;
@end

