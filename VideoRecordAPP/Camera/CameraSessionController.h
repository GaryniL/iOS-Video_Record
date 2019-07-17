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
@property (strong, nonatomic) NSURL *videoURL;
@property (nonatomic, assign) Boolean isRecording;

- (BOOL) checkVideoANDAudioPermissionStatus;
- (void) requestAuthForVideoAndAudio;
- (void) setupCameraSession;

- (void) startVideoSession;
- (void) stopVideoSession;
- (void) startVideoRecord;
- (void) stopVideoRecord;
@end
