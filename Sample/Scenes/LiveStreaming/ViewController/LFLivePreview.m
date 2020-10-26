//
//  LFLivePreview.m
//  LFLiveKit
//
//  Created by 倾慕 on 16/5/2.
//  Copyright © 2016年 live Interactive. All rights reserved.
//

//
// https://github.com/LaiFengiOS/LFLiveKit/tree/master
// https://github.com/BradLarson/GPUImage
//

#import "LFLivePreview.h"
#import "UIControl+YYAdd.h"
#import "UIView+YYAdd.h"
#import "LFLiveKit.h"

inline static NSString* formatedSpeed(float bytes, float elapsed_milli) {
    if (elapsed_milli <= 0) {
        return @"N/A";
    }

    if (bytes <= 0) {
        return @"0 KB/s";
    }

    float bytes_per_sec = ((float)bytes) * 1000.f /  elapsed_milli;
    if (bytes_per_sec >= 1000 * 1000) {
        return [NSString stringWithFormat:@"%.2f MB/s", ((float)bytes_per_sec) / 1000 / 1000];
    } else if (bytes_per_sec >= 1000) {
        return [NSString stringWithFormat:@"%.1f KB/s", ((float)bytes_per_sec) / 1000];
    } else {
        return [NSString stringWithFormat:@"%ld B/s", (long)bytes_per_sec];
    }
}

@interface LFLivePreview () <LFLiveSessionDelegate>

@property (nonatomic, strong) LFLiveDebug* debugInfo;
@property (nonatomic, strong) LFLiveSession* session;

@property (nonatomic, strong) UILabel* stateLabel;
@property (nonatomic, copy) NSString* streamURL;

@end

@implementation LFLivePreview

- (void) prepareForUsing {
   [self requestAccessForVideo];
   [self requestAccessForAudio];
}

#pragma mark -- Public Method

- (void) requestAccessForVideo {
    __weak typeof(self) _self = self;
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
    case AVAuthorizationStatusNotDetermined: {
        // Диалог Лицензия не появляется, запуск Лицензия
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler: ^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_self.session setRunning: YES];
                    });
                }
            }];
        break;
    }
    case AVAuthorizationStatusAuthorized: {
        // Он открыл разрешено продолжать
        dispatch_async(dispatch_get_main_queue(), ^{
            [_self.session setRunning: YES];
        });
        break;
    }
    case AVAuthorizationStatusDenied:
    case AVAuthorizationStatusRestricted:
        // Пользователь явно отказано в разрешении, или не может получить доступ к устройству камеры
        break;
    default:
        break;
    }
}

- (void) requestAccessForAudio {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (status) {
    case AVAuthorizationStatusNotDetermined: {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            }];
        break;
    }
    case AVAuthorizationStatusAuthorized: {
        break;
    }
    case AVAuthorizationStatusDenied:
    case AVAuthorizationStatusRestricted:
        break;
    default:
        break;
    }
}

#pragma mark -- LFStreamingSessionDelegate
/** live status changed will callback */

- (void) liveSession: (nullable LFLiveSession*) session liveStateDidChange: (LFLiveState) state {

   NSLog(@"liveStateDidChange: %ld", state);
   
   switch (state) {
    case LFLiveReady:
        _stateLabel.text = @"No connect";
        break;
    case LFLivePending:
        _stateLabel.text = @"Connecting...";
        break;
    case LFLiveStart:
        _stateLabel.text = @"Connected";
        break;
    case LFLiveError:
        _stateLabel.text = @"Connection error";
        break;
    case LFLiveStop:
        _stateLabel.text = @"No Connected";
        break;
    default:
        break;
    }
}

/** live debug info callback */

- (void) liveSession: (nullable LFLiveSession*) session debugInfo: (nullable LFLiveDebug*)debugInfo {
    NSLog(@"debugInfo uploadSpeed: %@", formatedSpeed(debugInfo.currentBandwidth, debugInfo.elapsedMilli));
}

/** callback socket errorcode */
- (void) liveSession: (nullable LFLiveSession*) session errorCode: (LFLiveSocketErrorCode)errorCode {
    NSLog(@"errorCode: %ld", errorCode);
}

#pragma mark -- Getter Setter

- (LFLiveSession *)session {
    if (!_session) {
        /**      发现大家有不会用横屏的请注意啦，横屏需要在ViewController  supportedInterfaceOrientations修改方向  默认竖屏  ****/
        /**      发现大家有不会用横屏的请注意啦，横屏需要在ViewController  supportedInterfaceOrientations修改方向  默认竖屏  ****/
        /**      发现大家有不会用横屏的请注意啦，横屏需要在ViewController  supportedInterfaceOrientations修改方向  默认竖屏  ****/


        /***   Default resolution 368 * 640 Audio: 44.1 iphone6 above 48 dual-channel vertical screen direction ***/
        LFLiveVideoConfiguration *videoConfiguration = [LFLiveVideoConfiguration new];
        videoConfiguration.videoSize = CGSizeMake(1280, 720);
        videoConfiguration.videoBitRate = 800*1024;
        videoConfiguration.videoMaxBitRate = 1000*1024;
        videoConfiguration.videoMinBitRate = 500*1024;
        videoConfiguration.videoFrameRate = 24;
        videoConfiguration.videoMaxKeyframeInterval = 48;
        videoConfiguration.outputImageOrientation = UIInterfaceOrientationLandscapeLeft;
        videoConfiguration.autorotate = NO;
        videoConfiguration.sessionPreset = LFCaptureSessionPreset720x1280;
        _session = [[LFLiveSession alloc] initWithAudioConfiguration:[LFLiveAudioConfiguration defaultConfiguration] videoConfiguration:videoConfiguration captureType:LFLiveCaptureDefaultMask];

        /**    Customize your own mono  */
        /*
           LFLiveAudioConfiguration *audioConfiguration = [LFLiveAudioConfiguration new];
           audioConfiguration.numberOfChannels = 1;
           audioConfiguration.audioBitrate = LFLiveAudioBitRate_64Kbps;
           audioConfiguration.audioSampleRate = LFLiveAudioSampleRate_44100Hz;
           _session = [[LFLiveSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:[LFLiveVideoConfiguration defaultConfiguration]];
         */

        /**    Customize your own high-quality audio 96K */
        /*
           LFLiveAudioConfiguration *audioConfiguration = [LFLiveAudioConfiguration new];
           audioConfiguration.numberOfChannels = 2;
           audioConfiguration.audioBitrate = LFLiveAudioBitRate_96Kbps;
           audioConfiguration.audioSampleRate = LFLiveAudioSampleRate_44100Hz;
           _session = [[LFLiveSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:[LFLiveVideoConfiguration defaultConfiguration]];
         */

        /**    Own custom high-quality audio 96K resolution set to 540 * 960 direction vertical screen */

        /*
           LFLiveAudioConfiguration *audioConfiguration = [LFLiveAudioConfiguration new];
           audioConfiguration.numberOfChannels = 2;
           audioConfiguration.audioBitrate = LFLiveAudioBitRate_96Kbps;
           audioConfiguration.audioSampleRate = LFLiveAudioSampleRate_44100Hz;

           LFLiveVideoConfiguration *videoConfiguration = [LFLiveVideoConfiguration new];
           videoConfiguration.videoSize = CGSizeMake(540, 960);
           videoConfiguration.videoBitRate = 800*1024;
           videoConfiguration.videoMaxBitRate = 1000*1024;
           videoConfiguration.videoMinBitRate = 500*1024;
           videoConfiguration.videoFrameRate = 24;
           videoConfiguration.videoMaxKeyframeInterval = 48;
           videoConfiguration.orientation = UIInterfaceOrientationPortrait;
           videoConfiguration.sessionPreset = LFCaptureSessionPreset540x960;

           _session = [[LFLiveSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:videoConfiguration];
         */


        /**    自己定制高质量音频128K 分辨率设置为720*1280 方向竖屏 */

        /*
           LFLiveAudioConfiguration *audioConfiguration = [LFLiveAudioConfiguration new];
           audioConfiguration.numberOfChannels = 2;
           audioConfiguration.audioBitrate = LFLiveAudioBitRate_128Kbps;
           audioConfiguration.audioSampleRate = LFLiveAudioSampleRate_44100Hz;

           LFLiveVideoConfiguration *videoConfiguration = [LFLiveVideoConfiguration new];
           videoConfiguration.videoSize = CGSizeMake(720, 1280);
           videoConfiguration.videoBitRate = 800*1024;
           videoConfiguration.videoMaxBitRate = 1000*1024;
           videoConfiguration.videoMinBitRate = 500*1024;
           videoConfiguration.videoFrameRate = 15;
           videoConfiguration.videoMaxKeyframeInterval = 30;
           videoConfiguration.landscape = NO;
           videoConfiguration.sessionPreset = LFCaptureSessionPreset360x640;

           _session = [[LFLiveSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:videoConfiguration];
         */


        /**    自己定制高质量音频128K 分辨率设置为720*1280 方向横屏  */

        /*
           LFLiveAudioConfiguration *audioConfiguration = [LFLiveAudioConfiguration new];
           audioConfiguration.numberOfChannels = 2;
           audioConfiguration.audioBitrate = LFLiveAudioBitRate_128Kbps;
           audioConfiguration.audioSampleRate = LFLiveAudioSampleRate_44100Hz;

           LFLiveVideoConfiguration *videoConfiguration = [LFLiveVideoConfiguration new];
           videoConfiguration.videoSize = CGSizeMake(1280, 720);
           videoConfiguration.videoBitRate = 800*1024;
           videoConfiguration.videoMaxBitRate = 1000*1024;
           videoConfiguration.videoMinBitRate = 500*1024;
           videoConfiguration.videoFrameRate = 15;
           videoConfiguration.videoMaxKeyframeInterval = 30;
           videoConfiguration.landscape = YES;
           videoConfiguration.sessionPreset = LFCaptureSessionPreset720x1280;

           _session = [[LFLiveSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:videoConfiguration];
        */

        _session.delegate = self;
        _session.showDebugInfo = NO;
        _session.preView = self;
        
        /*本地存储*/
//        _session.saveLocalVideo = YES;
//        NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.mp4"];
//        unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
//        NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
//        _session.saveLocalVideoPath = movieURL;
        
        /*
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.alpha = 0.8;
        imageView.frame = CGRectMake(100, 100, 29, 29);
        imageView.image = [UIImage imageNamed:@"ios-29x29"];
        _session.warterMarkView = imageView;*/
        
    }
    return _session;
}

- (UILabel*) stateLabel {
    if (!_stateLabel) {
        _stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 80, 40)];
        _stateLabel.text = @"Not Connected";
        _stateLabel.textColor = [UIColor whiteColor];
        _stateLabel.font = [UIFont boldSystemFontOfSize:14.f];
    }
    return _stateLabel;
}


- (void) changeCameraPosition {
   AVCaptureDevicePosition devicePositon = self.session.captureDevicePosition;
   self.session.captureDevicePosition = (devicePositon == AVCaptureDevicePositionBack) ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
}

- (BOOL) changeBeauty {
   self.session.beautyFace = !self.session.beautyFace;
   return !self.session.beautyFace;
}

- (void) startPublishingWithStreamURL: (NSString*) streamURL {
   LFLiveStreamInfo* stream = [LFLiveStreamInfo new];
   stream.url = streamURL;  // @"rtmp://live.hkstv.hk.lxdns.com:1935/live/stream153";
   NSLog(@"STREAM URL=%@", streamURL);
   [self.session startLive: stream];
}

- (void) stopPublishing {
   [self.session stopLive];
}

@end

