//
//  LYZCutVideoFinishViewController.m
//  LYZMediaEditTool
//
//  Created by artios on 2017/9/25.
//  Copyright © 2017年 artios. All rights reserved.
//

#import "LYZCutVideoFinishViewController.h"


@interface LYZCutVideoFinishViewController ()

@property (strong, nonatomic) AVPlayer *player;

@end

@implementation LYZCutVideoFinishViewController

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.player pause];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"剪辑视频完成";
    
    [self configUI];
    
}

- (void)configUI {
    UIView *playView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, 400)];
    [self.view addSubview:playView];
    
    AVPlayerItem *playItem = [[AVPlayerItem alloc] initWithURL:self.playURL];
    
    self.player = [[AVPlayer alloc]initWithPlayerItem:playItem];
    
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    playerLayer.frame = playView.frame;
    [playView.layer addSublayer:playerLayer];
    
    UIButton *playButton           = [UIButton buttonWithType:UIButtonTypeCustom];
    playButton.frame               = CGRectMake(100, 550, self.view.frame.size.width - 100*2, 50);
    playButton.backgroundColor     = [UIColor redColor];
    playButton.layer.cornerRadius  = 5;
    playButton.layer.masksToBounds = YES;
    playButton.titleLabel.font     = [UIFont systemFontOfSize:20];
    [playButton setTitle:@"播放" forState:UIControlStateNormal];
    [playButton setTitle:@"暂停" forState:UIControlStateSelected];
    [playButton addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playButton];
}

- (void)playAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        
        [self.player play];
        
    } else {
        
        [self.player pause];
    }
    
}

- (void)repeatPlay {
    [self.player seekToTime:CMTimeMake(0, 1)];
    [self.player play];
}

@end
