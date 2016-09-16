//
//  SongAudioEngine.h
//  BreathMusic
//
//  Created by barry on 08/09/2014.
//  Copyright (c) 2014 rocudo. All rights reserved.
//

#import "SequenceData.h"
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@protocol SongEngineProtocol <NSObject>

-(void)stictchedSongPassedIndex:(int)index;
-(void)logOutput:(NSString*)log;
-(void)reset;
-(void)stopEngine;
@end

@interface SongAudioEngine : NSObject
@property (nonatomic) MusicPlayer musicPlayer;
@property (nonatomic) MusicSequence currentSequence;
@property(nonatomic,unsafe_unretained)id<SongEngineProtocol>delegate;


-(void)playIndex:(int)index;
-(void)cleanup;
-(void)setMidiStyle:(NSDictionary*)style;
-(void)playMIDIFile;
-(void)setInstrument:(int)instrument;
-(void)loadMIDIFile;
-(void)setSongWithID:(int)theid;
-(void)beginBreath;
-(void)stopBreath;
-(void)stitchMidiData;
@end
