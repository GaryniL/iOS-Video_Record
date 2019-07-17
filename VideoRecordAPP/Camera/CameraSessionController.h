//
//  CameraSessionController.h
//  VideoRecordAPP
//
//  Created by Gary on 2019/7/16.
//  Copyright © 2019 Gary. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "CameraSessionViewSource.h"

@interface CameraSessionController : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate>

@property (nonatomic, weak) id <CameraSessionViewSource> viewSource;
@property (nonatomic, strong) AVCaptureSession *captureSession;

- (BOOL) checkVideoANDAudioPermissionStatus;
- (void) requestAuthForVideoAndAudio;
- (void) setupCameraSession;

- (void) startVideoStream;
- (void) stopVideoSession;
@end
