//
//  SequenceTrack.h
//  MIDIFileSequence
//
//  Created by barry on 13/08/2014.
//  Copyright (c) 2014 Rockhopper Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NoteEvent.h"

@interface SequenceTrack : NSObject
-(void)addNoteEvent:(NoteEvent*)noteEvent;
@property(nonatomic,strong)NSMutableArray *notes;
@property(readwrite)UInt8 presetNumber;
@property(readwrite)float volume;

@end
