//
//  SongEngine2.h
//  BreathMusic
//
//  Created by barry on 20/10/2014.
//  Copyright (c) 2014 rocudo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SequenceData.h"
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
@protocol SongEngineProtocol
-(void)playingIndex:(int)index;
@end
@interface SongEngine2 : NSObject
//@property (nonatomic) MusicPlayer musicPlayer;
//@property (nonatomic) MusicSequence currentSequence;
-(void)playIndex:(int)index;
-(void)cleanup;
-(void)setMidiStyle:(NSDictionary*)style;
-(void)beginBreath;
-(void)stopBreath;
@property(nonatomic,unsafe_unretained)id<SongEngineProtocol>delegate;
@end
