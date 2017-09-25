//
//  LYZMediaEditTool.m
//  LYZMediaEditTool
//
//  Created by artios on 2017/9/25.
//  Copyright © 2017年 artios. All rights reserved.
//

#import "LYZMediaEditTool.h"

@implementation LYZMediaEditTool

#pragma mark - 音频与视频的合并
+ (void)mixVideoAndAudioWithVieoPath:(NSURL *)videoPath
                           audioPath:(NSURL *)audioPath
                      needVideoVoice:(BOOL)needVideoVoice
                         videoVolume:(CGFloat)videoVolume
                         audioVolume:(CGFloat)audioVolume
                      outPutFileName:(NSString *)fileName
                     complitionBlock:(CompletionBlock)completionBlock
{
    if (videoPath == nil) {
        return;
    }
    if (audioPath == nil) {
        return;
    }
    if (videoVolume > 1.0) {
        videoVolume = 1.0f;
    }
    if (videoVolume < 0.0) {
        videoVolume = 0.0f;
    }
    if (audioVolume > 1.0) {
        audioVolume = 1.0f;
    }
    if (audioVolume < 0.0) {
        audioVolume = 0.0f;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        AVAsset *asset      = [AVAsset assetWithURL:videoPath];
        AVAsset *audioAsset = [AVAsset assetWithURL:audioPath];
        
        CMTime duration = asset.duration;
        CMTimeRange video_timeRange = CMTimeRangeMake(kCMTimeZero, duration);
        
        AVAssetTrack *videoAssetTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        AVAssetTrack *audioAssetTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
        
        AVMutableComposition *composition = [[AVMutableComposition alloc]init];
        
        /** 视频素材加入视频轨道 */
        AVMutableCompositionTrack *videoCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [videoCompositionTrack insertTimeRange:video_timeRange ofTrack:videoAssetTrack atTime:kCMTimeZero error:nil];
        
        /** 音频素材加入音频轨道 */
        AVMutableCompositionTrack *audioCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [audioCompositionTrack insertTimeRange:video_timeRange ofTrack:audioAssetTrack atTime:kCMTimeZero error:nil];
        
        /** 是否加入视频原声 */
        AVMutableCompositionTrack *originalAudioCompositionTrack = nil;
        if (needVideoVoice) {
            AVAssetTrack *originalAudioAssetTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
            originalAudioCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            [originalAudioCompositionTrack insertTimeRange:video_timeRange ofTrack:originalAudioAssetTrack atTime:kCMTimeZero error:nil];
        }
        
        AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetMediumQuality];
        
        /** 设置输出路径 */
        NSURL *outputPath = [self exporterPathWithFileName:fileName];
        exporter.outputURL = outputPath;
        exporter.outputFileType = AVFileTypeQuickTimeMovie;
        exporter.shouldOptimizeForNetworkUse = YES;
        
        /** 音量控制 */
        exporter.audioMix = [self buildAudioMixWithVideoTrack:originalAudioCompositionTrack
                                                  VideoVolume:videoVolume
                                                   audioTrack:audioCompositionTrack
                                                  audioVolume:audioVolume
                                                       atTime:kCMTimeZero];
        
        [exporter exportAsynchronouslyWithCompletionHandler:^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                switch ([exporter status]) {
                        
                    case AVAssetExportSessionStatusFailed: {
                        NSLog(@"合成失败：%@",[[exporter error] description]);
                        completionBlock(NO,outputPath);
                    }
                        break;
                        
                    case AVAssetExportSessionStatusCancelled: {
                        completionBlock(NO,outputPath);
                    }
                        break;
                        
                    case AVAssetExportSessionStatusCompleted: {
                        completionBlock(YES,outputPath);
                    }
                        break;
                        
                    default: {
                        completionBlock(NO,outputPath);
                    }
                        break;
                }
            });
            
            
        }];
        
    });
    
    
}

#pragma mark - 调节合成的音量
+ (AVAudioMix *)buildAudioMixWithVideoTrack:(AVCompositionTrack *)videoTrack
                                VideoVolume:(float)videoVolume
                                 audioTrack:(AVCompositionTrack *)audioTrack
                                audioVolume:(float)audioVolume
                                     atTime:(CMTime)volumeRange
{
    
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    
    AVMutableAudioMixInputParameters *videoParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:videoTrack];
    [videoParameters setVolume:videoVolume atTime:volumeRange];
    
    AVMutableAudioMixInputParameters *audioParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioTrack];
    [audioParameters setVolume:audioVolume atTime:volumeRange];
    
    audioMix.inputParameters = @[videoParameters,audioParameters];
    
    return audioMix;
}

#pragma mark - 剪辑音视频
+ (void)cutMediaWithMediaType:(LYZMediaType)mediaType
                    mediaPath:(NSURL *)mediaPath
                    startTime:(CGFloat)startTime
                      endTime:(CGFloat)endTime
               outPutFileName:(NSString *)fileName
              complitionBlock:(CompletionBlock)completionBlock
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        AVAsset *asset = [AVAsset assetWithURL:mediaPath];
        
        AVAssetExportSession *exporter;
        
        if (mediaType == LYZMediaTypeAudio) {
            
            exporter = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetAppleM4A];
            
        } else if (mediaType == LYZMediaTypeVideo) {
            
            exporter = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetPassthrough];
        }
        
        /** 剪辑(设置导出的时间段) */
        CMTime start = CMTimeMakeWithSeconds(startTime, asset.duration.timescale);
        CMTime duration = CMTimeMakeWithSeconds(endTime - startTime,asset.duration.timescale);
        exporter.timeRange = CMTimeRangeMake(start, duration);
        
        NSURL *outputPath;
        
        if (mediaType == LYZMediaTypeAudio) {
            
            exporter.outputFileType = AVFileTypeAppleM4A;
            outputPath = [self exporterAudioPathWithFileName:fileName];
            exporter.outputURL = [self exporterAudioPathWithFileName:fileName];
            
        } else if (mediaType == LYZMediaTypeVideo) {
            
            exporter.outputFileType = AVFileTypeAppleM4V;
            outputPath = [self exporterPathWithFileName:fileName];
            exporter.outputURL = [self exporterPathWithFileName:fileName];
        }
        
        exporter.shouldOptimizeForNetworkUse = YES;
        
        /** 合成后的回调 */
        [exporter exportAsynchronouslyWithCompletionHandler:^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                switch ([exporter status]) {
                        
                    case AVAssetExportSessionStatusFailed: {
                        NSLog(@"合成失败：%@",[[exporter error] description]);
                        completionBlock(NO,outputPath);
                    }
                        break;
                        
                    case AVAssetExportSessionStatusCancelled: {
                        completionBlock(NO,outputPath);
                    }
                        break;
                        
                    case AVAssetExportSessionStatusCompleted: {
                        completionBlock(YES,outputPath);
                    }
                        break;
                        
                    default: {
                        completionBlock(NO,outputPath);
                    }
                        break;
                }
                
            });
            
            
        }];
    });
    
    
    
}

#pragma mark - 音频与音频的合并
+ (void)mixOriginalAudio:(NSURL *)originalAudioPath
     originalAudioVolume:(float)originalAudioVolume
             bgAudioPath:(NSURL *)bgAudioPath
           bgAudioVolume:(float)bgAudioVolume
          outPutFileName:(NSString *)fileName
         completionBlock:(CompletionBlock)completionBlock
{
    if (originalAudioPath == nil) {
        return;
    }
    if (bgAudioPath == nil) {
        return;
    }
    if (originalAudioVolume > 1.0) {
        originalAudioVolume = 1.0f;
    }
    if (originalAudioVolume < 0) {
        originalAudioVolume = 0.0f;
    }
    if (bgAudioVolume > 1.0) {
        bgAudioVolume = 1.0f;
    }
    if (bgAudioVolume < 0) {
        bgAudioVolume = 0.0f;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        AVURLAsset *originalAudioAsset = [AVURLAsset assetWithURL:originalAudioPath];
        AVURLAsset *bgAudioAsset       = [AVURLAsset assetWithURL:bgAudioPath];
        
        AVMutableComposition *compostion   = [AVMutableComposition composition];
        
        AVMutableCompositionTrack *originalAudio = [compostion addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:0];
        [originalAudio insertTimeRange:CMTimeRangeMake(kCMTimeZero, originalAudioAsset.duration) ofTrack:[originalAudioAsset tracksWithMediaType:AVMediaTypeAudio].firstObject atTime:kCMTimeZero error:nil];
        
        AVMutableCompositionTrack *bgAudio = [compostion addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:0];
        [bgAudio insertTimeRange:CMTimeRangeMake(kCMTimeZero, bgAudioAsset.duration) ofTrack:[bgAudioAsset tracksWithMediaType:AVMediaTypeAudio].firstObject atTime:kCMTimeZero error:nil];
        
        /** 得到对应轨道中的音频声音信息，并更改 */
        AVMutableAudioMixInputParameters *originalAudioParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:originalAudio];
        [originalAudioParameters setVolume:originalAudioVolume atTime:kCMTimeZero];
        
        AVMutableAudioMixInputParameters *bgAudioParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:bgAudio];
        [originalAudioParameters setVolume:bgAudioVolume atTime:kCMTimeZero];
        
        /** 赋给对应的类 */
        AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
        audioMix.inputParameters = @[originalAudioParameters,bgAudioParameters];
        
        AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:compostion presetName:AVAssetExportPresetAppleM4A];
        
        /** 设置输出路径 */
        NSURL *outputPath = [self exporterAudioPathWithFileName:fileName];
        
        session.audioMix       = audioMix;
        session.outputURL      = outputPath;
        session.outputFileType = AVFileTypeAppleM4A;
        session.shouldOptimizeForNetworkUse = YES;
        
        [session exportAsynchronouslyWithCompletionHandler:^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                switch ([session status]) {
                        
                    case AVAssetExportSessionStatusFailed: {
                        NSLog(@"合成失败：%@",[[session error] description]);
                        completionBlock(NO,outputPath);
                    }
                        break;
                        
                    case AVAssetExportSessionStatusCancelled: {
                        completionBlock(NO,outputPath);
                    }
                        break;
                        
                    case AVAssetExportSessionStatusCompleted: {
                        completionBlock(YES,outputPath);
                        
                    }
                        break;
                        
                    default: {
                        completionBlock(NO,outputPath);
                    }
                        break;
                }
                
            });
            
            
        }];
        
    });
    
    
    
}

#pragma mark - 视频输出路径
+ (NSURL *)exporterPathWithFileName:(NSString *)outPutfileName
{
    NSString *fileName = [NSString stringWithFormat:@"%@.mp4",outPutfileName];
    
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *directoryName = @"editVideo";
    
    BOOL createDir = [self createDirWihtName:directoryName];
    
    if (createDir) {
        NSString *directory = [cachePath stringByAppendingPathComponent:directoryName];
        NSString *outputFilePath = [directory stringByAppendingPathComponent:fileName];
        
        if([[NSFileManager defaultManager] fileExistsAtPath:outputFilePath]) {
            
            [[NSFileManager defaultManager] removeItemAtPath:outputFilePath error:nil];
        }
        
        return [NSURL fileURLWithPath:outputFilePath];
    }
    
    return nil;
}

#pragma mark - 音频输出路径
+ (NSURL *)exporterAudioPathWithFileName:(NSString *)outPutfileName
{
    NSString *fileName = [NSString stringWithFormat:@"%@.m4a",outPutfileName];
    
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *directoryName = @"editAudio";
    
    BOOL createDir = [self createDirWihtName:directoryName];
    
    if (createDir) {
        NSString *directory = [cachePath stringByAppendingPathComponent:directoryName];
        NSString *outputFilePath = [directory stringByAppendingPathComponent:fileName];
        
        if([[NSFileManager defaultManager] fileExistsAtPath:outputFilePath]) {
            
            [[NSFileManager defaultManager] removeItemAtPath:outputFilePath error:nil];
        }
        
        return [NSURL fileURLWithPath:outputFilePath];
    }
    
    return nil;
}


/** 创建文件夹 */
+ (BOOL)createDirWihtName:(NSString *)name
{
    if (!name) {
        return NO;
    }
    
    NSString      *cachePath    = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSFileManager *fileManager  = [NSFileManager defaultManager];
    NSString      *directory    = [cachePath stringByAppendingPathComponent:name];
    // 创建目录
    BOOL res = [fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
    
    return res;
}


@end
