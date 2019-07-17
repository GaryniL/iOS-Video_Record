//
//  CameraViewController.h
//  VideoRecordAPP
//
//  Created by Gary on 2019/7/16.
//  Copyright © 2019 Gary. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraSessionController.h"
#import "CameraSessionViewSource.h"

@interface CameraViewController : UIViewController <CameraSessionViewSource>

// Views - 01-Capture
@property (strong, nonatomic) UIButton *captureButton;
@property (strong, nonatomic) UIButton *dismissButton;
// Views - 02-Preview
@property (strong, nonatomic) UIButton *capturedCancelButton;
@property (strong, nonatomic) UIButton *capturedConfirmButton;


// AVVideo
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;


@property (strong, nonatomic) CameraSessionController *cameraSessionController;

+ (instancetype)defaultCameraController;
- (void) showErrorAlertView:(NSString*)content;
@end
