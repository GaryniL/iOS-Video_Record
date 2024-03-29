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


// TODO
//1. hint title
//2. recoding time (Timer)

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
    // [Video] Check Permission each time back to view
    if ([self.cameraSessionController checkVideoANDAudioPermissionStatus] == NO){
        // [Video] Without Permission
        [self.cameraSessionController requestAuthForVideoAndAudio];
    }
    
    // Video setup
    // [Video] Important! initial at viewWillAppear preventing crash
    [self.cameraSessionController setupCameraSession];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    // [UI] Resize cornerRadius for preventing rotate change
    self.captureButton.layer.cornerRadius = self.view.frame.size.width * CAMERABUTTONSCALE/2;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.cameraSessionController startVideoSession];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.cameraSessionController stopVideoSession];
    [self.captureVideoPreviewLayer setAffineTransform:CGAffineTransformMakeScale(1, 1)];

}


#pragma mark - UI Initial
/**
 *  UI elements
 */
- (void)setupUI{
    // Capture Button (mid)
    self.captureButton = [[CaptureButton alloc] init];
    [self.captureButton addTarget:self
                           action:@selector(buttonRecordTouched:)
                 forControlEvents:UIControlEventTouchUpInside];
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
    
    // preview Button (Right)
    self.previewButton = [[UIButton alloc] init];
    [self.previewButton addTarget:self
                           action:@selector(buttonPreviewTouched:)
                 forControlEvents:UIControlEventTouchUpInside];
//    [self.previewButton setTitle:@"預覽" forState:UIControlStateNormal];
    [self.previewButton setImage:[UIImage imageNamed:@"album"] forState:UIControlStateNormal];
    [self.previewButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.previewButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [self.view addSubview:self.previewButton];
    
    self.timeLabel = [[UILabel alloc] init];
    [self.timeLabel setTextColor:UIColor.whiteColor];
    [self.timeLabel setFont:[UIFont boldSystemFontOfSize:16]];
    self.timeLabel.text = @"按下開始錄影";
    self.timeLabel.textAlignment = UITextAlignmentCenter;
    [self.view addSubview:self.timeLabel];

    [self setupConstraints];
}

- (void) moveNecessaryUItoFront{
    [self.view bringSubviewToFront:self.captureButton];
    [self.view bringSubviewToFront:self.dismissButton];
    [self.view bringSubviewToFront:self.previewButton];
    [self.view bringSubviewToFront:self.timeLabel];
}

/**
 *  AutoLayout
 */
- (void)setupConstraints{
    // Capture Button (mid)
    [self.captureButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.captureButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.captureButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-25.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.captureButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:CAMERABUTTONSCALE constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.captureButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.captureButton attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    
    // Dismiss Button (left)
    [self.dismissButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.dismissButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.captureButton attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-40.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.dismissButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.captureButton attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.dismissButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.captureButton attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.dismissButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.captureButton attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
    
    // Preview Button (right)
    [self.previewButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.previewButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.captureButton attribute:NSLayoutAttributeRight multiplier:1.0 constant:40.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.previewButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.captureButton attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.previewButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.captureButton attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.previewButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.captureButton attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
    
    // Label (mid)
    [self.timeLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.timeLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.timeLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.captureButton attribute:NSLayoutAttributeTop multiplier:1.0 constant:-5.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.timeLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.timeLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.captureButton attribute:NSLayoutAttributeHeight multiplier:0.8 constant:0.0]];
}

#pragma mark - Button Actions
/**
 *  Close Camera VC
 */
- (void) buttonDismissTouched:(UIButton*)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void) buttonRecordTouched:(UIButton*)sender {
    [sender setSelected:!sender.selected];
    if ([sender isSelected]){
        [self.cameraSessionController startVideoRecord];
    } else {
        [self.cameraSessionController stopVideoRecord];
    }
    
    // Check url exist for show the preview button
    if (self.cameraSessionController.videoURL && sender.isSelected == NO) {
        [self.previewButton setHidden:NO];
    } else {
        [self.previewButton setHidden:YES];
    }
}

- (void) buttonPreviewTouched:(UIButton*)sender {
    NSURL *url ;
    if (self.cameraSessionController.videoURL) {
        GLog(@"URL: %@",self.cameraSessionController.videoURL);
        url = self.cameraSessionController.videoURL;
    } else {
        GLog(@"Video URL not exist");
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        url = [NSURL URLWithString:[prefs stringForKey:kVIDEOPATHKEY]];
    }
    [self showPreviewVideoVC:url];
}





@end
