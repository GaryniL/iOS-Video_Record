//
//  CameraViewController.m
//  VideoRecordAPP
//
//  Created by Gary on 2019/7/16.
//  Copyright © 2019 Gary. All rights reserved.
//

#import "CameraViewController.h"
#import "VideoPreviewController.h"
@interface CameraViewController ()
- (void) moveNecessaryUItoFront;
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
- (AVCaptureVideoPreviewLayer*)captureVideoPreviewLayer{
    if (!_captureVideoPreviewLayer){
        _captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.cameraSessionController.captureSession];
    }
    return _captureVideoPreviewLayer;
}

/**
 *  Setup VideoPreviewLayer into UI (delegate method)
 */
- (void)setupCaptureVideoPreviewLayer{
    if (!self.captureVideoPreviewLayer) {
        self.captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.cameraSessionController.captureSession];
    }
    self.view.layer.masksToBounds = YES;
    self.captureVideoPreviewLayer.frame = self.view.bounds;
    self.captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:self.captureVideoPreviewLayer];
    
    // [UI] Preventing previewLayer cover all UI
    [self moveNecessaryUItoFront];
}

- (void)showAlertView:(NSString*)title message:(NSString*)message completion:(void (^)(UIAlertAction *action))action{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:action];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showPreviewVideoVC:(NSURL*)url{
    VideoPreviewController *previewController = [[VideoPreviewController alloc] init];
    previewController.videoURL = url;
    [self presentViewController:previewController animated:YES completion:^{
        
    }];
}

@end
