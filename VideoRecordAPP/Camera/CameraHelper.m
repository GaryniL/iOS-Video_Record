//
//  CameraHelper.m
//  VideoRecordAPP
//
//  Created by Gary on 2019/7/16.
//  Copyright © 2019 Gary. All rights reserved.
//

// Helper
// https://developer.apple.com/documentation/avfoundation/cameras_and_media_capture/

#import "CameraHelper.h"

@interface CameraHelper ()

@end

@implementation CameraHelper

+ (void)startRecord:(UIViewController*)viewController delegate:(id<UIImagePickerControllerDelegate, UINavigationControllerDelegate>)delegate{
    CameraViewController *cameraView = [CameraViewController defaultCameraController];
    [viewController presentViewController:cameraView animated:YES completion:nil];
}

@end
