//
//  GameViewController.h
//  FallingBall
//

//  Copyright (c) 2014 Georges Kanaan. All rights reserved.
//

// Frameworks
#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import <AVFoundation/AVFoundation.h>
#import <GameKit/GameKit.h>
#import <GoogleMobileAds/GADBannerView.h>

// Scenes
#import "MainScene.h"

@interface GameViewController : UIViewController

@property (nonatomic) BOOL canShowAD;
@property (strong, nonatomic) AVAudioPlayer *backgroundPlayer;

- (void)canShowAdChanged;
- (void)reportScore:(int64_t)score forLeaderboardID:(NSString*)identifier;
- (void)presentLeaderboards;

@end
