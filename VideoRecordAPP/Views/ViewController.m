//
//  ViewController.m
//  VideoRecordAPP
//
//  Created by Gary on 2019/7/16.
//  Copyright © 2019 Gary. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize buttonCamera;
@synthesize buttonGallery;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
}

#pragma mark - UI
- (void)setupUI {
    self.view.backgroundColor = UIColor.whiteColor;
    
    self.buttonCamera = [[UIButton alloc] init];
    [self.buttonCamera setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
//    [self.buttonCamera setTitle:@"Camera" forState:UIControlStateNormal];
    [self.buttonCamera addTarget:self action:@selector(buttonCameraTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.buttonCamera];
    [self setupConstraints];
}

#pragma mark - AutoLayout
- (void)setupConstraints{
    [self.buttonCamera setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonCamera attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonCamera attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonCamera attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.25 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonCamera attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.buttonCamera attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
}

- (void) buttonCameraTouched:(UIButton*)sender {
    NSLog(@"You clicked on button %ld", (long)sender.tag);
    __weak id weakSelf = self;
    [CameraHelper startRecord:self delegate:weakSelf];
}

@end
