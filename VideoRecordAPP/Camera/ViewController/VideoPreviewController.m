//
//  VideoPreviewController.m
//  VideoRecordAPP
//
//  Created by Gary on 2019/7/17.
//  Copyright © 2019 Gary. All rights reserved.
//

#import "VideoPreviewController.h"

@interface VideoPreviewController ()

@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (strong, nonatomic) UIButton *dismissButton;
@end

@implementation VideoPreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self previewVideo];
}


- (void)setupUI{
    self.view.backgroundColor = UIColor.blackColor;
    
    // Play Button (mid)
    self.dismissButton = [[UIButton alloc] init];
    [self.dismissButton addTarget:self
                        action:@selector(buttonDismissTouched:)
              forControlEvents:UIControlEventTouchUpInside];
    [self.dismissButton setTitle:@"X" forState:UIControlStateNormal];
    self.dismissButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [self.dismissButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.dismissButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [self.view addSubview:self.dismissButton];
    
    
    [self setupConstraints];
}


/**
 *  AutoLayout
 */
- (void)setupConstraints{
    // dismiss Button (mid)
    [self.dismissButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.dismissButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:15.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.dismissButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:15.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.dismissButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.25 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.dismissButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.dismissButton attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
}

- (void) buttonDismissTouched:(UIButton*)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


- (void)previewVideo{
    if (self.videoURL == nil){
        return;
    }
    
    AVPlayer *player = [[AVPlayer alloc] initWithURL:self.videoURL];
    NSLog(@"previewVideo %@", self.videoURL);
    AVPlayerViewController *playerController = [[AVPlayerViewController alloc] init];
    
    playerController.player = player;
    [self addChildViewController:playerController];
    [self.view addSubview:playerController.view];
    playerController.view.frame = self.view.frame;
}

@end
