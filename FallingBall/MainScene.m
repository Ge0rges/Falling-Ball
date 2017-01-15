//
//  GameOverScene.m
//  FallingBall
//
//  Created by Georges Kanaan on 6/10/14.
//  Copyright (c) 2014 Georges Kanaan. All rights reserved.
//

#import "MainScene.h"

int score;

#define kLeaderboardID "Main"

@implementation MainScene

- (instancetype)initWithSize:(CGSize)size start:(BOOL)lclStart {
  if (self = [super initWithSize:size]) {
    
    // Assign the global variable
    start = lclStart;
    
    // Set the background color
    [self setBackgroundColor:[UIColor colorWithWhite:(250/255.0) alpha:1.0]];
    
    // Set the background image
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"Background"];
    background.zPosition = -2.0;
    background.size = self.frame.size;
    background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    
    [self addChild:background];
    
    if (!start) {
      // Setup the view for game over
      // Game over label
      SKLabelNode *gameOverLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica-light"];
      gameOverLabel.fontColor = [UIColor grayColor];
      gameOverLabel.fontSize = 42;
      gameOverLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
      gameOverLabel.text = @"Game Over";
      
      // Score label
      int highscore = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"highscore"];
      SKLabelNode *scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica-light"];
      scoreLabel.fontColor = [UIColor grayColor];
      scoreLabel.fontSize = 30;
      scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-40);
      scoreLabel.text = [NSString stringWithFormat:@"Score: %i Hits | Top Score: %i Hits", score, highscore];
      
      [self addChild:gameOverLabel];
      [self addChild:scoreLabel];
      
      // Set the highscore
      if (score > highscore) {
        // Save it
        [[NSUserDefaults standardUserDefaults] setInteger:score forKey:@"highscore"];
        highscore = score;
        
        // Significant event
        [Appirater userDidSignificantEvent:YES];
        
        // Set the score label
        scoreLabel.text = [NSString stringWithFormat:@"New Top Score: %i Hits!", highscore];
        
        // Send the score to game center if game center is enabled in 0.2 seconds so that self.gameViewController will have been assigned
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
          if ([[NSUserDefaults standardUserDefaults] boolForKey:@"GameCenter"]) {
            [self.gameViewController reportScore:highscore forLeaderboardID:@kLeaderboardID];
          }
        });
      }
      
    } else {
      // Setup the view for start
      // Score label
      int highscore = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"highscore"];
      SKLabelNode *scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica-light"];
      scoreLabel.fontColor = [UIColor grayColor];
      scoreLabel.fontSize = 20;
      scoreLabel.position = CGPointMake(110, self.frame.size.height-30);
      scoreLabel.text = [NSString stringWithFormat:@"Top Score: %i Hits", highscore];
      scoreLabel.name = @"TopScoreLabel";
      
      // Start label
      SKLabelNode *instructionsLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica-light"];
      instructionsLabel.fontColor = [UIColor grayColor];
      instructionsLabel.fontSize = 32;
      instructionsLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
      instructionsLabel.text = @"Tap to play!";
      instructionsLabel.name = @"TapToPlayLabel";
      
      // Add the views
      [self addChild:scoreLabel];
      [self addChild:instructionsLabel];
      
    }
    
    // Setup the HUD
    [self performSelectorInBackground:@selector(setupHUD) withObject:nil];
  }
  
  return self;
}

- (void)setupGameCenterHUD {
  // Add the game center button if game center is enabled
  if ([[NSUserDefaults standardUserDefaults] boolForKey:@"GameCenter"]) {
    SKSpriteNode *gameCenterNodeButton = [SKSpriteNode spriteNodeWithImageNamed:@"GameCenterButton"];
    gameCenterNodeButton.position = CGPointMake(self.frame.size.width-30, 25);
    gameCenterNodeButton.name = @"GameCenterButton";//how the node is identified later
    gameCenterNodeButton.xScale = 0.3;
    gameCenterNodeButton.yScale = 0.3;
    
    // Add the views
    [self addChild:gameCenterNodeButton];
  }
  
}

- (void)setupHUD {
  // Add game center
  [self setupGameCenterHUD];
  
  // Add white bars
  //top bar
  SKSpriteNode *topWhiteBar = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithWhite:1.0 alpha:0.6] size:CGSizeMake(self.frame.size.width, 100)];
  topWhiteBar.zPosition = -0.5;
  topWhiteBar.position = CGPointMake(self.frame.size.width/2, self.frame.size.height);
  topWhiteBar.name = @"topWhiteBar";
  topWhiteBar.blendMode = SKBlendModeMultiplyX2;
  
  // Bottom bar
  SKSpriteNode *bottomWhiteBar = [topWhiteBar copy];
  bottomWhiteBar.position = CGPointMake(self.frame.size.width/2, 0);
  bottomWhiteBar.name = @"bottomWhiteBar";
  
  // Add sound and vibration buttons
  // Sound
  SKSpriteNode *soundButton;
  if ([[NSUserDefaults standardUserDefaults] boolForKey:@"music"]) {// Change the image and its name depending on current music state
    soundButton = [SKSpriteNode spriteNodeWithImageNamed:@"SoundButton"];
    soundButton.name = @"SoundButton";//how the node is identified later
    
  } else {
    soundButton = [SKSpriteNode spriteNodeWithImageNamed:@"NoSoundButton"];
    soundButton.name = @"NoSoundButton";//how the node is identified later
  }
  
  soundButton.position = CGPointMake(70, 23);
  soundButton.xScale = 0.3;
  soundButton.yScale = 0.3;
  soundButton.color = [SKColor redColor];
  
  //vibration
  SKSpriteNode *vibrateButton;
  if ([[NSUserDefaults standardUserDefaults] boolForKey:@"vibration"]) {// Change the image and its name depending on current vibration state
    vibrateButton = [SKSpriteNode spriteNodeWithImageNamed:@"VibrateButton"];
    vibrateButton.name = @"VibrateButton";//how the node is identified later
  } else {
    vibrateButton = [SKSpriteNode spriteNodeWithImageNamed:@"NoVibrateButton"];
    vibrateButton.name = @"NoVibrateButton";//how the node is identified later
  }
  
  vibrateButton.position = CGPointMake(30, 23);
  vibrateButton.xScale = 0.4;
  vibrateButton.yScale = 0.4;
  
  // Add the nodes
  [self addChild:soundButton];
  [self addChild:vibrateButton];
  [self addChild:bottomWhiteBar];
  [self addChild:topWhiteBar];
  
  // Show the iad
  [self.gameViewController setCanShowAD:YES];
  [self.gameViewController canShowAdChanged];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint location = [touch locationInNode:self];
  SKNode *node = [self nodeAtPoint:location];
  
  // If game center button touched
  if ([node.name isEqualToString:@"GameCenterButton"]) {
    [self.gameViewController presentLeaderboards];// Show game center UI
    
  } else if ([node.name isEqualToString:@"NoSoundButton"]) {// If sound button touched
    
    // Set the sound to on
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"music"];
    
    // Play the music
    [self.gameViewController.backgroundPlayer prepareToPlay];
    [self.gameViewController.backgroundPlayer play];
    
    // Update the button image and name
    node.name = @"SoundButton";
    SKSpriteNode *spriteNode = (SKSpriteNode *)node;
    spriteNode.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"SoundButton"]];
    
  } else if ([node.name isEqualToString:@"SoundButton"]) {// If sound button touched
    
    // Set the sound to on
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"music"];
    
    // Play the music
    [self.gameViewController.backgroundPlayer stop];
    
    // Update the button image and name
    node.name = @"NoSoundButton";
    SKSpriteNode *spriteNode = (SKSpriteNode *)node;
    spriteNode.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"NoSoundButton"]];
    
  } else if ([node.name isEqualToString:@"VibrateButton"]) {// If sound button touched
    
    // Set the sound to on
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"vibration"];
    
    // Update the button image and name
    node.name = @"NoVibrateButton";
    SKSpriteNode *spriteNode = (SKSpriteNode *)node;
    spriteNode.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"NoVibrateButton"]];
    
  } else if ([node.name isEqualToString:@"NoVibrateButton"]) {// If sound button touched
    
    // Set the sound to on
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"vibration"];
    
    // Update the button image and name
    node.name = @"VibrateButton";
    SKSpriteNode *spriteNode = (SKSpriteNode *)node;
    spriteNode.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"VibrateButton"]];
    
  } else if (![node.name isEqualToString:@"topWhiteBar"] && ![node.name isEqualToString:@"bottomWhiteBar"]){//make sure he didn't hit on a bar
    
    SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
    
    if (start) {// If we are on the start screen change the animation
      reveal = [SKTransition pushWithDirection:SKTransitionDirectionDown duration:0.5];
    }
    
    GameScene *gameScene = [[GameScene alloc] initWithSize:self.size];
    gameScene.gameViewController = self.gameViewController;// Pass the instance of the view controller
    
    //hide the iad
    [self.gameViewController setCanShowAD:NO];
    [self.gameViewController canShowAdChanged];
    
    // Present the scene
    [self.view presentScene:gameScene transition:reveal];
  }
  
  // Synchronize the user defaults
  [[NSUserDefaults standardUserDefaults] synchronize];
}

@end