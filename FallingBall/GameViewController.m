//
//  GameViewController.m
//  FallingBall
//
//  Created by Georges Kanaan on 6/10/14.
//  Copyright (c) 2014 Georges Kanaan. All rights reserved.
//

#import "GameViewController.h"

#define kLeaderboardID "Main"

@interface GameViewController () <GKGameCenterControllerDelegate, GADBannerViewDelegate> {
  BOOL adAvailable;
  BOOL admobIsShowing;
}

@end

@implementation GameViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  // Set the player
  // Enable music if the setting allows it
  if ([[NSUserDefaults standardUserDefaults] boolForKey:@"music"]) {
    NSURL *backgroundMusicURL = [[NSBundle mainBundle] URLForResource:@"FallingBall" withExtension:@"m4a"];
    self.backgroundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:nil];
    [self.backgroundPlayer prepareToPlay];
    
    self.backgroundPlayer.numberOfLoops = -1;
    
    [self.backgroundPlayer play];
  }
}

-(void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  // Show the ad
  adAvailable = NO;// No ads are available
  
  GADBannerView *bannerView = [[GADBannerView alloc] initWithAdSize:GADAdSizeFullWidthLandscapeWithHeight(40) origin:CGPointMake(0, self.view.frame.size.height-90)];
  
  bannerView.adUnitID = @"ca-app-pub-2991268085925645/8694075810";
  bannerView.rootViewController = self;
  bannerView.delegate = self;
  bannerView.tag = 4;
  bannerView.alpha = 0.0;
  
  [self.view addSubview:bannerView];
  [self.view bringSubviewToFront:bannerView];
  
  GADRequest *request = [GADRequest request];
  
  [bannerView loadRequest:request];
  
  // Add the ad to the view and bring it to the front
  [self.view addSubview:bannerView];
  [self.view bringSubviewToFront:bannerView];
}

- (void)viewWillLayoutSubviews {
  [super viewWillLayoutSubviews];
  
  // Authenticate the user for Game Center
  [self authenticateLocalPlayer];
  
  // Configure the view scene
  SKView *skView = (SKView *)self.view;
  
  // Configure the view scene
  if (!skView.scene) {
    // Create and configure the scene
    MainScene *scene = [[MainScene alloc] initWithSize:skView.bounds.size start:YES];
    scene.scaleMode = SKSceneScaleModeAspectFit;
    scene.gameViewController = self;
    
    // Present the scene
    [skView presentScene:scene];
  }
}

#pragma mark - Game Center
- (void)authenticateLocalPlayer {
  __weak GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
  localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
    if (viewController != nil) {
      // Pause the game if the user is playing
      SKView *skView = (SKView *)self.view;
      if ([skView.scene isKindOfClass:[GameScene class]]) {
        GameScene *gameScene = (GameScene *)skView.scene;
        [gameScene pauseGame];
      }
      
      // Present the authentication view controller
      [self presentViewController:viewController animated:YES completion:nil];
      
    } else if (localPlayer.isAuthenticated) {
      // The player is authenticated enable game center
      [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"GameCenter"];
      
      // Get player highscore
      [self downloadHighscoreForPlayer:localPlayer];
      
      // Update the game scene HUD
      SKView *skView = (SKView *)self.view;
      if ([skView.scene isKindOfClass:[MainScene class]]) {
        MainScene *mainScene = (MainScene *)skView.scene;
        [mainScene setupGameCenterHUD];
      }
      
    } else {
      // Disable game center
      [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"GameCenter"];
    }
    
    if (error) {
      NSLog(@"error authenticating user: %@", error);
    }
  };
}

- (void)downloadHighscoreForPlayer:(GKLocalPlayer *)localPlayer {
  GKLeaderboard *leaderboardRequest = [[GKLeaderboard alloc] init];
  leaderboardRequest.identifier = @kLeaderboardID;
  [leaderboardRequest loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error) {
    if (error) {
      NSLog(@"Error getting player highscore from Game Center: %@", error);
    }
    
    if (scores) {
      GKScore *localPlayerScore = leaderboardRequest.localPlayerScore;
      int64_t GKhighscore = localPlayerScore.value;
      if (GKhighscore < [[NSUserDefaults standardUserDefaults] integerForKey:@"highscore"]) {
        [self reportScore:(int64_t)[[NSUserDefaults standardUserDefaults] integerForKey:@"highscore"] forLeaderboardID:@kLeaderboardID];
      } else {
        // Save the score as the highscore
        [[NSUserDefaults standardUserDefaults] setInteger:(NSInteger)GKhighscore forKey:@"highscore"];
      }
    }
  }];
}

- (void)reportScore:(int64_t)score forLeaderboardID:(NSString*)identifier {
  GKScore *scoreReporter = [[GKScore alloc] initWithLeaderboardIdentifier:@"Main"];
  scoreReporter.value = score;
  
  NSArray *scores = @[scoreReporter];
  [GKScore reportScores:scores withCompletionHandler:^(NSError *error) {
    if (error) NSLog(@"error reporting score: %@", error);
  }];
}

- (void)presentLeaderboards {
  
  GKGameCenterViewController *gameCenterController = [GKGameCenterViewController new];
  gameCenterController.viewState = GKGameCenterViewControllerStateLeaderboards;
  gameCenterController.gameCenterDelegate = self;
  [self presentViewController:gameCenterController animated:YES completion:nil];
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController {
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - GADBannerViewDdelegate
-(void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
  adAvailable = NO;// No ads are available
  [UIView animateWithDuration:0.2 animations:^{view.alpha = 0.0;}];// Animate the banner out
}

-(void)adViewDidReceiveAd:(GADBannerView *)view {
  adAvailable = YES;// Ads are available
  if (self.canShowAD && view.alpha == 0.0) {//make sure we are allowed to show ad
    [UIView animateWithDuration:0.2 animations:^{view.alpha = 1.0;}];// Animate the banner in
  }
}

-(void)adViewWillLeaveApplication:(GADBannerView *)adView {
  SKView *skView = (SKView *)self.view;
  if ([skView.scene isKindOfClass:[GameScene class]]) {
    GameScene *gameScene = (GameScene *)skView.scene;
    [gameScene pauseGame];
  }
}


-(void)canShowAdChanged {
  if (!self.canShowAD) {// canShowAd was changed to NO then hide the iad banner
    [UIView animateWithDuration:0.2 animations:^{[self.view viewWithTag:3].alpha = 0.0; [self.view viewWithTag:4].alpha = 0.0;}];// Animate the banner out
    
  } else if (adAvailable) {// Otherwise it was yes and we have an ad available then show it
    [UIView animateWithDuration:0.2 animations:^{[self.view viewWithTag:3].alpha = 1.0; [self.view viewWithTag:4].alpha = 1.0;}];// Animate the banner in
  }
}

@end
