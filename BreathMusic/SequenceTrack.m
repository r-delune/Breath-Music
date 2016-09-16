//
//  SequenceTrack.m
//  MIDIFileSequence
//
//  Created by barry on 13/08/2014.
//  Copyright (c) 2014 Rockhopper Technologies. All rights reserved.
//

#import "SequenceTrack.h"

@implementation SequenceTrack
-(void)addNoteEvent:(NoteEvent*)noteEvent
{
    if (!self.notes) {
        self.notes=[NSMutableArray new];
    }
    
    [self.notes addObject:noteEvent];
}
@end
