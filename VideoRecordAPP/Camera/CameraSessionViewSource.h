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

- (AVCaptureVideoPreviewLayer*)captureVideoPreviewLayer;
- (void)setupCaptureVideoPreviewLayer;
- (void)showPreviewVideoVC:(NSURL*)url;
- (void)setTimerText:(NSString*)text;


- (void)showAlertView:(NSString*)title message:(NSString*)message completion:(void (^)(void))completion;
@end

