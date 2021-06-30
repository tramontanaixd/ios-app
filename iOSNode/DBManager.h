//
//  DBManager.h
//  iOSNode
//
//  Created by local on 6/24/16.
//  Copyright © 2016 binaryfutures. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>

@interface DBManager : UIView

@property (strong,nonatomic)IBOutlet UIButton* linkButton;
@property (strong,nonatomic)IBOutlet UIViewController* controller;

- (IBAction)didPressLink;
@end
