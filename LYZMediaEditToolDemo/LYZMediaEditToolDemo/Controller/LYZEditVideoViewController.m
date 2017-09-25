//
//  LYZEditVideoViewController.m
//  LYZMediaEditTool
//
//  Created by artios on 2017/9/25.
//  Copyright © 2017年 artios. All rights reserved.
//

#import "LYZEditVideoViewController.h"
#import "LYZMediaEditTool.h"
#import "LYZEditVideoFinishViewController.h"
#import "WSProgressHUD.h"

@interface LYZEditVideoViewController ()

@property (strong, nonatomic) AVPlayer      *player;
@property (strong, nonatomic) AVAudioPlayer *BGMPlayer;
@property (strong, nonatomic) UISlider      *originalVoiceSlide;
@property (strong, nonatomic) UISlider      *BGMVoiceSlider;
@property (assign, nonatomic) CGFloat       duration;
@property (strong, nonatomic) UIButton      *playButton;

@end

@implementation LYZEditVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"编辑视频";
    
    [self addTipLabel];
    
    [self configUI];
    
}

- (void)configUI {
    
    UIView *playView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, 300)];
    [self.view addSubview:playView];
    
    UILabel *videoLabel      = [[UILabel alloc] initWithFrame:CGRectMake(10, 330 + 120, 80, 20)];
    videoLabel.textAlignment = NSTextAlignmentLeft;
    videoLabel.font          = [UIFont systemFontOfSize:13.f];
    videoLabel.text          = @"视频音量";
    [self.view addSubview:videoLabel];
    
    UILabel *audioLabel      = [[UILabel alloc] initWithFrame:CGRectMake(10, 380 + 120, 80, 20)];
    audioLabel.textAlignment = NSTextAlignmentLeft;
    audioLabel.font          = [UIFont systemFontOfSize:13.f];
    audioLabel.text          = @"音频音量";
    [self.view addSubview:audioLabel];
    
    self.originalVoiceSlide              = [[UISlider alloc] initWithFrame:CGRectMake(100, 330 + 120, self.view.bounds.size.width - 120, 20)];
    self.originalVoiceSlide.minimumValue = 0.0f;
    self.originalVoiceSlide.maximumValue = 1.0f;
    self.originalVoiceSlide.value        = 0.5f;
    [self.originalVoiceSlide addTarget:self action:@selector(originalVoiceSlideChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.originalVoiceSlide];
    
    
    self.BGMVoiceSlider              = [[UISlider alloc] initWithFrame:CGRectMake(100, 380 + 120, self.view.bounds.size.width - 120, 20)];
    self.BGMVoiceSlider.minimumValue = 0.0f;
    self.BGMVoiceSlider.maximumValue = 1.0f;
    self.BGMVoiceSlider.value        = 0.5f;
    [self.BGMVoiceSlider addTarget:self action:@selector(BGMVoiceSliderChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.BGMVoiceSlider];
    
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
    
    UIButton *synthesizeButton           = [UIButton buttonWithType:UIButtonTypeCustom];
    synthesizeButton.frame               = CGRectMake(100, 530 + 120, self.view.frame.size.width - 100*2, 50);
    synthesizeButton.backgroundColor     = [UIColor redColor];
    synthesizeButton.layer.cornerRadius  = 5;
    synthesizeButton.layer.masksToBounds = YES;
    synthesizeButton.titleLabel.font     = [UIFont systemFontOfSize:20];
    [synthesizeButton setTitle:@"合成" forState:UIControlStateNormal];
    [synthesizeButton setTitle:@"" forState:UIControlStateSelected];
    [synthesizeButton addTarget:self action:@selector(synthesizeClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:synthesizeButton];
    
    
    AVPlayerItem *playItem = [[AVPlayerItem alloc] initWithURL:[self filePathName:@"abc" Type:@"mp4"]];
    self.player            = [[AVPlayer alloc] initWithPlayerItem:playItem];
    self.player.volume     = 0.5;
    
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    playerLayer.frame          = playView.frame;
    [playView.layer addSublayer:playerLayer];
    
    self.BGMPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[self filePathName:@"123" Type:@"mp3"] error:nil];
    
    
    self.BGMPlayer.numberOfLoops = -1;//循环播放
    self.BGMPlayer.volume = 0.5;
    
    [self.BGMPlayer prepareToPlay];
}

- (void)originalVoiceSlideChange:(UISlider *)slider {
    
    self.player.volume = slider.value;
    
    NSLog(@"playerslider volume : %.2f",slider.value);
}

- (void)BGMVoiceSliderChange:(UISlider *)slider {
    self.BGMPlayer.volume = slider.value;
    
    NSLog(@"BGMPlayerlider volume : %.2f",slider.value);
}

//视频重新播放
- (void)repeatPlay {
    [self.player seekToTime:CMTimeMake(0, 1)];
    [self.player play];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.BGMPlayer stop];
    [self.player pause];
}

- (void)playAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        
        [self.BGMPlayer play];
        [self.player play];
        
    } else {
        
        [self.BGMPlayer stop];
        [self.player pause];
    }
    
}

- (void)synthesizeClick:(UIButton *)sender {
    
    if (self.playButton.selected) {
        self.playButton.selected = NO;
    }
    
    [self.BGMPlayer stop];
    [self.player pause];
    
    [WSProgressHUD showWithStatus:@"正在处理..."];
    
    [LYZMediaEditTool mixVideoAndAudioWithVieoPath:[self filePathName:@"abc" Type:@"mp4"]
                                          audioPath:[self filePathName:@"123" Type:@"mp3"]
                                     needVideoVoice:YES
                                        videoVolume:self.originalVoiceSlide.value
                                        audioVolume:self.BGMVoiceSlider.value
                                     outPutFileName:@"outputFile"
                                    complitionBlock:^(BOOL isSuccesed, NSURL *outputPath) {
                                        
                                        [WSProgressHUD dismiss];
                                        
                                        if (isSuccesed) {
                                            
                                            LYZEditVideoFinishViewController *finishVC = [[LYZEditVideoFinishViewController alloc] init];
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
