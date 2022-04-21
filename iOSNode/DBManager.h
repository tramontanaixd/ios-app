//
//  DBManager.h
//  iOSNode
//
//  Created by Pierluigi Dalla Rosa on 6/24/16.
//  AGPL-3.0-only
//

#import <Foundation/Foundation.h>
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>

@interface DBManager : UIView

@property (strong,nonatomic)IBOutlet UIButton* linkButton;
@property (strong,nonatomic)IBOutlet UIViewController* controller;

- (IBAction)didPressLink;
@end
