//
//  AAAGamificationManager.m
//  Gamify
//
//  Created by Håkon Bogen on 12.02.14.
//  Copyright (c) 2014 Haaakon Bogen. All rights reserved.
//

#import "AAAGamificationManager.h"
#import "AAAMainPlayer.h"
#import "AAAAchievmentViewController.h"

@interface AAAGamificationManager ()
@property (nonatomic,strong) AAAMainPlayer *mainPlayer;
@end

@implementation AAAGamificationManager

+ (AAAGamificationManager *)sharedManager {
    static AAAGamificationManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[AAAGamificationManager alloc] init];
        [_sharedManager loadMainPlayer];
    });
    
    return _sharedManager;
}

- (NSString*)documentsDirectory
{
    return [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/score"];
}

- (void)setScoreView:(AAAScoreView *)scoreView
{
    _scoreView = scoreView;
    _scoreView.scoreLabel.text = [NSString stringWithFormat:@"%ld",self.mainPlayer.playerScore];
}

- (void)loadMainPlayer {
    NSError *error;
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/score"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    NSString *filePath = [path stringByAppendingPathComponent:@"data"];
    NSData *codedData = [[NSData alloc] initWithContentsOfFile:filePath];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:codedData];
    self.mainPlayer  = [unarchiver decodeObjectForKey:@"mainPlayer"];
    if (self.mainPlayer == nil) {
        self.mainPlayer = [[AAAMainPlayer alloc] init];
    }
    [unarchiver finishDecoding];
}

- (void)saveMainPlayerData
{
    NSError *error;
    [[NSFileManager defaultManager] createDirectoryAtPath:[self documentsDirectory] withIntermediateDirectories:YES attributes:nil error:&error];
    NSString *filePath = [[self documentsDirectory] stringByAppendingPathComponent:@"data"];
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:self.mainPlayer forKey:@"mainPlayer"];
    [archiver finishEncoding];
    [data writeToFile:filePath atomically:YES];
}

- (NSInteger)mainPlayerScore
{
    return self.mainPlayer.playerScore;
}

- (void)initialSetScoreNoAnimation
{
    if ([self.scoreView respondsToSelector:@selector(setScoreWithoutAnimation:)]) {
        [self.scoreView setScoreWithoutAnimation:self.mainPlayer.playerScore];
    }
}

- (void)showAchievementViewControllerOnViewController:(UIViewController*)viewController withAchievement:(AAAAchievement*)achievement
{
    AAAAchievmentViewController *achievementViewController = [[AAAAchievmentViewController alloc] init];
    achievementViewController.achievement = achievement;
    [viewController presentViewController:achievementViewController animated:YES completion:^{
        
    }];
}

- (void)setMainPlayersScore:(NSInteger)score
{
    NSInteger oldScore = self.mainPlayer.playerScore;
    self.mainPlayer.playerScore = score;
    
    if ([self.scoreView respondsToSelector:@selector(setScoreTo:scoreChange:)]) {
        [self.scoreView setScoreTo:score scoreChange: score - oldScore ];
    }
    [self saveMainPlayerData];
    
}

- (void)addToMainPlayerScore:(NSInteger)score
{
    NSInteger oldScore = self.mainPlayer.playerScore;
    
    if ([self.scoreView respondsToSelector:@selector(setScoreTo:scoreChange:)]) {
        [self.scoreView setScoreTo:score + oldScore scoreChange: score ];
    }
    self.mainPlayer.playerScore = score + oldScore;
    [self saveMainPlayerData];
}

@end
