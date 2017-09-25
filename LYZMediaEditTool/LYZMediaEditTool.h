//
//  LYZMediaEditTool.h
//  LYZMediaEditTool
//
//  Created by artios on 2017/9/25.
//  Copyright © 2017年 artios. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>


typedef NS_ENUM(NSUInteger, LYZMediaType) {
    LYZMediaTypeVideo,
    LYZMediaTypeAudio,
};

typedef void(^CompletionBlock)(BOOL isSuccesed,NSURL *outputPath);

@interface LYZMediaEditTool : NSObject

/**
 音视频合成
 
 @param videoPath 原始视频路径
 @param audioPath 背景音乐路径
 @param needVideoVoice 是否添加原视频的声音
 @param videoVolume 视频音量
 @param audioVolume 背景音乐音量
 @param completionBlock 合成后的回调
 */
+ (void)mixVideoAndAudioWithVieoPath:(NSURL *)videoPath
                           audioPath:(NSURL *)audioPath
                      needVideoVoice:(BOOL)needVideoVoice
                         videoVolume:(CGFloat)videoVolume
                         audioVolume:(CGFloat)audioVolume
                      outPutFileName:(NSString *)fileName
                     complitionBlock:(CompletionBlock)completionBlock;


/**
 音频合成
 
 @param originalAudioPath 原音频路径
 @param originalAudioVolume 原音频音量
 @param bgAudioPath 背景音频路径
 @param bgAudioVolume 背景音频音量
 @param fileName 合成之后的文件名
 @param completionBlock 完成后的回调
 */
+ (void)mixOriginalAudio:(NSURL *)originalAudioPath
     originalAudioVolume:(float)originalAudioVolume
             bgAudioPath:(NSURL *)bgAudioPath
           bgAudioVolume:(float)bgAudioVolume
          outPutFileName:(NSString *)fileName
         completionBlock:(CompletionBlock)completionBlock;

/**
 音视频剪辑
 
 @param mediaType 选择类型（音频 or 视频）
 @param mediaPath 路径
 @param startTime 开始时间
 @param endTime 结束时间
 @param fileName 保存的文件名
 @param completionBlock 完成后的回调
 */
+ (void)cutMediaWithMediaType:(LYZMediaType)mediaType
                    mediaPath:(NSURL *)mediaPath
                    startTime:(CGFloat)startTime
                      endTime:(CGFloat)endTime
               outPutFileName:(NSString *)fileName
              complitionBlock:(CompletionBlock)completionBlock;



@end
