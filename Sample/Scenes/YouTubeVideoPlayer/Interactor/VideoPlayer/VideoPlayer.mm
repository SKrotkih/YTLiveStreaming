//
//  VideoPlayer.mm
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

#import "VideoPlayer.h"

@implementation VideoPlayer

- (instancetype) initWithVideoId: (NSString *) videoId {
    self = [super init];
    if (self) {
        [self loadVideoWithId: videoId];
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(receivedPlaybackStartedNotification:)
                                                     name: @"Playback started"
                                                   object: nil];
    }
    return self;
}

- (void) loadVideoWithId: (NSString*) videoId {
    self.playerView = [[YTPlayerView alloc] init];
    self.playerView.delegate = self;
    // For a full list of player parameters, see the documentation for the HTML5 player
    // at: https://developers.google.com/youtube/player_parameters?playerVersion=HTML5
    NSDictionary *playerVars = @{
        @"controls": @0,
        @"playsinline": @1,
        @"autohide": @1,
        @"showinfo": @0,
        @"modestbranding": @1
    };
    [self.playerView loadWithVideoId: videoId
                          playerVars: playerVars];

}

// MARK: - YTPlayerViewDelegate protocol implementation

- (void) playerView: (YTPlayerView *) ytPlayerView didChangeToState: (YTPlayerState) state {
    NSString *message = [NSString stringWithFormat: @"Player state changed: %ld\n", (long) state];
    NSLog(@"%@", message);
}

- (void) playerView: (YTPlayerView *) playerView didPlayTime: (float)playTime {
    [self.playerView duration: ^(double result, NSError * _Nullable error) {
        float progress = playTime/result;
        NSLog(@"Progress: %f.2", progress);
        // Should be sent to the progress indicator view (like slider i.e.)
        // [self.slider setValue: progress];
    }];
}

// MARK: - API

- (void) playVideo {
    [[NSNotificationCenter defaultCenter] postNotificationName: @"Playback started"
                                                        object: self];
    [self.playerView playVideo];
}

- (void) start {
    [self.playerView seekToSeconds: 0
                    allowSeekAhead: YES];
}

- (void) stop {
    [self.playerView stopVideo];
}

- (void) pause {
    [self.playerView pauseVideo];
}

- (void) reverse {
    [self.playerView currentTime: ^(float result, NSError * _Nullable error) {
        float seekToTime = result - 30.0;
        [self.playerView seekToSeconds: seekToTime
                        allowSeekAhead: YES];
    }];
}

- (void) forward {
    [self.playerView currentTime: ^(float result, NSError * _Nullable error) {
        float seekToTime = result + 30.0;
        [self.playerView seekToSeconds: seekToTime
                        allowSeekAhead: YES];
    }];
}

- (void) seekToTime: (float) time {
    [self.playerView duration: ^(double result, NSError * _Nullable error) {
        float seekToTime = result * time;
        [self.playerView seekToSeconds: seekToTime
                        allowSeekAhead: YES];
    }];
}

// MARK: - Private methods

- (void) receivedPlaybackStartedNotification: (NSNotification *) notification {
    if ([notification.name isEqual: @"Playback started"] && notification.object != self) {
        [self pause];
    }
}

@end
