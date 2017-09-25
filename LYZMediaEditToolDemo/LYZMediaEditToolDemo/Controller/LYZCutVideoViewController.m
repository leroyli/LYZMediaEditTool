//
//  LYZCutVideoViewController.m
//  LYZMediaEditTool
//
//  Created by artios on 2017/9/25.
//  Copyright © 2017年 artios. All rights reserved.
//

#import "LYZCutVideoViewController.h"
#import "LYZMediaEditTool.h"
#import "LYZCutVideoFinishViewController.h"
#import "WSProgressHUD.h"

@interface LYZCutVideoViewController ()

@property (strong, nonatomic) AVPlayer      *player;
@property (assign, nonatomic) CGFloat       duration;
@property (strong, nonatomic) UIButton      *playButton;

@end

@implementation LYZCutVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"剪辑视频";
    
    [self addTipLabel];
    
    [self configUI];
    
}

- (void)configUI{
    UIView *playView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, 300)];
    [self.view addSubview:playView];
    
    self.playButton           = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playButton.frame               = CGRectMake(100, 440 + 120, self.view.frame.size.width - 100*2, 50);
    self.playButton.backgroundColor     = [UIColor redColor];
    self.playButton.layer.cornerRadius  = 5;
    self.playButton.layer.masksToBounds = YES;
    self.playButton.titleLabel.font     = [UIFont systemFontOfSize:20];
    [self.playButton setTitle:@"播放" forState:UIControlStateNormal];
    [self.playButton setTitle:@"暂停" forState:UIControlStateSelected];
    [self.playButton addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.playButton];
    
    UIButton *cutButton           = [UIButton buttonWithType:UIButtonTypeCustom];
    cutButton.frame               = CGRectMake(100, 530 + 120, self.view.frame.size.width - 100*2, 50);
    cutButton.backgroundColor     = [UIColor redColor];
    cutButton.layer.cornerRadius  = 5;
    cutButton.layer.masksToBounds = YES;
    cutButton.titleLabel.font     = [UIFont systemFontOfSize:20];
    [cutButton setTitle:@"剪辑" forState:UIControlStateNormal];
    [cutButton setTitle:@"" forState:UIControlStateSelected];
    [cutButton addTarget:self action:@selector(cutClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cutButton];
    
    
    AVPlayerItem *playItem = [[AVPlayerItem alloc] initWithURL:[self filePathName:@"abc" Type:@"mp4"]];
    self.player = [[AVPlayer alloc] initWithPlayerItem:playItem];
    self.player.volume = 0.5;
    
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    playerLayer.frame = playView.frame;
    [playView.layer addSublayer:playerLayer];
    
}

//视频重新播放
- (void)repeatPlay {
    [self.player seekToTime:CMTimeMake(0, 1)];
    [self.player play];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.player pause];
}

- (void)playAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        
        [self.player play];
        
    } else {
        
        [self.player pause];
    }
    
}

- (void)cutClick:(UIButton *)sender {
    
    if (self.playButton.selected) {
        self.playButton.selected = NO;
    }
    
    [self.player pause];
    
    [WSProgressHUD showWithStatus:@"正在处理..."];
    
    [LYZMediaEditTool cutMediaWithMediaType:LYZMediaTypeVideo
                                   mediaPath:[self filePathName:@"abc" Type:@"mp4"]
                                   startTime:0.0
                                     endTime:10.0
                              outPutFileName:@"cutVideo"
                             complitionBlock:^(BOOL isSuccesed, NSURL *outputPath) {
                                 
                                 [WSProgressHUD dismiss];
                                 
                                 if (isSuccesed) {
                                     
                                     LYZCutVideoFinishViewController *finishVC = [[LYZCutVideoFinishViewController alloc] init];
                                     finishVC.playURL = outputPath;
                                     [self.navigationController pushViewController:finishVC animated:YES];
                                     
                                 }
                              }];
    
}

- (NSURL *)filePathName:(NSString *)fileName Type:(NSString *)type {
    return [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:fileName ofType:type]];
}

- (void)addTipLabel {
    
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height - 100, self.view.frame.size.width - 20 * 2, 20)];
    
    tipLabel.textAlignment = NSTextAlignmentCenter;
    
    tipLabel.text = @"具体信息请看控制台";
    
    [self.view addSubview:tipLabel];
    
}

@end
