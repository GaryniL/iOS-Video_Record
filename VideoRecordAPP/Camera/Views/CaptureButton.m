//
//  CaptureButton.m
//  VideoRecordAPP
//
//  Created by Gary on 2019/7/16.
//  Copyright © 2019 Gary. All rights reserved.
//

#import "CaptureButton.h"

#define INACTIVE_COLOR [UIColor colorWithRed:0.93f green:0.93f blue:0.93f alpha:1.0]
#define ACTIVE_COLOR [UIColor colorWithRed:0.76f green:0.21f blue:0.12f alpha:1.0]

@implementation CaptureButton

- (id)init{
    self = [super init];
    if (self) {
        self.backgroundColor = ACTIVE_COLOR;
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 5.0f;
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.contentEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    
    if (selected) {
        // deep background
        self.backgroundColor = INACTIVE_COLOR;
    } else {
        self.backgroundColor = ACTIVE_COLOR;
    }
}


@end
