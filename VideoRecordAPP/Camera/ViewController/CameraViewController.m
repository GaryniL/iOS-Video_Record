//
//  CameraViewController.m
//  VideoRecordAPP
//
//  Created by Gary on 2019/7/16.
//  Copyright © 2019 Gary. All rights reserved.
//

#import "CameraViewController.h"
@interface CameraViewController ()
@end

@implementation CameraViewController


#pragma mark - Singleton
+ (instancetype)defaultCameraController {
    static CameraViewController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CameraViewController alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Property
- (CameraSessionController *)cameraSessionController {
    if (_cameraSessionController == nil){
        _cameraSessionController = [[CameraSessionController alloc] init];
        _cameraSessionController.viewSource = self;
    }
    return _cameraSessionController;
}

#pragma mark - Delegate (ViewSource)
- (UIView *)mainView{
    return self.view;
}

- (AVCaptureVideoPreviewLayer*)captureVideoPreviewLayer{
    if (!_captureVideoPreviewLayer){
        _captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.cameraSessionController.captureSession];
    }
    return _captureVideoPreviewLayer;
}

@end
