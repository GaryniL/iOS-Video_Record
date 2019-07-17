//
//  CaptureButton.m
//  VideoRecordAPP
//
//  Created by Gary on 2019/7/16.
//  Copyright © 2019 Gary. All rights reserved.
//

#import "CaptureButton.h"

@implementation CaptureButton

- (id)init{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.00];
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 5.0f;
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.contentEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    }
    
    return self;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        // deep background
        self.backgroundColor = [UIColor colorWithRed:0.63 green:0.63 blue:0.63 alpha:1.00];
    } else {
        self.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.00];
    }
}

@end
