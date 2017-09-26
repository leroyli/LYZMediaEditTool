# LYZMediaEditTool
一款用于音视频合成、音频合成、音视频剪辑的工具

![screenShot1](https://github.com/leroyli/LYZMediaEditTool/blob/master/LYZMediaEditToolDemo/LYZMediaEditToolDemo/ScreenShot/screenShot1.PNG)

![screenShot2](https://github.com/leroyli/LYZMediaEditTool/blob/master/LYZMediaEditToolDemo/LYZMediaEditToolDemo/ScreenShot/screenShot2.PNG)

![screenShot3](https://github.com/leroyli/LYZMediaEditTool/blob/master/LYZMediaEditToolDemo/LYZMediaEditToolDemo/ScreenShot/screenShot3.png)

![screenShot4](https://github.com/leroyli/LYZMediaEditTool/blob/master/LYZMediaEditToolDemo/LYZMediaEditToolDemo/ScreenShot/screenShot4.PNG)

![screenShot5](https://github.com/leroyli/LYZMediaEditTool/blob/master/LYZMediaEditToolDemo/LYZMediaEditToolDemo/ScreenShot/screenShot5.PNG)

![screenShot6](https://github.com/leroyli/LYZMediaEditTool/blob/master/LYZMediaEditToolDemo/LYZMediaEditToolDemo/ScreenShot/screenShot6.PNG)

### 使用方法
可以直接拖入工程使用，也可使用CocoaPoda引入使用`pod search LYZMediaEditTool`

### 使用举例
```
/** 音视频合并 */
[LYZMediaEditTool mixVideoAndAudioWithVieoPath:[self filePathName:@"abc" Type:@"mp4"]
                                          audioPath:[self filePathName:@"123" Type:@"mp3"]
                                     needVideoVoice:YES
                                        videoVolume:self.originalVoiceSlide.value
                                        audioVolume:self.BGMVoiceSlider.value
                                     outPutFileName:@"outputFile"
                                    complitionBlock:^(BOOL isSuccesed, NSURL *outputPath) {
                                        // do something...
                                        
                                    }];
```

```
/** 音频与音频合并 */
[LYZMediaEditTool mixOriginalAudio:[self filePathName:@"陈奕迅" Type:@"mp3"]
                    originalAudioVolume:0.5
                            bgAudioPath:[self filePathName:@"五环之歌" Type:@"mp3"]
                          bgAudioVolume:0.5
                         outPutFileName:@"mix"
                        completionBlock:^(BOOL isSuccesed, NSURL *outputPath) {
                            // do something...
                            
                        }];
```
