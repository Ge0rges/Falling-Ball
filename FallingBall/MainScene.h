//
//  GameOverScene.h
//  FallingBall
//
//  Created by Georges Kanaan on 6/10/14.
//  Copyright (c) 2014 Georges Kanaan. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <CoreImage/CoreImage.h>
#import "GameScene.h"
#import "GameViewController.h"

@class GameViewController;
@class GameScene;
@class SettingsScene;

@interface MainScene : SKScene {
  BOOL start;
}

@property (strong, nonatomic) GameViewController *gameViewController;

- (instancetype)initWithSize:(CGSize)size start:(BOOL)lclStart;
- (void)setupGameCenterHUD;

@end
