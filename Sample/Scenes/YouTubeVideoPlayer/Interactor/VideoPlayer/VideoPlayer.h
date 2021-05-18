//
//  VideoPlayer.h
//  LiveEvents
//
//  Created by Sergey Krotkih
//

#import <UIKit/UIKit.h>
#import <youtube_ios_player_helper/YTPlayerView.h>

@interface VideoPlayer: NSObject <YTPlayerViewDelegate>

@property(nonatomic, strong) YTPlayerView *playerView;

- (instancetype) initWithVideoId: (NSString *)videoId;

- (void) playVideo;
- (void) start;
- (void) stop;
- (void) pause;
- (void) reverse;
- (void) forward;
- (void) seekToTime: (float) time;

@end
