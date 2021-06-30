//
//  DBManager.m
//  iOSNode
//
//  Created by local on 6/24/16.
//  Copyright © 2016 binaryfutures. All rights reserved.
//

#import "DBManager.h"

@implementation DBManager

- (id)initWithCoder:(NSCoder *)decoder
{
    self= [super initWithCoder:decoder];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateButtons) name:@"DBLink" object:nil];
   
    return self;
}
- (void)didMoveToSuperview{
    [self performSelector:@selector(updateButtons) withObject:nil afterDelay:0.5];
}
- (void)updateButtons {
    NSString* title = [[DBClientsManager authorizedClients] count ]>0  ? @"Unlink Dropbox" : @"Link Dropbox";
    [_linkButton setTitle:title forState:UIControlStateNormal];
}

- (IBAction)didPressLink {
//    [DBClientsManager authorizeFromController:[UIApplication sharedApplication]
//                                   controller:self
//                                      openURL:^(NSURL *url) {
//                                          [[UIApplication sharedApplication] openURL:url];
//                                      }];
//
//    NSLog(@"%@",[DBClientsManager authorizedClient]);
//     NSLog(@"%@",[DBClientsManager authorizedTeamClient]);
    if ([DBClientsManager authorizedClient]==NULL && [DBClientsManager authorizedTeamClient]== NULL ) {
        //[[DBSession sharedSession] linkFromController:self.controller];
        [DBClientsManager authorizeFromController:[UIApplication sharedApplication]
                                       controller:self.controller
                                          openURL:^(NSURL *url) {
                                              [[UIApplication sharedApplication] openURL:url];
                                          }];
    } else {
        //[[DBSession sharedSession] unlinkAll];
     [DBClientsManager unlinkAndResetClients];
        [[[UIAlertView alloc]
           initWithTitle:@"Account Unlinked!" message:@"Your dropbox account has been unlinked"
           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
          
         show];
        [self updateButtons];
    }
}

@end
