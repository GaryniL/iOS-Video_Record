//
//  CameraSessionViewSource.h
//  VideoRecordAPP
//
//  Created by Gary on 2019/7/17.
//  Copyright © 2019 Gary. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol CameraSessionViewSource

- (UIView *)mainView;
- (AVCaptureVideoPreviewLayer*)captureVideoPreviewLayer:(AVCaptureSession*)captureSession;
- (void)setupCaptureVideoPreviewLayer;
@end

