//
//  CHTSessionViewController.h
//  ChaoTimer
//
//  Created by Jichao Li on 10/6/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHTSessionManager.h"

@interface CHTSessionViewController : UITableViewController <UIActionSheetDelegate>
@property (nonatomic, strong) CHTSessionManager *sessionManager;

@end