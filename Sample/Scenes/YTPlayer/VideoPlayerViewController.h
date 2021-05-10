//
//  VideoPlayerViewController.h
//  LiveEvents
//

#import <UIKit/UIKit.h>
#import <youtube_ios_player_helper/YTPlayerView.h>

@interface VideoPlayerViewController: UIViewController <YTPlayerViewDelegate>

@property(nonatomic, strong) NSString *videoId;

@property(nonatomic, strong) IBOutlet YTPlayerView *playerView;

@property(nonatomic, weak) IBOutlet UIButton *playButton;
@property(nonatomic, weak) IBOutlet UIButton *pauseButton;
@property(nonatomic, weak) IBOutlet UIButton *stopButton;
@property(nonatomic, weak) IBOutlet UITextView *statusTextView;
@property(nonatomic, weak) IBOutlet UISlider *slider;

@property(nonatomic, weak) IBOutlet UIButton *reverseButton;
@property(nonatomic, weak) IBOutlet UIButton *forwardButton;
@property(nonatomic, weak) IBOutlet UIButton *startButton;

- (IBAction) onSliderChange: (id) sender;
- (IBAction) buttonPressed: (id) sender;

@end
