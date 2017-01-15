//
//  GameScene.h
//  FallingBall
//

//  Copyright (c) 2014 Georges Kanaan. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <AudioToolbox/AudioServices.h>
#import "MainScene.h"
#import "GameViewController.h"

@class GameViewController;

@interface GameScene : SKScene {
  
  float level;
  
  int ballsSpawned;
  int beforePauseBallsSpawned;
  int lives;
  
  BOOL canHitBall1;
  BOOL canHitBall2;
  BOOL canHitBall3;
  BOOL canHitHeart;
  BOOL canHitBomb;
  
  BOOL hasCreatedSecondBall;
  BOOL hasCreatedThirdBall;
  BOOL hasCreatedHeart;
  BOOL hasCreatedBomb;
  
  BOOL calledGameOver;
  
  SKLabelNode *scoreNode;
  
  SKShapeNode *ball1;
  SKShapeNode *ball2;
  SKShapeNode *ball3;
  
  SKSpriteNode *heart;
  SKSpriteNode *bomb;
  
  SKSpriteNode *livesNode;
  SKSpriteNode *pauseButtonNode;
}

@property (strong, nonatomic) GameViewController *gameViewController;

- (instancetype)initWithSize:(CGSize)size;
- (void)pauseGame;
- (void)resumeGame;

@end
