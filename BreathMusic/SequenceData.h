//
//  SequenceData.h
//  MIDIFileSequence
//
//  Created by barry on 13/08/2014.
//  Copyright (c) 2014 Rockhopper Technologies. All rights reserved.
//
#import <AudioToolbox/AudioToolbox.h>

#import <Foundation/Foundation.h>
#import "NoteEvent.h"
#import "SequenceTrack.h"
typedef enum SequenceType

{
    SequenceTypeIntro,
    SequenceTypeChord,
    SequenceTypeOutro
}SequenceType;


@interface SequenceData : NSObject
@property (readwrite)MusicSequence  sequence;
@property (nonatomic,strong)NSMutableArray *tracks;
@property (readwrite)int tempo;


-(void)parseEvents;
-(void)changePitch:(int)pitch;
-(void)pitchup;
-(void)pitchDown;
-(void)cleanup;
@end
