//
//  GCLeaderboardScore.h
//  FallingBall
//
//  Created by Georges Kanaan on 6/19/14.
//  Copyright (c) 2014 Georges Kanaan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GCLeaderboardScore : NSObject

@property (strong, nonatomic) NSString *alias;
@property (strong, nonatomic) NSString *playerID;
@property (nonatomic) NSInteger score;
@property (nonatomic) NSInteger rank;
@property (strong, nonatomic) UIImage *photo;

@end
