//
//  CHTCustomPickerView.h
//  ChaoTimer
//
//  Created by Jichao Li on 10/6/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomIOS7AlertView.h"

@interface CHTScramblePickerView : CustomIOS7AlertView <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic) int selectedType;
@property (nonatomic) int selectedSubType;
- (id) initWithPickerView;
@end
