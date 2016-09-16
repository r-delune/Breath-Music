//
//  ScaleAudioEngine.h
//  BreathMusic
//
//  Created by barry on 05/09/2014.
//  Copyright (c) 2014 rocudo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScaleAudioEngine : NSObject

-(void)setOctave:(int)octave;
-(void)setKey:(NSString*)key;
-(void)setInstrument:(int)instrument;
-(void)playNote:(NSString*)note;

-(void)setup;
-(void)cleanup;
@property (readwrite) BOOL playing;
-(void)setTheVelocity:(UInt32)velocity;

//@property(readwrite)NSInteger currentScaleIndex;

@property(nonatomic,strong)NSDictionary  *currentScale;
@end
