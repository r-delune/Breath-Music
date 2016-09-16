//
//  SongEngine2.m
//  BreathMusic
//
//  Created by barry on 20/10/2014.
//  Copyright (c) 2014 rocudo. All rights reserved.
//

#import "SongEngine2.h"
#import "GDCoreAudioUtils.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AudioToolbox/MusicPlayer.h>
@interface SongEngine2 ()

@property (readwrite) AUGraph processingGraph;
@property (readwrite) AUNode ioNode;
@property (readwrite) AudioUnit mixerUnit;

@property (readwrite) AudioUnit ioUnit;

@property (nonatomic,strong) SequenceData  *lastSequence;
@property (readwrite) NSMutableArray  *chordSequences;

@property (nonatomic, readwrite)int tempo;
@property (nonatomic, readwrite)int beatsperbar;
@property (nonatomic, readwrite)int stylenumber;
@property(readwrite)NSInteger  currentbeat;
@property(nonatomic,strong)NSString  *firstChord;

@property(nonatomic,strong)NSMutableArray  *instruments;

@property int currentBeat;

@property(nonatomic,strong)NSString *currentInstrument;
@property(readwrite)UInt8 currentPresetNumber;

@property int numparts;
@property(nonatomic,strong)NSString  *filename;

@property(nonatomic,strong)AVMIDIPlayer  *player;
@property(nonatomic,strong)NSMutableArray  *midifilenames;
@property(nonatomic,strong)NSMutableArray  *midiplayers;
@property(nonatomic,assign)AVMIDIPlayer  *currentPlayer;

@property int lastIndex;

@end

@implementation SongEngine2

- (id) init
{
    if ( self = [super init] )
    {
        self.midifilenames=[NSMutableArray new];
        self.midiplayers=[NSMutableArray new];
    }
    
    return self;
}


-(void)playIndex:(int)index{
NSLog(@"%s",__func__);
    _lastIndex=index;
    

    
     for (int i=0; i<[self.midiplayers count]; i++) {
        
        AVMIDIPlayer  *player=self.midiplayers[i];
        
        if (i==index) {
            
            player.currentPosition=0;
            [player play:^{
                [self assessPlaybackPosition];
            }];
        }
    }

}
-(void)cleanup{
NSLog(@"%s",__func__);
    
    for (int i=0; i<[self.midiplayers count]; i++) {
        
        AVMIDIPlayer  *player=self.midiplayers[i];
        [player stop];
        player=nil;
    }

}
-(void)setMidiStyle:(NSDictionary*)style{
    
     NSLog(@"Palying index %@", _lastIndex);
    
    self.lastIndex=-1;
    self.tempo=[[style valueForKey:@"SongTempo"]intValue];
    
    self.numparts=[[style valueForKey:@"SongPartCount"]intValue];
    self.filename=[style valueForKey:@"SongFileName"];
    
    
    for (int i=0; i<self.numparts; i++) {
        int num=i+1;
        
        
        // midi bank file, you can download from http://www.sf2midi.com/
        NSURL *bank = [[NSBundle mainBundle] URLForResource:@"yamaha" withExtension:@"sf2"];
        
        NSError *error = nil;
        
        [_midifilenames addObject:[NSString stringWithFormat:@"%@_part%i",self.filename,num]];
        NSURL *url = [[NSBundle mainBundle] URLForResource:_midifilenames[i] withExtension:@"mid"];

        AVMIDIPlayer  *player = [[AVMIDIPlayer alloc] initWithContentsOfURL:url soundBankURL:bank error:&error];
        [player prepareToPlay];
        [self.midiplayers addObject:player];
        
    }



}
-(void)assessPlaybackPosition
{
    
    NSLog(@"%s",__func__);
    self.lastIndex++;
    
    if (self.lastIndex>=self.numparts) {
        
        self.lastIndex=0;
    }
    
    [self playIndex:self.lastIndex];

    [self.delegate playingIndex:self.lastIndex];
    
    NSLog(@"Palying index %d", _lastIndex);
}


-(void)beginBreath{

     NSLog(@"Palying index %d", _lastIndex);
    
    [self playIndex:self.lastIndex];
}

-(void)stopBreath
{
    
    for (int i=0; i<[self.midiplayers count]; i++) {
        
        AVMIDIPlayer  *player=self.midiplayers[i];
        [player stop];
    }

}
@end
