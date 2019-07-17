//
//  CameraHelper.h
//  VideoRecordAPP
//
//  Created by Gary on 2019/7/16.
//  Copyright © 2019 Gary. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraViewController.h"

@interface CameraHelper : NSObject <UIImagePickerControllerDelegate>

+ (void)startRecord:(UIViewController*)viewController delegate:(id<UIImagePickerControllerDelegate, UINavigationControllerDelegate>)delegate;

@end

