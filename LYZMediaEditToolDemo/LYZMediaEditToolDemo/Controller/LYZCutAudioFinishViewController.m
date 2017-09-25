//
//  LYZCutAudioFinishViewController.m
//  LYZMediaEditTool
//
//  Created by artios on 2017/9/25.
//  Copyright © 2017年 artios. All rights reserved.
//

#import "LYZCutAudioFinishViewController.h"

@interface LYZCutAudioFinishViewController ()

@property (nonatomic, strong) AVAudioPlayer *player; //音频播放器

@property (nonatomic, strong) NSTimer       *timer;

@property (nonatomic, strong) UISlider      *slider;

@end

@implementation LYZCutAudioFinishViewController

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.player stop];
    [self.timer setFireDate:[NSDate distantFuture]];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"剪辑音频完成";
    
    [self lyz_config];
    [self configAudioPlayerWithUrl:self.playUrl];
    
}

- (void)lyz_config {
    
    self.slider = [[UISlider alloc] initWithFrame:CGRectMake(20, 100, self.view.bounds.size.width - 20 * 2, 20)];
    self.slider.minimumValue = 0.0f;
    self.slider.maximumValue = 1.0f;
    self.slider.value = 0.5f;
    [self.view addSubview:self.slider];
    
    
    UIButton *playButton           = [UIButton buttonWithType:UIButtonTypeCustom];
    playButton.frame               = CGRectMake(100, 440, self.view.frame.size.width - 100*2, 50);
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
        [self.timer setFireDate:[NSDate distantPast]];
        
    } else {
        
        [self.player pause];
        [self.timer setFireDate:[NSDate distantFuture]];//暂停计时器
    }
    
}

- (void)configAudioPlayerWithUrl:(NSURL *)url {
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    
    self.player.numberOfLoops = 1;
    
    self.player.volume = 1.0;
    
}

- (NSTimer *)timer {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0 target:self
                                                selector:@selector(timerAction) userInfo:nil repeats:YES];
        [_timer setFireDate:[NSDate distantFuture]];//在创建计时器的时候把计时器先暂停。
    }
    return _timer;
}

- (void)timerAction{
    self.slider.maximumValue = self.player.duration;
    self.slider.minimumValue = 0;
    self.slider.value = self.player.currentTime;
    NSLog(@"%.2f",self.player.currentTime);//在这里打印了一下歌曲当前的时间
}

- (NSURL *)filePathName:(NSString *)fileName Type:(NSString *)type {
    return [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:fileName ofType:type]];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
