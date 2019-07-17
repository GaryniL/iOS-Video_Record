//
//  CameraViewController+View.m
//  VideoRecordAPP
//
//  Created by Gary on 2019/7/16.
//  Copyright © 2019 Gary. All rights reserved.
//
// This file collected methods for Views

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h> //UIBtn
#import "CameraViewController.h"
#import "CaptureButton.h"

// UI config
#define CAMERABUTTONSCALE 0.2f

@interface CameraViewController(View)

@end

@implementation CameraViewController(View)

#pragma mark - View Life Cycles
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.grayColor;
    
    [self setupUI];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Check Permission each time back to view
    if ([self.cameraSessionController checkVideoANDAudioPermissionStatus] == NO){
        // Without Permission
        [self.cameraSessionController requestAuthForVideoAndAudio];
    }
    
    // Video setup
    // Important! initial at viewWillAppear preventing crash
    [self.cameraSessionController setupCameraSession];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    // Resize cornerRadius for preventing rotate change
    self.captureButton.layer.cornerRadius = self.view.frame.size.width * CAMERABUTTONSCALE/2;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.cameraSessionController startVideoSession];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.cameraSessionController stopVideoSession];
}





- (void)setupUI{
    // Capture Button (mid)
    self.captureButton = [[CaptureButton alloc] init];
    [self.view addSubview:self.captureButton];
    
    // Dismiss Button (left)
    self.dismissButton = [[UIButton alloc] init];
    [self.dismissButton addTarget:self
               action:@selector(buttonDismissTouched:)
     forControlEvents:UIControlEventTouchUpInside];
    [self.dismissButton setTitle:@"取消" forState:UIControlStateNormal];
    [self.dismissButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.dismissButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [self.view addSubview:self.dismissButton];
    
    [self setupConstraints];
}

- (void) moveNecessaryUItoFront{
    [self.view bringSubviewToFront:self.captureButton];
    [self.view bringSubviewToFront:self.dismissButton];
}

#pragma mark - AutoLayout
- (void)setupConstraints{
    // Capture Button (mid)
    [self.captureButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.captureButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.captureButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-15.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.captureButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:CAMERABUTTONSCALE constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.captureButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.captureButton attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    
    // Dismiss Button (left)
    [self.dismissButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.dismissButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.captureButton attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-40.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.dismissButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.captureButton attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.dismissButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.captureButton attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.dismissButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.captureButton attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
}

#pragma mark - Button Actions
/**
 *  Close Camera VC
 */
- (void) buttonDismissTouched:(UIButton*)sender {
    NSLog(@"You clicked on button %ld", (long)sender.tag);
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Show UI
- (void) showErrorAlertView:(NSString*)content{
    NSLog(@"=============>%@",content);
}


#pragma mark - Video
- (void)setupCaptureVideoPreviewLayer{
    if (!self.captureVideoPreviewLayer) {
        self.captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.cameraSessionController.captureSession];
    }
    self.view.layer.masksToBounds = YES;
    self.captureVideoPreviewLayer.frame = self.view.bounds;
    self.captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    //    self.captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.view.layer addSublayer:self.captureVideoPreviewLayer];
    // TODO.新增聚焦手勢
    
    [self moveNecessaryUItoFront];
}
@end
