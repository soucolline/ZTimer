//
//  CHTSolveDetailViewController.h
//  ChaoTimer
//
//  Created by Jichao Li on 10/5/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHTSolve.h"

@interface CHTSolveDetailViewController : UITableViewController<UIActionSheetDelegate> {
    UIActionSheet *shareSheet;
}

@property (nonatomic, strong) CHTSolve *solve;

@end
