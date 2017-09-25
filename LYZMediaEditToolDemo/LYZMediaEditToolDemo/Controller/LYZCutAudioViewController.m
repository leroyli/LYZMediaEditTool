//
//  LYZCutAudioViewController.m
//  LYZMediaEditTool
//
//  Created by artios on 2017/9/25.
//  Copyright © 2017年 artios. All rights reserved.
//

#import "LYZCutAudioViewController.h"
#import "LYZMediaEditTool.h"
#import "LYZCutAudioFinishViewController.h"
#import "WSProgressHUD.h"

@interface LYZCutAudioViewController ()

@property (nonatomic, strong) AVAudioPlayer *player; //音频播放器

@property (nonatomic, strong) NSTimer       *timer;

@property (nonatomic, strong) UISlider      *slider;

@property (nonatomic, strong) UIButton      *playButton;

@end

@implementation LYZCutAudioViewController

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.player pause];
    [self.player stop];
    [self.timer setFireDate:[NSDate distantFuture]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"剪辑音频";
    
    [self addTipLabel];
    
    [self lyz_config];
    
    [self configAudioPlayerWithUrl:[self filePathName:@"五环之歌" Type:@"mp3"]];
    
}

- (void)lyz_config {
    
    self.slider = [[UISlider alloc] initWithFrame:CGRectMake(20, 100, self.view.bounds.size.width - 20 * 2, 20)];
    self.slider.minimumValue = 0.0f;
    self.slider.maximumValue = 1.0f;
    self.slider.value = 0.5f;
    [self.view addSubview:self.slider];
    
    
    self.playButton           = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playButton.frame               = CGRectMake(100, 440, self.view.frame.size.width - 100*2, 50);
    self.playButton.backgroundColor     = [UIColor redColor];
    self.playButton.layer.cornerRadius  = 5;
    self.playButton.layer.masksToBounds = YES;
    self.playButton.titleLabel.font     = [UIFont systemFontOfSize:20];
    [self.playButton setTitle:@"播放" forState:UIControlStateNormal];
    [self.playButton setTitle:@"暂停" forState:UIControlStateSelected];
    [self.playButton addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.playButton];
    
    UIButton *synthesizeButton           = [UIButton buttonWithType:UIButtonTypeCustom];
    synthesizeButton.frame               = CGRectMake(100, 530, self.view.frame.size.width - 100*2, 50);
    synthesizeButton.backgroundColor     = [UIColor redColor];
    synthesizeButton.layer.cornerRadius  = 5;
    synthesizeButton.layer.masksToBounds = YES;
    synthesizeButton.titleLabel.font     = [UIFont systemFontOfSize:20];
    [synthesizeButton setTitle:@"剪辑" forState:UIControlStateNormal];
    [synthesizeButton setTitle:@"" forState:UIControlStateSelected];
    [synthesizeButton addTarget:self action:@selector(cutClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:synthesizeButton];
    
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



- (void)cutClick:(UIButton *)sender {
    
    if (self.playButton.selected) {
        self.playButton.selected = NO;
    }
    
    [self.player pause];
    [self.timer setFireDate:[NSDate distantFuture]];//暂停计时器
    
    [WSProgressHUD showWithStatus:@"正在处理..."];
    
    [LYZMediaEditTool cutMediaWithMediaType:LYZMediaTypeAudio
                                   mediaPath:[self filePathName:@"五环之歌" Type:@"mp3"]
                                   startTime:0.0
                                     endTime:10.0
                              outPutFileName:@"cutAudio"
                             complitionBlock:^(BOOL isSuccesed, NSURL *outputPath) {
                                 
                                 [WSProgressHUD dismiss];
                                 
                                 if (isSuccesed) {
                                     
                                     NSString *path = [outputPath absoluteString];
                                     
                                     NSLog(@">>>>>>>>>>>>>Cut successed and path is : %@",path);
                                     
                                     LYZCutAudioFinishViewController *finishVC = [[LYZCutAudioFinishViewController alloc] init];
                                     finishVC.playUrl = outputPath;
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
