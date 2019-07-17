//
//  CameraSessionController.m
//  VideoRecordAPP
//
//  Created by Gary on 2019/7/16.
//  Copyright © 2019 Gary. All rights reserved.
//

#import "CameraSessionController.h"
#import <UIKit/UIKit.h>

@interface CameraSessionController()
@property (nonatomic, weak) UIView *cameraView;
@property (nonatomic, weak) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;


// Videos
@property (nonatomic, strong) AVCaptureDeviceInput *videoCaptureInput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoCaptureOutput;
// Audio
@property (nonatomic, strong) AVCaptureDeviceInput *audioCaptureInput;
@property (nonatomic, strong) AVCaptureAudioDataOutput *audioCaptureOutput;
- (AVCaptureSession *)captureSession;
@end

@implementation CameraSessionController

//- (id)initWithView:(CameraViewController*)viewController {
//    self = [self init];
//    self.cameraView = viewController;
//    return self;
//}

- (void) setupCameraSession{
    // Add video / audio input/outpur to stream session
    [self setupVideoStream];
    [self setupAudioStream];
    [self.viewSource setupCaptureVideoPreviewLayer];
}

/**
 *  Start AV Session
 *
 */
- (void) startVideoSession{
    GLog(@"[Video] Start Session");
    if (![self.captureSession isRunning]){
        [self.captureSession startRunning];
    }
}

/**
 *  Stop AV Session
 *
 */
- (void) stopVideoSession{
    GLog(@"[Video] Stop Session");
    if ([self.captureSession isRunning]){
        [self.captureSession stopRunning];
    }
}





#pragma mark - Auth checking
/**
 *  Check Privacy auth status for video and audio
 *  https://developer.apple.com/documentation/avfoundation/avauthorizationstatus
 */
- (BOOL) checkVideoANDAudioPermissionStatus{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        // Without permission
        GLog(@"Video capture access denied");
        return NO;
    }
    
    authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        // Without permission
        GLog(@"Audio capture access denied");
        return NO;
    }
    return YES;
}

/**
 *  Request authorization for video and audio
 */
- (void) requestAuthForVideoAndAudio{
    //requestAuthorizationForVideo()
    // TODO. alert view
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}



#pragma mark - Create Video Session
//1.選擇輸入來源(相機, 麥克風, 耳機等等)
//2.獲取視訊輸入流
//3.建立AVCaptrueSession (property)
//4.視訊輸入流加入AVCaptureSession
// AVCaptureDevice->AVCaptureDeviceInput-> Add to AVCaptureSession
//5.建立輸出流 AVCaptureVideoDataOutput data output buffer
//6.視訊輸出流加入到AVCaptureSession
//7.設定session相關參數

/**
 *  Setup Video Stream with 4 step
 *
 */
- (void) setupVideoStream{
    NSError *error = nil;
    
    // 1.選擇輸入來源(相機, 麥克風, 耳機等等)
    AVCaptureDevice *videoCaptureDevice = [self getVideoDevice];
    if (!videoCaptureDevice) {
        GLog(@"[Video] Get Video device error");
//        [self.cameraView showErrorAlertView:@"[錯誤] 無法取得相機"];
        return;
    }
    
    // 2.獲取視訊輸入流
    @try {
        self.videoCaptureInput = [[AVCaptureDeviceInput alloc] initWithDevice:videoCaptureDevice error:nil];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"Reason: %@", exception.reason );
        return;
    } @finally {
        if (error) {
            GLog(@"[Video] Get Video Input error：%@", error);
            return;
        }
    }
    
    // 4.視訊輸入流加入 AVCaptureSession
    if ([self.captureSession canAddInput:self.videoCaptureInput]) {
        [self.captureSession addInput:self.videoCaptureInput];
    } else {
        GLog(@"[Video] Add Video input to stream error");
//        [self.cameraView showErrorAlertView:@"[錯誤] 無法加入輸入流"];
        return;
    }

    // 5.建立輸出流 AVCaptureVideoDataOutput data output buffer
    self.videoCaptureOutput = [[AVCaptureVideoDataOutput alloc] init];
    if (!self.videoCaptureOutput) {
        GLog(@"[Video] Export Video output error");
//        [self.cameraView showErrorAlertView:@"[錯誤] 無法輸出輸出流"];
        return;
    }
//    self.videoCaptureOutput.alwaysDiscardsLateVideoFrames = YES;
    dispatch_queue_t videoQueue = dispatch_queue_create("Video Capture Queue", DISPATCH_QUEUE_SERIAL);
    [self.videoCaptureOutput setSampleBufferDelegate:self queue:videoQueue];
    
    // 6.視訊輸出流加入 AVCaptureSession
    if ([self.captureSession canAddOutput:self.videoCaptureOutput]) {
        [self.captureSession addOutput:self.videoCaptureOutput];
    } else {
        GLog(@"[Video] Add Video output to stream error");
//        [self.cameraView showErrorAlertView:@"[錯誤] 無法加入輸出流"];
        return;
    }
    GLog(@"[Video] Video stream init done");
    
    
//    //防抖功能
//    _captureMovieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
//    AVCaptureConnection *captureConnection = [_captureMovieFileOutput connectionWithMediaType:AVMediaTypeAudio];
//    if ([captureConnection isVideoStabilizationSupported]) {
//        captureConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
//    }
//    //將裝置輸出新增到會話中
//    if ([_captureSession canAddOutput:_captureMovieFileOutput]) {
//        [_captureSession addOutput:_captureMovieFileOutput];
//    }

}

/**
 *  Setup Audio Stream with 4 step
 *
 */
#pragma mark - Create Audio Session
- (void) setupAudioStream{
    NSError *error = nil;
    // 2.獲取音訊輸入流
    @try {
        self.audioCaptureInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self getAudioDevice] error:&error];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"[Audio] Reason: %@", exception.reason );
        return;
    } @finally {
        if (error) {
            GLog(@"[Audio] Get Video Input error：%@", error);
            return;
        }
    }
    
    if ([self.captureSession canAddInput:self.audioCaptureInput]) {
        [self.captureSession addInput:self.audioCaptureInput];
    } else {
        GLog(@"[Audio] Add Audio input to stream error");
//        [self.cameraView showErrorAlertView:@"[錯誤] 無法加入音訊輸入流"];
        return;
    }
    
    self.audioCaptureOutput = [[AVCaptureAudioDataOutput alloc] init];
    dispatch_queue_t audioQueue = dispatch_queue_create("Audio Capture Queue", DISPATCH_QUEUE_SERIAL);
    [self.audioCaptureOutput setSampleBufferDelegate:self queue:audioQueue];
    
    if([self.captureSession canAddOutput:self.audioCaptureOutput]) {
        [self.captureSession addOutput:self.audioCaptureOutput];
    } else {
        GLog(@"[Audio] Add Audio output to stream error");
//        [self.cameraView showErrorAlertView:@"[錯誤] 無法加入音訊輸出流"];
        return;
    }
    GLog(@"[Audio] Audio stream init done");
    
}










#pragma mark - Video/Audio Property
/**
 *  Get AV Capture Session
 *
 *  @return AVCaptureSession
 */
- (AVCaptureSession *)captureSession {
    if (_captureSession == nil){
        _captureSession = [[AVCaptureSession alloc] init];
        
        if ([_captureSession canSetSessionPreset:AVCaptureSessionPresetHigh]) {
            self.captureSession.sessionPreset = AVCaptureSessionPresetHigh;
        }
    }
    return _captureSession;
}

/**
 *  Get AV Video Capture Device
 *
 *  @return AVCaptureDevice (back)
 */
- (AVCaptureDevice *)getVideoDevice {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == AVCaptureDevicePositionBack) {
            return device;
        }
    }
    return nil;
}

/**
 *  Get AV Audio Capture Device
 *
 *  @return AVCaptureDevice (Audio)
 */
- (AVCaptureDevice *)getAudioDevice {
    return [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
}

- (UIView *)cameraView{
    return self.viewSource.mainView;
}

- (AVCaptureVideoPreviewLayer *)captureVideoPreviewLayer{
    return [self.viewSource captureVideoPreviewLayer];
}

@end
