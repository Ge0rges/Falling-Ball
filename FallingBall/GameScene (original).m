//
//  GameScene.m
//  FallingBall
//
//  Created by Georges Kanaan on 6/10/14.
//  Copyright (c) 2014 Georges Kanaan. All rights reserved.
//

#import "GameScene.h"

#define IS_OS_7_OR_EARLIER    ([[[UIDevice currentDevice] systemVersion] floatValue] <= 7.0)
#define kBallRadius 130.0

extern int score;//extern so we can access it in other scenes

@implementation GameScene

#pragma mark - Configuring the scene
- (instancetype)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        //set the background color
        [self setBackgroundColor:[UIColor colorWithWhite:(250/255.0) alpha:1.0]];
        
        //setup game properties
        ballsSpawned = 0;
        level = 0.2;
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
        
        //setup the feedback
        //score label
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
        
        //add pause button
        pauseButtonNode = [SKSpriteNode spriteNodeWithImageNamed:@"PauseButton"];
        pauseButtonNode.position = CGPointMake(30, self.frame.size.height-25);
        pauseButtonNode.name = @"PauseButton";//how the node is identified later
        pauseButtonNode.xScale = 0.3;
        pauseButtonNode.yScale = 0.3;
        
        //add white top bar
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
    //Create a physics body that borders the screen and a extra edge on the bottom
    CGRect outOfScreenRect = CGRectMake(self.frame.origin.x, self.frame.origin.y, 1, 1);
    SKPhysicsBody *borderBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:outOfScreenRect];
    self.physicsBody = borderBody;//Set physicsBody of scene to borderBody
    self.physicsBody.friction = 0.0f;//Set the friction of that physicsBody to 0
    self.physicsWorld.gravity = CGVectorMake(0.0, level*-10.0);//Set gravity to -3.0
    
    //spawn ball
    [self spawnFirstBall];
}

#pragma mark - Handling Elimination of Objects
#pragma mark Processing Touches
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    //get the touch location
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    //get the node at the location
    SKNode *node = [self nodeAtPoint:location];
    
    if (node == ball1 && canHitBall1 && self.paused == NO) {//check if the node is a ball1
        //no more hits!
        canHitBall1 = NO;
        
        //add spark particle to ball
        SKEmitterNode *emitter =  [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"SparkParticle" ofType:@"sks"]];
        emitter.name = @"emitter1";
        emitter.position = node.position;
        [self addChild:emitter];
        
        //fade out the ball
        [ball1 runAction:[SKAction fadeOutWithDuration:0.2]];
        
        //after the animation is done
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
           //remove the ball
            [ball1 removeFromParent];
            [emitter removeFromParent];
            
            //reset the alpha
            [ball1  runAction:[SKAction fadeInWithDuration:0.2]];
            
            //next ball
            [self spawnFirstBall];
        });
        
        //update the score and display it
        score ++;
        [scoreNode setText:[NSString stringWithFormat:@"Score: %i Hits", score]];
        
        //only 1 score for each hit increment variable after 0.5 to make sure we don't get 2 points or more for one hit
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            canHitBall1 = YES;
        });
        
    } else if (node == ball2 && canHitBall2 && self.paused == NO) {//check if the node is a ball2
        //no more hits!
        canHitBall2 = NO;
        
        //add spark particle to ball
        SKEmitterNode *emitter =  [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"SparkParticle" ofType:@"sks"]];
        emitter.name = @"emitter2";
        emitter.position = node.position;
        [self addChild:emitter];
        
        //fade out the ball
        [ball2 runAction:[SKAction fadeOutWithDuration:0.2]];
        
        //after the animation is done
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //remove the ball
            [ball2 removeFromParent];
            [emitter removeFromParent];
            
            //reset the alpha
            [ball2  runAction:[SKAction fadeInWithDuration:0.2]];
            
            //next ball
            [self spawnSecondBall];
        });
        
        //update the score and display it
        score ++;
        [scoreNode setText:[NSString stringWithFormat:@"Score: %i Hits", score]];
        
        //only 1 score for each hit increment variable after 0.5 to make sure we don't get 2 points or more for one hit
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            canHitBall2 = YES;
        });
        
    } else if (node == ball3 && canHitBall3 && self.paused == NO) {//check if the node is a ball3
        //no more hits!
        canHitBall3 = NO;

        //add spark particle to ball
        SKEmitterNode *emitter =  [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"SparkParticle" ofType:@"sks"]];
        emitter.name = @"emitter3";
        emitter.position = node.position;
        [self addChild:emitter];
        
        //fade out the ball
        [ball3 runAction:[SKAction fadeOutWithDuration:0.2]];
        
        //after the animation is done
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //remove the ball
            [ball3 removeFromParent];
            [emitter removeFromParent];
            
            //reset the alpha
            [ball3  runAction:[SKAction fadeInWithDuration:0.2]];
            
            //next ball
            [self spawnThirdBall];
        });
        
        //update the score and display it
        score ++;
        [scoreNode setText:[NSString stringWithFormat:@"Score: %i Hits", score]];
        
        //only 1 score for each hit increment variable after 0.5 to make sure we don't get 2 points or more for one hit
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            canHitBall3 = YES;
        });        
   
    } else if (node == heart && canHitHeart && self.paused == NO) {//check if the node is a ball3
        //no more hits!
        canHitHeart = NO;
        
        //add spark particle to heart
        SKEmitterNode *emitter =  [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"HeartParticle" ofType:@"sks"]];
        emitter.name = @"emitter4";
        emitter.position = node.position;
        [self addChild:emitter];
        
        //fade out the heart
        [heart runAction:[SKAction fadeOutWithDuration:0.2]];
        
        //after the animation is done
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //remove the ball
            [heart removeFromParent];
            [emitter removeFromParent];
            
            //reset the alpha
            [heart  runAction:[SKAction fadeInWithDuration:0.2]];
            
            //next ball
            [NSTimer scheduledTimerWithTimeInterval:50 target:self selector:@selector(spawnHeart) userInfo:nil repeats:NO];
        });
        
        //update the lives and display it
        lives ++;
        [self updateLivesImageNode];
        
        //only 1 score for each hit increment variable after 0.5 to make sure we don't get 2 lives or more for one hit
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            canHitHeart = YES;
        });
    
    } else if (node == bomb && canHitBomb && self.paused == NO) {//check if the node is a ball3
        //no more hits!
        canHitBomb = NO;
        
        //add spark particle to bomb
        SKEmitterNode *emitter =  [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"BombParticle" ofType:@"sks"]];
        emitter.name = @"emitter5";
        emitter.position = node.position;
        [self addChild:emitter];
        
        //fade out the heart
        [bomb runAction:[SKAction fadeOutWithDuration:0.2]];
        
        //after the animation is done
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //remove the ball
            [bomb removeFromParent];
            [emitter removeFromParent];
            
            //reset the alpha
            [bomb  runAction:[SKAction fadeInWithDuration:0.2]];
            
            //next ball
            [NSTimer scheduledTimerWithTimeInterval:35 target:self selector:@selector(spawnBomb) userInfo:nil repeats:NO];
        });
        
        //update the lives and display it
        lives --;
        [self updateLivesImageNode];
        
        //only 1 score for each hit increment variable after 0.5 to make sure we don't lose 2 lives or more for one hit
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            canHitBomb = YES;
        });
    
    } else if ([node.name isEqualToString:@"PauseButton"]) {//if sound button touched
        [self pauseGame];//pause game
        
    } else if ([node.name isEqualToString:@"PlayButton"]) {//if sound button touched
        [self resumeGame];//start game
    }
}

#pragma mark Off Screen Object Handling

- (void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    if (!self.paused) {//don't waste CPU
        if (lives > 0) {//this isn't needed if we have 0 lives
            if (ball1.position.y < -ball1.frame.size.height){//if the ball is off the screen completely
                //vibrate the phone if the setting allows it
                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"vibration"]) AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
                
                //remove the ball
                [ball1 removeFromParent];
                
                //remove a life and display it
                lives --;
                [self updateLivesImageNode];
                
                //spawn a new ball if there are still lives
                if (lives > 0) [self spawnFirstBall];
            }
            
            if (ball2.position.y < -ball2.frame.size.height){//if the ball is off the screen completely
                
                //vibrate the phone if the setting allows it
                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"vibration"]) AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
                
                //remove the ball
                [ball2 removeFromParent];
                
                //remove a life and display it
                lives --;
                [self updateLivesImageNode];
                
                //spawn a new ball if there are still lives
                if (lives > 0) [self spawnSecondBall];
            }
            
            if (ball3.position.y < -ball3.frame.size.height){//if the ball is off the screen completely
                //vibrate the phone if the setting allows it
                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"vibration"]) AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
                
                //remove the ball
                [ball3 removeFromParent];
                
                //remove a life and display it
                lives --;
                [self updateLivesImageNode];
                
                //spawn a new ball if there are still lives
                if (lives > 0) [self spawnThirdBall];
                
            }
            
            if (heart.position.y < -heart.frame.size.height){//if the heart is off the screen completely
                //remove the heart
                [heart removeFromParent];
                
                //spawn a new heart in 25 seconds
                [NSTimer scheduledTimerWithTimeInterval:25.0 target:self selector:@selector(spawnHeart) userInfo:nil repeats:NO];
            }
            
            if (bomb.position.y < -bomb.frame.size.height){//if the heart is off the screen completely
                //remove the bomb
                [bomb removeFromParent];
                
                //spawn a new heart in 25 seconds
                [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(spawnBomb) userInfo:nil repeats:NO];
            }
            
        } else if (!calledGameOver) {
            
            //make sure this isn't called twice
            calledGameOver = YES;
            
            //present the game over scene after a second
            SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
            MainScene *gameOverScene = [[MainScene alloc] initWithSize:self.size start:NO];
            gameOverScene.gameViewController = self.gameViewController;//pass the instance of the view controller
            
            //present the scene
            [self.view presentScene:gameOverScene transition:reveal];
            
            
        }
    }
}

#pragma mark - Spawning Balls, Hearts & Bombs
//balls
- (void)spawnFirstBall {
    //increment the ballsSpawned variable
    ballsSpawned ++;
    
    //increment the level
    level += 0.002;
    self.physicsWorld.gravity = CGVectorMake(level, level*-10);
    
    //generate a randomn UIColor for the ball
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *ballColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    
    //assign ball and configure it if it is not already assigned
    if (!ball1) {
        //create a ball sprite
        ball1 = [SKShapeNode shapeNodeWithCircleOfRadius:kBallRadius];
        
        //configure global properties of the ball
        ball1.zPosition = -0.6;
        
        //configure the balls physics
        ball1.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:kBallRadius];
        
    }
    
    //configure the ball color
    ball1.strokeColor = [SKColor clearColor];
    ball1.fillColor = ballColor;
    
    //configure the scale and position of the ball
    ball1.xScale = 0.3;
    ball1.yScale = 0.3;
    int x = arc4random() % (int)(self.frame.size.width/2);//get randomn x for left portion of the screen
    if (x < ball1.frame.size.width+5) x = ball1.frame.size.width+5;
    ball1.position = CGPointMake(x, self.frame.size.height+80);
    
    //add the ball to the scene
    [self addChild:ball1];
    
    //if we passed a certain number of balls spawned send a second or third ball on the screen
    if (ballsSpawned >= 10 && hasCreatedSecondBall == NO) {//if more than 10 were already shown send a second one
        [self spawnSecondBall];
        hasCreatedSecondBall = YES;
    }
}

- (void)spawnSecondBall {
    //increment the ballsSpawned variable
    ballsSpawned ++;
    
    //generate a randomn UIColor for the ball
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *ballColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    
    //assign ball and configure it if it is not already assigned
    if (!ball2) {
        //create a ball sprite
        ball2 = [SKShapeNode shapeNodeWithCircleOfRadius:kBallRadius];
        
        //configure global properties of the ball
        ball2.zPosition = -0.6;
        
        //configure the balls physics
        ball2.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:kBallRadius];
        
    }
    
    //configure the ball color
    ball2.strokeColor = [SKColor clearColor];
    ball2.fillColor = ballColor;
    
    //configure the scale and position of the ball
    ball2.xScale = 0.3;
    ball2.yScale = 0.3;
    int x = (arc4random() % (int)(self.frame.size.width/2))+self.frame.size.width/2;//get randomn x for right portion of the screen
    if (x > self.frame.size.width-ball2.frame.size.width-5) x = self.frame.size.width-ball2.frame.size.width-5;
    ball2.position = CGPointMake(x, self.frame.size.height+80);
    
    //add the ball to the scene
    [self addChild:ball2];
    
    //if we passed a certain number of balls spawned send a third ball on the screen only in iPad
    if (ballsSpawned >= 50 && hasCreatedThirdBall == NO) {//if more than 40 balls were already shown send a second one
        [self spawnThirdBall];
        hasCreatedThirdBall = YES;
    }
}

- (void)spawnThirdBall {
    //increment the ballsSpawned variable
    ballsSpawned ++;
    
    //generate a randomn UIColor for the ball
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *ballColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    
    //assign ball and configure it if it is not already assigned
    if (!ball3) {
        //create a ball sprite
        ball3 = [SKShapeNode shapeNodeWithCircleOfRadius:kBallRadius];
        
        //configure global properties of the ball
        ball3.zPosition = -0.6;
        
        //configure the balls physics
        ball3.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:kBallRadius];
    }
    
    //configure the ball color
    ball3.strokeColor = [SKColor clearColor];
    ball3.fillColor = ballColor;
    
    //configure the scale and position of the ball
    ball3.xScale = 0.3;
    ball3.yScale = 0.3;
    int x = (arc4random() % (int)self.frame.size.width);//get randomn x for the whole screen
    if (x > self.frame.size.width-ball3.frame.size.width-5) x = self.frame.size.width-ball3.frame.size.width-5;
    ball3.position = CGPointMake(x, self.frame.size.height+80);
    
    //add the ball to the scene
    [self addChild:ball3];
    
    //spawn heart and bomb for the first time
    if (!hasCreatedBomb && ballsSpawned > 100) {
        [self spawnBomb];
    }
    
    if (!hasCreatedHeart && ballsSpawned > 70) {
        [self spawnHeart];
    }
    
}

//heart and bomb
- (void)spawnHeart {
    //assign heart and configure it if it is not already assigned
    if (!heart) {
        //create a ball sprite
        heart = [SKSpriteNode spriteNodeWithImageNamed:@"Heart"];
        
        //configure global properties of the ball
        heart.zPosition = -0.6;
        
        //configure the balls physics
        heart.physicsBody = [SKPhysicsBody bodyWithTexture:heart.texture size:heart.size];
    }
    
    //configure the scale and position of the heart
    heart.xScale = 0.3;
    heart.yScale = 0.3;
    int x = (arc4random() % (int)self.frame.size.width);//get randomn x for the whole screen
    if (x > self.frame.size.width-heart.frame.size.width-5) x = self.frame.size.width-heart.frame.size.width-5;
    heart.position = CGPointMake(x, self.frame.size.height+80);
    
    //add the heart to the scene
    [self addChild:heart];
}

- (void)spawnBomb {
    //assign bomb and configure it if it is not already assigned
    if (!bomb) {
        //create a ball sprite
        bomb = [SKSpriteNode spriteNodeWithImageNamed:@"Bomb"];
        
        //configure global properties of the ball
        bomb.zPosition = -0.6;
        
        //configure the balls physics
        bomb.physicsBody = [SKPhysicsBody bodyWithTexture:bomb.texture size:bomb.size];
    }
    
    //add smoke to the bomb
    SKEmitterNode *emitter =  [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"BombSmokeParticle" ofType:@"sks"]];
    emitter.name = @"emitter6";
    emitter.position = CGPointMake(bomb.frame.size.width-5, bomb.frame.size.height-5);
    
    //configure the scale and position of the bomb
    bomb.xScale = 0.3;
    bomb.yScale = 0.3;
    int x = (arc4random() % (int)self.frame.size.width);//get randomn x for the whole screen
    if (x > self.frame.size.width-bomb.frame.size.width-5) x = self.frame.size.width-bomb.frame.size.width-5;
    bomb.position = CGPointMake(x, self.frame.size.height+80);
    
    //add the bomb to the scene
    [self addChild:bomb];
}
#pragma mark - UI update
- (void)updateLivesImageNode {
    //assign the correct texture to display number of lives left
    if (lives == 5) {
        livesNode.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"5Lives"]];
    } else if (lives == 4) {
        livesNode.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"4Lives"]];
    } else if (lives == 3) {
        livesNode.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"3Lives"]];
    } else if (lives == 2) {
        livesNode.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"2Lives"]];
    } else if (lives == 1) {
        livesNode.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"1Life"]];
    } else if (lives == 0) {
        livesNode.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"0Lives"]];
    }
}


#pragma mark - Pausing
- (void)pauseGame {
    //pause the scene
    self.paused = YES;
    
    //set the pause button
    pauseButtonNode.name = @"PlayButton";
    pauseButtonNode.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"PlayButton"]];
}

- (void)resumeGame {
    //resume the scene
    self.paused = NO;
    
    //set the gravity
    self.physicsWorld.gravity = CGVectorMake(level, level*-10);
    
    //set the pause button
    pauseButtonNode.name = @"PauseButton";
    pauseButtonNode.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"PauseButton"]];
}

@end