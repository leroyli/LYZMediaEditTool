//
//  LYZEditAudioViewController.m
//  LYZMediaEditTool
//
//  Created by artios on 2017/9/25.
//  Copyright © 2017年 artios. All rights reserved.
//

#import "LYZEditAudioViewController.h"
#import "LYZMediaEditTool.h"
#import "LYZEditAudioFinishViewController.h"
#import "WSProgressHUD.h"

@interface LYZEditAudioViewController ()

@property (nonatomic, strong) AVAudioPlayer *player; //音频播放器

@property (nonatomic, strong) NSTimer       *timer;

@property (nonatomic, strong) UISlider      *slider;

@property (nonatomic, strong) NSURL         *fileUrl;

@property (nonatomic, strong) UIButton      *playButton1;

@property (nonatomic, strong) UIButton      *playButton2;

@end

@implementation LYZEditAudioViewController

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
    
    self.title = @"编辑音频";
    
    [self addTipLabel];
    
    [self lyz_config];
    
}

- (void)lyz_config {
    
    self.slider = [[UISlider alloc] initWithFrame:CGRectMake(20, 100, self.view.bounds.size.width - 20 * 2, 20)];
    self.slider.minimumValue = 0.0f;
    self.slider.maximumValue = 1.0f;
    self.slider.value = 0.5f;
    [self.view addSubview:self.slider];
    
    
    self.playButton1           = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playButton1 .frame               = CGRectMake(100, 440, self.view.frame.size.width - 100*2, 50);
    self.playButton1 .backgroundColor     = [UIColor redColor];
    self.playButton1 .layer.cornerRadius  = 5;
    self.playButton1 .layer.masksToBounds = YES;
    self.playButton1 .titleLabel.font     = [UIFont systemFontOfSize:20];
    [self.playButton1  setTitle:@"播放音频1" forState:UIControlStateNormal];
    [self.playButton1  setTitle:@"暂停音频1" forState:UIControlStateSelected];
    [self.playButton1  addTarget:self action:@selector(playActionOne:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.playButton1 ];
    
    self.playButton2           = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playButton2.frame               = CGRectMake(100, 530, self.view.frame.size.width - 100*2, 50);
    self.playButton2.backgroundColor     = [UIColor redColor];
    self.playButton2.layer.cornerRadius  = 5;
    self.playButton2.layer.masksToBounds = YES;
    self.playButton2.titleLabel.font     = [UIFont systemFontOfSize:20];
    [self.playButton2 setTitle:@"播放音频2" forState:UIControlStateNormal];
    [self.playButton2 setTitle:@"暂停音频2" forState:UIControlStateSelected];
    [self.playButton2 addTarget:self action:@selector(playActionTwo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.playButton2];
    
    
    UIButton *synthesizeButton           = [UIButton buttonWithType:UIButtonTypeCustom];
    synthesizeButton.frame               = CGRectMake(100, 620, self.view.frame.size.width - 100*2, 50);
    synthesizeButton.backgroundColor     = [UIColor redColor];
    synthesizeButton.layer.cornerRadius  = 5;
    synthesizeButton.layer.masksToBounds = YES;
    synthesizeButton.titleLabel.font     = [UIFont systemFontOfSize:20];
    [synthesizeButton setTitle:@"合成" forState:UIControlStateNormal];
    [synthesizeButton setTitle:@"" forState:UIControlStateSelected];
    [synthesizeButton addTarget:self action:@selector(synthesizeClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:synthesizeButton];
}

- (void)playActionOne:(UIButton *)sender {
    
    if (self.playButton2.selected) {
        self.playButton2.selected = NO;
    }
    
    if (self.player) {
        self.player = nil;
    }
    
    [self configAudioPlayerWithUrl:[self filePathName:@"陈奕迅" Type:@"mp3"]];
    
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        
        [self.player play];
        [self.timer setFireDate:[NSDate distantPast]];
        
    } else {
        
        [self.player pause];
        [self.timer setFireDate:[NSDate distantFuture]];//暂停计时器
    }
    
}

- (void)playActionTwo:(UIButton *)sender {
    
    if (self.playButton1.selected) {
        self.playButton1.selected = NO;
    }
    
    if (self.player) {
        self.player = nil;
    }
    
    [self configAudioPlayerWithUrl:[self filePathName:@"五环之歌" Type:@"mp3"]];
    
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



- (void)synthesizeClick:(UIButton *)sender {
    
    if (self.playButton1.selected) {
        self.playButton1.selected = NO;
    }
    
    if (self.playButton2.selected) {
        self.playButton2.selected = NO;
    }
    
    [self.player pause];
    [self.timer setFireDate:[NSDate distantFuture]];//暂停计时器
    
    [WSProgressHUD showWithStatus:@"正在处理..."];
    
    [LYZMediaEditTool mixOriginalAudio:[self filePathName:@"陈奕迅" Type:@"mp3"]
                    originalAudioVolume:0.5
                            bgAudioPath:[self filePathName:@"五环之歌" Type:@"mp3"]
                          bgAudioVolume:0.5
                         outPutFileName:@"mix"
                        completionBlock:^(BOOL isSuccesed, NSURL *outputPath) {
                            
                            [WSProgressHUD dismiss];
                            
                            if (isSuccesed) {
                                
                                NSString *path = [outputPath absoluteString];
                                
                                NSLog(@">>>>>>>>>>>>>success and path is : %@",path);
                                
                                LYZEditAudioFinishViewController *finishVC = [[LYZEditAudioFinishViewController alloc] init];
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
