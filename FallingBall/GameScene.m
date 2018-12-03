//
//  GameScene.m
//  FallingBall
//
//  Created by Georges Kanaan on 6/10/14.
//  Copyright (c) 2014 Georges Kanaan. All rights reserved.
//

#import "GameScene.h"

#define kBallRadius 150.0
#define IS_OS_8_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

extern int score;// Extern so we can access it in other scenes

@implementation GameScene

#pragma mark - Configuring the scene
- (instancetype)initWithSize:(CGSize)size {
  if (self = [super initWithSize:size]) {
    
    // Set the background color
    [self setBackgroundColor:[UIColor colorWithWhite:(250/255.0) alpha:1.0]];
    
    // Setup game properties
    ballsSpawned = 0;
    level = 0.3;
    lives = 5;
    score = 0;
    
    hasCreatedHeart = NO;
    hasCreatedSecondBall = NO;
    hasCreatedThirdBall = NO;
    hasCreatedBomb = NO;
    
    canHitBall1 = YES;
    canHitBall2 = YES;
    canHitBall3 = YES;
    canHitBomb = YES;
    canHitHeart = YES;
    
    calledGameOver = NO;
    
    // Setup the feedback
    // Score label
    scoreNode = [SKLabelNode labelNodeWithFontNamed:@"Helvetica-light"];
    scoreNode.text = [NSString stringWithFormat:@"Score: %i Hits", score];
    scoreNode.fontColor = [UIColor grayColor];
    scoreNode.fontSize = 50;
    scoreNode.xScale = 0.5;
    scoreNode.yScale = 0.5;
    scoreNode.position = CGPointMake(150, self.frame.size.height-34);
    
    //lives image node
    livesNode = [SKSpriteNode spriteNodeWithImageNamed:@"5Lives"];
    livesNode.name = @"LivesNode";
    livesNode.position = CGPointMake(self.frame.size.width-80, self.frame.size.height-26);
    livesNode.xScale = 0.3;
    livesNode.yScale = 0.3;
    
    // Add pause button
    pauseButtonNode = [SKSpriteNode spriteNodeWithImageNamed:@"PauseButton"];
    pauseButtonNode.position = CGPointMake(30, self.frame.size.height-25);
    pauseButtonNode.name = @"PauseButton";//how the node is identified later
    pauseButtonNode.xScale = 0.3;
    pauseButtonNode.yScale = 0.3;
    
    // Add white top bar
    SKSpriteNode *topWhiteBar = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithWhite:1.0 alpha:1.0] size:CGSizeMake(self.frame.size.width, 100)];
    topWhiteBar.zPosition = -0.5;
    topWhiteBar.position = CGPointMake(self.frame.size.width/2, self.frame.size.height);
    topWhiteBar.blendMode = SKBlendModeMultiplyX2;
    
    [self addChild:topWhiteBar];
    [self addChild:pauseButtonNode];
    [self addChild:livesNode];
    [self addChild:scoreNode];
  }
  
  return self;
}


- (void)didMoveToView:(SKView *)view {
  /* Setup your scene here */
  // Create a physics body that borders the screen and a extra edge on the bottom
  CGRect outOfScreenRect = CGRectMake(self.frame.origin.x, self.frame.origin.y, 1, 1);
  SKPhysicsBody *borderBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:outOfScreenRect];
  self.physicsBody = borderBody;// Set physicsBody of scene to borderBody
  self.physicsBody.friction = 0.0f;// Set the friction of that physicsBody to 0
  self.physicsWorld.gravity = CGVectorMake(0.0, level*-10.0);// Set gravity to -3.0
  
  // Spawn ball
  [self spawnFirstBall];
}

#pragma mark - Handling Elimination of Objects
#pragma mark Processing Touches
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  // Get the touch location
  UITouch *touch = [touches anyObject];
  CGPoint location = [touch locationInNode:self];
  
  // Get the node at the location
  SKNode *node = [self nodeAtPoint:location];
  
  if (!self.view.paused) {// Don't waste resources
    if ([node isEqual:ball1] && canHitBall1) {// Check if the node is a ball1
      // No more hits!
      canHitBall1 = NO;
      
      // Add spark particle to ball
      SKEmitterNode *emitter =  [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"SparkParticle" ofType:@"sks"]];
      emitter.name = @"emitter1";
      emitter.position = node.position;
      emitter.particleColorSequence = [[SKKeyframeSequence alloc] initWithKeyframeValues:@[((SKShapeNode*)node).fillColor] times:@[@1]];
      [self addChild:emitter];
      
      // Fade out the ball
      [ball1 runAction:[SKAction fadeOutWithDuration:0.2]];
      
      // After the animation is done
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // Remove the ball
        [ball1 removeFromParent];
        [emitter runAction:[SKAction fadeOutWithDuration:0.2] completion:^{[emitter removeFromParent];}];
        
        // Reset the alpha
        ball1.alpha = 1.0;
        
        // Next ball
        [self spawnFirstBall];
      });
      
      // Update the score and display it
      score ++;
      [scoreNode setText:[NSString stringWithFormat:@"Score: %i Hits", score]];
      
      // Only 1 score for each hit increment variable after 0.3 to make sure we don't get 2 points or more for one hit
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        canHitBall1 = YES;
      });
      
    } else if ([node isEqual:ball2] && canHitBall2) {// Check if the node is a ball2
      // No more hits!
      canHitBall2 = NO;
      
      // Add spark particle to ball
      SKEmitterNode *emitter =  [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"SparkParticle" ofType:@"sks"]];
      emitter.name = @"emitter2";
      emitter.position = node.position;
      emitter.particleColorSequence = [[SKKeyframeSequence alloc] initWithKeyframeValues:@[((SKShapeNode*)node).fillColor] times:@[@1]];
      [self addChild:emitter];
      
      // Fade out the ball
      [ball2 runAction:[SKAction fadeOutWithDuration:0.2]];
      
      // After the animation is done
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // Remove the ball
        [ball2 removeFromParent];
        [emitter runAction:[SKAction fadeOutWithDuration:0.2] completion:^{[emitter removeFromParent];}];
        
        // Reset the alpha
        ball2.alpha = 1.0;
        
        // Next ball
        [self spawnSecondBall];
      });
      
      // Update the score and display it
      score ++;
      [scoreNode setText:[NSString stringWithFormat:@"Score: %i Hits", score]];
      
      // Only 1 score for each hit increment variable after 0.3 to make sure we don't get 2 points or more for one hit
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        canHitBall2 = YES;
      });
      
    } else if ([node isEqual:ball3] && canHitBall3) {// Check if the node is a ball3
      // No more hits!
      canHitBall3 = NO;
      
      // Add spark particle to ball
      SKEmitterNode *emitter =  [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"SparkParticle" ofType:@"sks"]];
      emitter.name = @"emitter3";
      emitter.position = node.position;
      emitter.particleColorSequence = [[SKKeyframeSequence alloc] initWithKeyframeValues:@[((SKShapeNode*)node).fillColor] times:@[@1]];
      [self addChild:emitter];
      
      // Fade out the ball
      [ball3 runAction:[SKAction fadeOutWithDuration:0.2] completion:^{[emitter removeFromParent];}];
      
      // After the animation is done
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // Remove the ball
        [ball3 removeFromParent];
        [emitter runAction:[SKAction fadeOutWithDuration:0.2]];
        
        // Reset the alpha
        ball3.alpha = 1.0;
        
        // Next ball
        [self spawnThirdBall];
      });
      
      // Update the score and display it
      score ++;
      [scoreNode setText:[NSString stringWithFormat:@"Score: %i Hits", score]];
      
      // Only 1 score for each hit increment variable after 0.3 to make sure we don't get 2 points or more for one hit
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        canHitBall3 = YES;
      });
      
    } else if ([node isEqual:heart] && canHitHeart) {// Check if the node is a ball3
      // No more hits!
      canHitHeart = NO;
      
      // Add spark particle to heart
      SKEmitterNode *emitter =  [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"HeartParticle" ofType:@"sks"]];
      emitter.name = @"emitter4";
      emitter.position = node.position;
      [self addChild:emitter];
      
      // Fade out the heart
      [heart runAction:[SKAction fadeOutWithDuration:0.2]];
      
      // After the animation is done
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // Remove the ball
        [heart removeFromParent];
        [emitter runAction:[SKAction fadeOutWithDuration:0.2] completion:^{[emitter removeFromParent];}];
        
        // Reset the alpha
        heart.alpha = 1.0;
        
        // Next heart
        [NSTimer scheduledTimerWithTimeInterval:40 target:self selector:@selector(spawnHeart) userInfo:nil repeats:NO];
      });
      
      // Update the lives and display it
      lives ++;
      [self updateLivesImageNode];
      
      // Only 1 score for each hit increment variable after 0.3 to make sure we don't get 2 lives or more for one hit
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        canHitHeart = YES;
      });
      
    } else if ([node isEqual:bomb] && canHitBomb) {// Check if the node is a ball3
      // No more hits!
      canHitBomb = NO;
      
      //vibrate the phone if the setting allows it
      if ([[NSUserDefaults standardUserDefaults] boolForKey:@"vibration"]) AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
      
      // Add spark particle to bomb
      SKEmitterNode *emitter =  [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"BombParticle" ofType:@"sks"]];
      emitter.name = @"emitter5";
      emitter.position = node.position;
      [self addChild:emitter];
      
      // Fade out the bomb
      [bomb runAction:[SKAction fadeOutWithDuration:0.2]];
      
      // After the animation is done
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // Remove the ball
        [bomb removeFromParent];
        [emitter runAction:[SKAction fadeOutWithDuration:0.2] completion:^{[emitter removeFromParent];}];
        
        // Reset the alpha
        bomb.alpha = 1.0;
        
        // Next bomb
        [NSTimer scheduledTimerWithTimeInterval:25 target:self selector:@selector(spawnBomb) userInfo:nil repeats:NO];
      });
      
      // Update the lives and display it
      lives --;
      [self updateLivesImageNode];
      
      // Only 1 score for each hit increment variable after 0.3 to make sure we don't lose 2 lives or more for one hit
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        canHitBomb = YES;
      });
    }
  }
  
  if ([node.name isEqualToString:@"PauseButton"]) {// If sound button touched
    [self pauseGame];// Pause game
    
  } else if ([node.name isEqualToString:@"PlayButton"]) {// If sound button touched
    [self resumeGame];// Start game
  }
}

#pragma mark Off Screen Object Handling

- (void)update:(CFTimeInterval)currentTime {
  /* Called before each frame is rendered */
  if (lives > 0) {//this isn't needed if we have 0 lives
    if (ball1.position.y < -ball1.frame.size.height && canHitBall1){// If the ball is off the screen completely
      // Vibrate the phone if the setting allows it
      if ([[NSUserDefaults standardUserDefaults] boolForKey:@"vibration"]) AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
      
      // Remove the ball
      [ball1 removeFromParent];
      
      // Remove a life and display it
      lives --;
      [self updateLivesImageNode];
      
      // Spawn a new ball if there are still lives
      if (lives > 0) [self spawnFirstBall];
    }
    
    if (ball2.position.y < -ball2.frame.size.height && canHitBall2){// If the ball is off the screen completely
      
      // Vibrate the phone if the setting allows it
      if ([[NSUserDefaults standardUserDefaults] boolForKey:@"vibration"]) AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
      
      // Remove the ball
      [ball2 removeFromParent];
      
      // Remove a life and display it
      lives --;
      [self updateLivesImageNode];
      
      // Spawn a new ball if there are still lives
      if (lives > 0) [self spawnSecondBall];
    }
    
    if (ball3.position.y < -ball3.frame.size.height && canHitBall3){// If the ball is off the screen completely
      // Vibrate the phone if the setting allows it
      if ([[NSUserDefaults standardUserDefaults] boolForKey:@"vibration"]) AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
      
      // Remove the ball
      [ball3 removeFromParent];
      
      // Remove a life and display it
      lives --;
      [self updateLivesImageNode];
      
      // Spawn a new ball if there are still lives
      if (lives > 0) [self spawnThirdBall];
      
    }
    
    if (heart.position.y < -heart.frame.size.height){// If the heart is off the screen completely
      // Remove the heart
      [heart removeFromParent];
      heart = nil;
      
      // Spawn a new heart in 25 seconds
      [NSTimer scheduledTimerWithTimeInterval:25.0 target:self selector:@selector(spawnHeart) userInfo:nil repeats:NO];
    }
    
    if (bomb.position.y < -bomb.frame.size.height){// If the bomb is off the screen completely
      // Remove the bomb
      [bomb removeFromParent];
      bomb = nil;
      
      // Spawn a new bomb in 20 seconds
      [NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(spawnBomb) userInfo:nil repeats:NO];
      
    }
    
  } else if (!calledGameOver) {
    
    //make sure this isn't called twice
    calledGameOver = YES;
    
    // Present the game over scene after a second
    SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
    MainScene *gameOverScene = [[MainScene alloc] initWithSize:self.size start:NO];
    gameOverScene.gameViewController = self.gameViewController;// Pass the instance of the view controller
    
    // Present the scene
    [self.view presentScene:gameOverScene transition:reveal];
  }
}

#pragma mark - Spawning Balls, Hearts & Bombs
// Balls
- (void)spawnFirstBall {
  // Increment the ballsSpawned variable
  ballsSpawned ++;
  
  // Increment the level
  level += 0.003;
  self.physicsWorld.gravity = CGVectorMake(0.0, level*-10);
  
  // Generate a randomn UIColor for the ball
  CGFloat hue = (arc4random() % 256 / 256.0 );  //  0.0 to 1.0
  CGFloat saturation = (arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
  CGFloat brightness = (arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
  UIColor *ballColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
  
  // Assign ball and configure it if it is not already assigned
  if (!ball1) {
    // Create a ball sprite
    if (IS_OS_8_OR_LATER) {
      ball1 = [SKShapeNode shapeNodeWithCircleOfRadius:kBallRadius];
      
    } else {
      ball1 = [SKShapeNode new];
      ball1.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, kBallRadius*2, kBallRadius*2)].CGPath;
      ball1.lineWidth = kBallRadius*2;
    }
    
    // Configure global properties of the ball
    ball1.zPosition = -0.6;
    
    // Configure the balls physics
    ball1.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:kBallRadius];
    
  }
  
  // Configure the ball color
  ball1.strokeColor = [SKColor clearColor];
  ball1.fillColor = ballColor;
  
  // Configure the scale and position of the ball
  ball1.xScale = 0.3;
  ball1.yScale = 0.3;
  int x = arc4random() % (int)(self.frame.size.width/2);// Get randomn x for left portion of the screen
  if (x < ball1.frame.size.width+5 || x == 0) x = ball1.frame.size.width+5;
  
  ball1.position = CGPointMake(x, self.frame.size.height+ball1.frame.size.height);
  
  // Add the ball to the scene
  [self addChild:ball1];
  
  // If we passed a certain number of balls spawned send a second or third ball on the screen
  if (ballsSpawned >= 10 && !hasCreatedSecondBall) {// If more than 10 were already shown send a second one
    level += 0.1;
    [self spawnSecondBall];
    hasCreatedSecondBall = YES;
  }
}

- (void)spawnSecondBall {
  // Increment the ballsSpawned variable
  ballsSpawned ++;
  
  // Generate a randomn UIColor for the ball
  CGFloat hue = (arc4random() % 256 / 256.0 );  //  0.0 to 1.0
  CGFloat saturation = (arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
  CGFloat brightness = (arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
  UIColor *ballColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
  
  // Assign ball and configure it if it is not already assigned
  if (!ball2) {
    // Create a ball sprite
    if (IS_OS_8_OR_LATER) {
      ball2 = [SKShapeNode shapeNodeWithCircleOfRadius:kBallRadius];
      
    } else {
      ball2 = [SKShapeNode new];
      ball2.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, kBallRadius*2, kBallRadius*2)].CGPath;
      ball2.lineWidth = kBallRadius*2;
    }
    
    // Configure global properties of the ball
    ball2.zPosition = -0.6;
    
    // Configure the balls physics
    ball2.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:kBallRadius];
  }
  
  // Configure the ball color
  ball2.strokeColor = [SKColor clearColor];
  ball2.fillColor = ballColor;
  
  // Configure the scale and position of the ball
  ball2.xScale = 0.3;
  ball2.yScale = 0.3;
  int x = (arc4random() % (int)(self.frame.size.width/2))+self.frame.size.width/2;// Get randomn x for right portion of the screen
  if (x > self.frame.size.width-ball2.frame.size.width-5) x = self.frame.size.width-ball2.frame.size.width-5;
  
  ball2.position = CGPointMake(x, self.frame.size.height+ball2.frame.size.height);
  
  // Add the ball to the scene
  [self addChild:ball2];
  
  // If we passed a certain number of balls spawned send a third ball on the screen only in iPad
  if (ballsSpawned >= 30 && hasCreatedThirdBall == NO) {// If more than 40 balls were already shown send a third one
    level += 0.15;
    [self spawnThirdBall];
    hasCreatedThirdBall = YES;
  }
}

- (void)spawnThirdBall {
  // Increment the ballsSpawned variable
  ballsSpawned ++;
  
  // Generate a randomn UIColor for the ball
  CGFloat hue = (arc4random() % 256 / 256.0 );  //  0.0 to 1.0
  CGFloat saturation = (arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
  CGFloat brightness = (arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
  UIColor *ballColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
  
  // Assign ball and configure it if it is not already assigned
  if (!ball3) {
    // Create a ball sprite
    if (IS_OS_8_OR_LATER) {
      ball3 = [SKShapeNode shapeNodeWithCircleOfRadius:kBallRadius];
      
    } else {
      ball3 = [SKShapeNode new];
      ball3.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, kBallRadius*2, kBallRadius*2)].CGPath;
      ball3.lineWidth = kBallRadius*2;
    }
    
    // Configure global properties of the ball
    ball3.zPosition = -0.6;
    
    // Configure the balls physics
    ball3.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:kBallRadius];
  }
  
  // Configure the ball color
  ball3.strokeColor = [SKColor clearColor];
  ball3.fillColor = ballColor;
  
  // Configure the scale and position of the ball
  ball3.xScale = 0.3;
  ball3.yScale = 0.3;
  int x = (arc4random() % (int)self.frame.size.width);// Get randomn x for the whole screen
  if (x > self.frame.size.width-ball3.frame.size.width-5 || x < ball3.frame.size.width+5|| x == 0) x = self.frame.size.width-ball3.frame.size.width-5;
  
  ball3.position = CGPointMake(x, self.frame.size.height+ball3.frame.size.height);
  
  // Add the ball to the scene
  [self addChild:ball3];
  
  // Spawn heart and bomb for the first time
  if (!hasCreatedBomb && ballsSpawned > 35) {
    [self spawnBomb];
    hasCreatedBomb = YES;
  }
  
  if (!hasCreatedHeart && ballsSpawned > 40) {
    [self spawnHeart];
    hasCreatedHeart = YES;
  }
}


// Heart and bomb
- (void)spawnHeart {
  if (lives < 5) {// Make sure the user doesn't have full life
    // Assign heart and configure it if it is not already assigned
    if (!heart) {
      // Create a ball sprite
      heart = [SKSpriteNode spriteNodeWithImageNamed:@"Heart"];
      
      // Configure global properties of the ball
      heart.zPosition = -0.6;
      heart.xScale = 0.5;
      heart.yScale = 0.5;
      
      // Configure the balls physics
      heart.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:heart.frame.size.width/2];
      heart.physicsBody.allowsRotation = NO;
    }
    
    // Configure the scale and position of the heart
    int x = (arc4random() % (int)self.frame.size.width);// Get randomn x for the whole screen
    if (x > self.frame.size.width-heart.frame.size.width-5 || x < heart.frame.size.width+5|| x == 0) x = self.frame.size.width-heart.frame.size.width-5;
    
    heart.position = CGPointMake(x, self.frame.size.height+heart.frame.size.height);
    
    // Add the heart to the scene
    [self addChild:heart];
    
  } else {// Otherwise set a timer because the heart was not spawned to try again
    // Spawn a new heart in 25 seconds
    [NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(spawnHeart) userInfo:nil repeats:NO];
  }
}

- (void)spawnBomb {
  // Assign bomb and configure it if it is not already assigned
  if (!bomb) {
    // Create a ball sprite
    bomb = [SKSpriteNode spriteNodeWithImageNamed:@"Bomb"];
    
    // Configure global properties of the ball
    bomb.zPosition = -0.6;
    bomb.xScale = 0.5;
    bomb.yScale = 0.5;
    
    // Configure the balls physics
    bomb.physicsBody = [SKPhysicsBody bodyWithTexture:bomb.texture size:bomb.size];
    bomb.physicsBody.allowsRotation = NO;
    
    // Add smoke to the bomb
    SKEmitterNode *emitter =  [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"BombSmokeParticle" ofType:@"sks"]];
    emitter.name = @"emitter6";
    emitter.position = CGPointMake(bomb.frame.size.width/2, bomb.frame.size.height-5);
    
    [bomb addChild:emitter];
  }
  
  // Configure the scale and position of the bomb
  int x = (arc4random() % (int)self.frame.size.width);// Get randomn x for the whole screen
  if (x > self.frame.size.width-bomb.frame.size.width-5 || x < bomb.frame.size.width+5|| x == 0) x = self.frame.size.width-bomb.frame.size.width-5;
  
  bomb.position = CGPointMake(x, self.frame.size.height+bomb.frame.size.height);
  
  // Add the bomb to the scene
  [self addChild:bomb];
}
#pragma mark - UI update
- (void)updateLivesImageNode {
  // Assign the correct texture to display number of lives left
  if (livesNode.scene && livesNode) {
    livesNode.texture = [SKTexture textureWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%iLives", lives]]];
  }
}


#pragma mark - Pausing
- (void)pauseGame {
  if (lives > 0) {// Make sure the user doesn't lose last life and pause at the same time
    // Set gravity to 0.0
    self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);
    
    // Set the pause button
    pauseButtonNode.name = @"PlayButton";
    pauseButtonNode.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"PlayButton"]];
    
    // Pause Game
    self.view.paused = YES;
  }
}

- (void)resumeGame {
  // Resume the scene
  self.view.paused = NO;
  
  // Set the pause button
  pauseButtonNode.name = @"PauseButton";
  pauseButtonNode.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"PauseButton"]];
  
  // Reset gravity
  self.physicsWorld.gravity = CGVectorMake(0.0, level*-10.0);
  
}

@end
