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

@property (nonatomic, assign) BOOL canWrite;
@property (nonatomic, strong) dispatch_queue_t captureVideoQueue;

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

@property (nonatomic, strong) CIFilter * filter;
@property (nonatomic, strong) CIContext *ciContext;
@end

@implementation CameraSessionController

@synthesize isRecording;
@synthesize canWrite;


- (void) setupCameraSession{
    // Add video / audio input/outpur to stream session
    isRecording = NO;
    canWrite = NO;
    
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
 *  Start Recording
 *
 */
- (void) startVideoRecord{
    self.ciContext = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer : @(YES)}];

    if (!isRecording && !self.assetWriter){
        GLog(@"[Video] Start Record");
        self.isRecording = YES;
        // Create file path for storing video
        self.videoURL = [self getVideoURL];
        // Setup Asset Writter for audio/video
        [self setupVideoWriter];
    }
}

- (void) saveVideoDone{
    [self.viewSource showAlertView:@"完成儲存" message:@"點擊確定檢視您錄製的影片" completion:^{
        [self.viewSource showPreviewVideoVC:self.videoURL];
    }];
}
/**
 *  Stop Recording
 *
 */
- (void) stopVideoRecord{
    if (self.isRecording){
        self.isRecording = NO;
        GLog(@"[Video] Stop Record");

        //self.assetWriter.status == AVAssetWriterStatusCompleted ||
        if (self.assetWriter.status == AVAssetWriterStatusUnknown ||
             self.assetWriter.status == AVAssetWriterStatusFailed || self.assetWriter.status == AVAssetWriterStatusCancelled) {
            NSLog(@"asset writer was in an unexpected state (%@)", @(self.assetWriter.status));
            return;
        }
    
        if(self.assetWriter && self.assetWriter.status == AVAssetWriterStatusWriting) {
            // no use async preventing markAsFinished not sync
            __weak __typeof(self)weakSelf = self;
            [self.assetWriter finishWritingWithCompletionHandler:^{
//                    [weakSelf.assetWriterAudioInput markAsFinished];
//                    [weakSelf.assetWriterVideoInput markAsFinished];
                weakSelf.assetWriter = nil;
                weakSelf.assetWriterAudioInput = nil;
                weakSelf.assetWriterVideoInput = nil;
                [weakSelf saveVideoURL];
                [weakSelf saveVideoDone];
                NSLog(@"保存成功");
            }];
            
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
    [self.viewSource showAlertView:@"無法取得相機權限" message:@"點擊前往設定.app授予權限" completion:^{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    
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
    
    // This ensures that any late video frames are dropped rather than output to delegate.
    self.videoCaptureOutput.alwaysDiscardsLateVideoFrames = YES;
    
    [self.videoCaptureOutput setSampleBufferDelegate:self queue:self.captureVideoQueue];
    
    // =============================================
    // 6.視訊輸出流加入 AVCaptureSession
    if ([self.captureSession canAddOutput:self.videoCaptureOutput]) {
        [self.captureSession addOutput:self.videoCaptureOutput];
    } else {
        GLog(@"[Video] Add Video output to stream error");
//        [self.cameraView showErrorAlertView:@"[錯誤] 無法加入輸出流"];
        return;
    }
    
    AVCaptureConnection *videoConnection = [self.videoCaptureOutput connectionWithMediaType:AVMediaTypeVideo];
    
    // default 90 degree rotate
    if ([videoConnection isVideoOrientationSupported]) {
        // (portrait)
        videoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    }
    GLog(@"[Video] Video stream init done");
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
    [self.audioCaptureOutput setSampleBufferDelegate:self queue:self.captureVideoQueue];
    
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
    double w = [UIScreen mainScreen].bounds.size.width;
    double h = [UIScreen mainScreen].bounds.size.height;
    
    double width = MIN(w, h);
    double height = MAX(w, h);
    // =============================================
    // 2. Video Setting && AVAssetWriterInput(Video) Init
    NSDictionary *videoOutputSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:height], AVVideoHeightKey,
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
    
//    self.assetWriterVideoInput.transform = CGAffineTransformMakeRotation(M_PI / 2.0);
    
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
    canWrite = NO;
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



- (void) saveVideoURL{
    [[NSUserDefaults standardUserDefaults] setObject:self.videoURL.absoluteString forKey:kVIDEOPATHKEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSURL*)getVideoURL{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    
    NSString *destDateString = [dateFormatter stringFromDate:[NSDate date]];
    
    
    NSURL *outputURL = [NSURL fileURLWithPath:[documentsDirectoryPath stringByAppendingPathComponent:[[NSString alloc] initWithFormat:(@"%@.mp4"),destDateString]]];
    NSLog(@"Video URL at %@", outputURL);
    return outputURL;
}

- (dispatch_queue_t) captureVideoQueue {
    if (!_captureVideoQueue)
    {
        _captureVideoQueue = dispatch_queue_create("CaptureVideoQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _captureVideoQueue;
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
    
    if (sampleBuffer == NULL){
        return;
    }
    if (!self.assetWriter){
        return ;
    }
    
    UIView* preview = [self.viewSource getpreviewView];
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    CMSampleBufferRef pixelBuffer;
    if (imageBuffer) {
        CIImage *ciImage = [CIImage imageWithCVImageBuffer:imageBuffer];
        
        // Implement Filter
        // https://developer.apple.com/documentation/coreimage?language=objc#3230489
        self.filter = [CIFilter filterWithName:@"CIXRay"];
        [self.filter setValue:ciImage forKey:@"inputImage"];
        
        CIImage *outputImage = [self.filter outputImage];
        CGImageRef outputImageRef = [self.ciContext createCGImage:outputImage fromRect:outputImage.extent];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            preview.layer.contents = (__bridge id )(outputImageRef);
            CGImageRelease(outputImageRef);
        });
        
        // Turn CIImage to CMSampleBufferRef
        // https://stackoverflow.com/questions/18851949/how-to-convert-ciimage-to-cmsamplebufferref
        // https://stackoverflow.com/questions/47576163/cicontext-render-tocvpixelbuffer-bounds-colorspace-function-does-not-work-fo
        //  https://stackoverflow.com/questions/15693784/crop-cmsamplebufferref
        // http://allmybrain.com/2011/12/08/rendering-to-a-texture-with-ios-5-texture-cache-api/
        
        CFDictionaryRef empty; // empty value for attr value.
        CFMutableDictionaryRef attrs;
        empty = CFDictionaryCreate(kCFAllocatorDefault, // our empty IOSurface properties dictionary
                                   NULL,
                                   NULL,
                                   0,
                                   &kCFTypeDictionaryKeyCallBacks,
                                   &kCFTypeDictionaryValueCallBacks);
        attrs = CFDictionaryCreateMutable(kCFAllocatorDefault,
                                          1,
                                          &kCFTypeDictionaryKeyCallBacks,
                                          &kCFTypeDictionaryValueCallBacks);
        
        CFDictionarySetValue(attrs,
                             kCVPixelBufferIOSurfacePropertiesKey,
                             empty);
        
        double w = [UIScreen mainScreen].bounds.size.width;
        double h = [UIScreen mainScreen].bounds.size.height;
        
        double width = MIN(w, h);
        double height = MAX(w, h);
        
        CVPixelBufferCreate(kCFAllocatorDefault, width*3, height*3, kCVPixelFormatType_32BGRA, attrs, &pixelBuffer);
        ///????? why x3
        
        CVPixelBufferLockBaseAddress( pixelBuffer, 0 );
        
        CIContext * ciContext = [CIContext contextWithOptions: nil];
        [ciContext render:outputImage toCVPixelBuffer:pixelBuffer];
        CVPixelBufferUnlockBaseAddress( pixelBuffer, 0 );
        
        CMSampleTimingInfo sampleTime = {
            .duration = CMSampleBufferGetDuration(sampleBuffer),
            .presentationTimeStamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer),
            .decodeTimeStamp = CMSampleBufferGetDecodeTimeStamp(sampleBuffer)
        };
        
        CMVideoFormatDescriptionRef videoInfo = NULL;
        CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault, pixelBuffer, &videoInfo);
        
        CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault, pixelBuffer, true, NULL, NULL, videoInfo, &sampleTime, &pixelBuffer);
    }
    
    
    
    // Thread Lock
    @synchronized(self)
    {
        // TODO thread problem..?
        if (!self.canWrite && connection == [self.videoCaptureOutput connectionWithMediaType:AVMediaTypeVideo] && self.assetWriter.status == AVAssetWriterStatusUnknown) {
            [self.assetWriter startWriting];
            [self.assetWriter startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
            self.canWrite = YES;
        }
    }
    
    // Video Write in
    if (connection == [self.videoCaptureOutput connectionWithMediaType:AVMediaTypeVideo]) {
        @synchronized(self)
        {
            // Prevent stop and still inputing buffer
            if (isRecording){
                if (self.assetWriterVideoInput.readyForMoreMediaData) {
                    [self.assetWriterVideoInput appendSampleBuffer:pixelBuffer];
                }
            }
        }
    }
    
    // Audio Write in
    if (connection == [self.audioCaptureOutput connectionWithMediaType:AVMediaTypeAudio]) {
        // Important!! Safe thread lock
        @synchronized(self) {
            // Prevent stop and still inputing buffer
            if (isRecording) {
                if (self.assetWriterAudioInput.readyForMoreMediaData) {
                    [self.assetWriterAudioInput appendSampleBuffer:sampleBuffer];
                }
            }
        }
    }
}


@end
