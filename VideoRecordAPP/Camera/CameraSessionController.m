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

@property (nonatomic, assign) Boolean isRecording;
@property (nonatomic, strong) dispatch_queue_t captureQueue;

@property (nonatomic, weak) UIView *cameraView;
@property (nonatomic, weak) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;

- (AVCaptureSession *)captureSession;
// Videos
@property (nonatomic, strong) AVCaptureDeviceInput *videoCaptureInput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoCaptureOutput;
// Audio
@property (nonatomic, strong) AVCaptureDeviceInput *audioCaptureInput;
@property (nonatomic, strong) AVCaptureAudioDataOutput *audioCaptureOutput;
// AssetWritter
@property (nonatomic, strong) AVAssetWriter *assetWriter;
@property (nonatomic, strong) AVAssetWriterInput *assetWriterVideoInput;
@property (nonatomic, strong) AVAssetWriterInput *assetWriterAudioInput;

@end

@implementation CameraSessionController

@synthesize isRecording;

//- (id)initWithView:(CameraViewController*)viewController {
//    self = [self init];
//    self.cameraView = viewController;
//    return self;
//}

- (void) setupCameraSession{
    // Add video / audio input/outpur to stream session
    isRecording = NO;
    [self setupVideoStream];
    [self setupAudioStream];
    [self.viewSource setupCaptureVideoPreviewLayer];
}

#pragma mark - Video Capture Procedure
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

/**
 *  Start AV Session
 *
 */
- (void) startVideoRecord{
    if (!isRecording){
        GLog(@"[Video] Start Record");
        self.isRecording = YES;
        // Create file path for storing video
        self.videoURL = [self getVideoPathURL];
        // Setup Asset Writter for audio/video
        [self setupVideoWriter];
    }
}

- (void) stopVideoRecord{
    if (isRecording){
        GLog(@"[Video] Stop Record");
        //self.assetWriter.status == AVAssetWriterStatusCompleted ||
        if (self.assetWriter.status == AVAssetWriterStatusUnknown ||
             self.assetWriter.status == AVAssetWriterStatusFailed || self.assetWriter.status == AVAssetWriterStatusCancelled) {
            NSLog(@"asset writer was in an unexpected state (%@)", @(self.assetWriter.status));
            return;
        } else{
            
            if(self.assetWriter && self.assetWriter.status == AVAssetWriterStatusWriting) {
                [self.assetWriterAudioInput markAsFinished];
                [self.assetWriterVideoInput markAsFinished];
                // no use async preventing markAsFinished no sync
                [self.assetWriter finishWritingWithCompletionHandler:^{
                    self.isRecording = NO;
                    self.assetWriter = nil;
                    self.assetWriterAudioInput = nil;
                    self.assetWriterVideoInput = nil;
                    NSLog(@"保存成功");
                }];
                
            }
        }
        
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
    
    // =============================================
    // 1.選擇輸入來源(相機, 麥克風, 耳機等等)
    AVCaptureDevice *videoCaptureDevice = [self getVideoDevice];
    if (!videoCaptureDevice) {
        GLog(@"[Video] Get Video device error");
//        [self.cameraView showErrorAlertView:@"[錯誤] 無法取得相機"];
        return;
    }
    
    // =============================================
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
    
    // =============================================
    // 4.視訊輸入流加入 AVCaptureSession
    if ([self.captureSession canAddInput:self.videoCaptureInput]) {
        [self.captureSession addInput:self.videoCaptureInput];
    } else {
        GLog(@"[Video] Add Video input to stream error");
//        [self.cameraView showErrorAlertView:@"[錯誤] 無法加入輸入流"];
        return;
    }

    // =============================================
    // 5.建立輸出流 AVCaptureVideoDataOutput data output buffer
    self.videoCaptureOutput = [[AVCaptureVideoDataOutput alloc] init];
    if (!self.videoCaptureOutput) {
        GLog(@"[Video] Export Video output error");
//        [self.cameraView showErrorAlertView:@"[錯誤] 無法輸出輸出流"];
        return;
    }
//    self.videoCaptureOutput.alwaysDiscardsLateVideoFrames = YES;
    
    [self.videoCaptureOutput setSampleBufferDelegate:self queue:self.captureQueue];
    
    // =============================================
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
    [self.audioCaptureOutput setSampleBufferDelegate:self queue:self.captureQueue];
    
    if([self.captureSession canAddOutput:self.audioCaptureOutput]) {
        [self.captureSession addOutput:self.audioCaptureOutput];
    } else {
        GLog(@"[Audio] Add Audio output to stream error");
//        [self.cameraView showErrorAlertView:@"[錯誤] 無法加入音訊輸出流"];
        return;
    }
    GLog(@"[Audio] Audio stream init done");
    
}




#pragma mark - Create Asset Writer
//1.AssetWriter Init
//2.Video Setting && AVAssetWriterInput(Video) Init
//3.Audio Setting && AVAssetWriterInput(Audio) Init
//4.Add video and audio input to assetWriter
/**
 *  Setup Asset writer
 *
 */
- (void) setupVideoWriter{
    NSError *error = nil;
    
    if (self.videoURL == nil) {
        return;
    }
    
    // =============================================
    // 1. AssetWriter Init
    self.assetWriter = [AVAssetWriter assetWriterWithURL:self.videoURL fileType:AVFileTypeMPEG4 error:nil];
    if (error) {
        GLog(@"[Asset] Init AssetWriter error：%@", error);
        return;
    }
    
    // =============================================
    // 2. Video Setting && AVAssetWriterInput(Video) Init
    NSDictionary *videoOutputSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:320], AVVideoWidthKey,
                                   [NSNumber numberWithInt:640], AVVideoHeightKey,
                            AVVideoScalingModeResizeAspectFill,AVVideoScalingModeKey,
                                   nil];

    self.assetWriterVideoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoOutputSettings];
    // Fetch realtime data from captureSession
    self.assetWriterVideoInput.expectsMediaDataInRealTime = YES;
    
    // =============================================
    // 3. Audio Setting && AVAssetWriterInput(Audio) Init
    NSDictionary *audioOutputSettings
    = [NSDictionary dictionaryWithObjectsAndKeys:
        @(kAudioFormatMPEG4AAC), AVFormatIDKey,
        @(1), AVNumberOfChannelsKey,
        @(44100), AVSampleRateKey,
        @(64000), AVEncoderBitRateKey,
//        @(28000), AVEncoderBitRatePerChannelKey,
       nil];
    self.assetWriterAudioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioOutputSettings];
    self.assetWriterAudioInput.expectsMediaDataInRealTime = YES;
    
    
    // =============================================
    // 4. Add video and audio input to assetWriter
    @try {
        if ([self.assetWriter canAddInput:self.assetWriterVideoInput]) {
            [self.assetWriter addInput:self.assetWriterVideoInput];
        }
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"[Asset] Add error, Reason: %@", exception.reason );
        return;
    }
    
    @try {
        if ([self.assetWriter canAddInput:self.assetWriterAudioInput]) {
            [self.assetWriter addInput:self.assetWriterAudioInput];
        }
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"[Asset] Add error, Reason: %@", exception.reason );
        return;
    }
    GLog(@"[Asset] Asset writer init done");
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

- (NSURL*)getVideoPathURL{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    
    NSString *destDateString = [dateFormatter stringFromDate:[NSDate date]];
    destDateString = [destDateString stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    destDateString = [destDateString stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    destDateString = [destDateString stringByReplacingOccurrencesOfString:@":" withString:@"-"];
    
    NSURL *outputURL = [NSURL fileURLWithPath:[documentsDirectoryPath stringByAppendingPathComponent:[[NSString alloc] initWithFormat:(@"%@.mp4"),destDateString]]];
    NSLog(@"Video URL at %@", outputURL);
    return outputURL;
}

- (dispatch_queue_t) captureQueue {
    if (!_captureQueue)
    {
        _captureQueue = dispatch_queue_create("CaptureQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _captureQueue;
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









#pragma mark <AVCaptureFileOutputRecordingDelegate>
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    if (!self.assetWriter){
        return ;
    }
    if (!CMSampleBufferDataIsReady(sampleBuffer)){
        return ;
    }
    
    if (self.assetWriter.status == AVAssetWriterStatusUnknown) {
        if ([self.assetWriter startWriting]){
            [self.assetWriter startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
        } else {
            NSLog(@"Starting writing error");
            return ;
        }
        
    } else if (self.assetWriter.status == AVAssetWriterStatusWriting){
        if (connection == [self.videoCaptureOutput connectionWithMediaType:AVMediaTypeVideo]){
            // Thread Lock
            if (self.assetWriterVideoInput.readyForMoreMediaData){
                BOOL success = [self.assetWriterVideoInput appendSampleBuffer:sampleBuffer];
                if (!success){
                    NSLog(@"Video not success");
                }
            }
        }
        
        if (connection == [self.audioCaptureOutput connectionWithMediaType:AVMediaTypeAudio]){
            // Thread Lock
            if (self.assetWriterAudioInput.readyForMoreMediaData){
                BOOL success = [self.assetWriterAudioInput appendSampleBuffer:sampleBuffer];
                if (!success){
                    NSLog(@"Video not success");
                }
            }
        }
    }
    
    
    
    
    
    
    /*
    if (self.assetWriter.status == AVAssetWriterStatusUnknown){
        @synchronized(self){
            self.isRecording = YES;
            [self.assetWriter startWriting];
            [self.assetWriter startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
        }
    } else if (self.assetWriter.status == AVAssetWriterStatusWriting){
        NSLog(@"錄製中");
        if (connection == [self.videoCaptureOutput connectionWithMediaType:AVMediaTypeVideo]){
            // Thread Lock
            @synchronized(self){
                if (self.assetWriterVideoInput.readyForMoreMediaData){
                    BOOL success = [self.assetWriterVideoInput appendSampleBuffer:sampleBuffer];
                    if (!success){
                        
                    }
                }
            }
        }
        
        if (connection == [self.audioCaptureOutput connectionWithMediaType:AVMediaTypeAudio]){
            // Thread Lock
            @synchronized(self){
                if (self.assetWriterAudioInput.readyForMoreMediaData) {
                    BOOL success = [self.assetWriterAudioInput appendSampleBuffer:sampleBuffer];
                    if (!success) {
                        
                    }
                }
            }
        }
    }
     */
    
    
    
    
    
}
@end
