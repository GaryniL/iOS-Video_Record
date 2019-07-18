//
//  ViewController.m
//  VideoRecordAPP
//
//  Created by Gary on 2019/7/16.
//  Copyright © 2019 Gary. All rights reserved.
//

#import "ViewController.h"
#import "VideoPreviewController.h"
#import "FileViewController.h"

@interface ViewController ()

@property (strong, nonatomic) UIButton *buttonCamera;
@property (strong, nonatomic) UIButton *buttonGallery;

@end

@implementation ViewController
@synthesize buttonCamera;
@synthesize buttonGallery;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self checkURLValid];
}

#pragma mark - UI
- (void)setupUI {
    self.view.backgroundColor = UIColor.whiteColor;
    
    self.buttonCamera = [[UIButton alloc] init];
    [self.buttonCamera setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
    [self.buttonCamera addTarget:self action:@selector(buttonCameraTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.buttonCamera];
    
    self.buttonGallery = [[UIButton alloc] init];
    [self.buttonGallery setImage:[UIImage imageNamed:@"album"] forState:UIControlStateNormal];
    [self.buttonGallery addTarget:self action:@selector(buttonGalleryTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.buttonGallery];
    
    [self setupConstraints];
}

#pragma mark - AutoLayout
- (void)setupConstraints{
    [self.buttonCamera setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonCamera attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonCamera attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonCamera attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.25 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonCamera attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.buttonCamera attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    
    
    [self.buttonGallery setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonGallery attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.buttonCamera attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonGallery attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.buttonCamera attribute:NSLayoutAttributeBottom multiplier:1.0 constant:100.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonGallery attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.buttonCamera attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonGallery attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.buttonGallery attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
}

- (NSURL*)url{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSURL *url = [NSURL URLWithString:[prefs stringForKey:kVIDEOPATHKEY]];
    NSLog(@"url: %@",url.absoluteString);
    return url;
}

- (BOOL)checkURLValid{
    NSURL* url = [self url];
    if([url.absoluteString isEqual: @""]){
        self.buttonGallery.alpha = 0.25;
        self.buttonGallery.enabled = NO;
        return NO;
    } else {
        self.buttonGallery.alpha = 1.0;
        self.buttonGallery.enabled = YES;
        return YES;
    }
}

- (void) buttonGalleryTouched:(UIButton*)sender {
//    NSURL *url = [self url];
//    if([self checkURLValid]){
//        VideoPreviewController *previewController = [[VideoPreviewController alloc] init];
//        previewController.videoURL = [self url];
//        [self presentViewController:previewController animated:YES completion:^{
//
//        }];
//    } else {
//        sender.alpha = 0.25;
//    }
    
    FileViewController *fileVC = [[FileViewController alloc] init];
    UINavigationController *naviVC = [[UINavigationController alloc] initWithRootViewController:fileVC];
    [self presentViewController:naviVC animated:YES completion:^{
    }];
    
}

- (void) buttonCameraTouched:(UIButton*)sender {
    __weak id weakSelf = self;
    [CameraHelper startRecord:self delegate:weakSelf];
}

@end
