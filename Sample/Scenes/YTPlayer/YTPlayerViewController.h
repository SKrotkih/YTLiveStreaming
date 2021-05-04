//
//  YTPlayerViewController.h
//  LiveEvents
//
//  Created by Сергей Кротких on 04.05.2021.
//  Copyright © 2021 Sergey Krotkih. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <youtube_ios_player_helper/YTPlayerView.h>

NS_ASSUME_NONNULL_BEGIN

@interface YTPlayerViewController : UIViewController<YTPlayerViewDelegate>

@property(nonatomic, strong) IBOutlet YTPlayerView *playerView;

@property(nonatomic, weak) IBOutlet UIButton *playButton;
@property(nonatomic, weak) IBOutlet UIButton *pauseButton;
@property(nonatomic, weak) IBOutlet UIButton *stopButton;
@property(nonatomic, weak) IBOutlet UIButton *startButton;
@property(nonatomic, weak) IBOutlet UIButton *reverseButton;
@property(nonatomic, weak) IBOutlet UIButton *forwardButton;
@property(nonatomic, weak) IBOutlet UITextView *statusTextView;

@property(nonatomic, weak) IBOutlet UISlider *slider;

- (IBAction)onSliderChange:(id)sender;

- (IBAction)buttonPressed:(id)sender;

@end

NS_ASSUME_NONNULL_END
