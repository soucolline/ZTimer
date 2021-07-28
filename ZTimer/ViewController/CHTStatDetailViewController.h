//
//  CHTStatDetailViewController.h
//  ChaoTimer
//
//  Created by Jichao Li on 10/5/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZTimer-Swift.h"

@class CHTSession;
@interface CHTStatDetailViewController : UITableViewController
@property (nonatomic, strong) NSMutableArray *statDetails;
@property (nonatomic, strong) CHTSession *session;
@property (nonatomic) OneStat *stat;
@property (nonatomic) int row;
@end
