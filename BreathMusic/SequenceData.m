//
//  SequenceData.m
//  MIDIFileSequence
//
//  Created by barry on 13/08/2014.
//  Copyright (c) 2014 Rockhopper Technologies. All rights reserved.
//

#import "SequenceData.h"
#import "GDCoreAudioUtils.h"

@interface SequenceData ()
{

    int currentPitchIncrement;
    BOOL up;
}

@end
@implementation SequenceData
@synthesize sequence=_sequence;

-(id)init
{
    if (self==[super init]) {
        
        self.tracks=[NSMutableArray new];
       CheckError(NewMusicSequence(&_sequence), "NewMusicSequence");

    }
    return self;
}

-(void)parseEvents
{
    UInt32 trackCount;
    CheckError(MusicSequenceGetTrackCount(self.sequence, &trackCount), "MusicSequenceGetTrackCount");
   // NSLog(@"Number of tracks: %lu", trackCount);
    
    
    for(int i = 0; i < trackCount; i++)
    {
        
        MusicTrack track = NULL;
        MusicTimeStamp trackLen = 0;
        
        UInt32 trackLenLen = sizeof(trackLen);
        
        MusicSequenceGetIndTrack(self.sequence, i, &track);
        
        MusicTrackGetProperty(track, kSequenceTrackProperty_TrackLength, &trackLen, &trackLenLen);
        
        MusicTrackLoopInfo loopInfo = { trackLen, 0 };
        loopInfo.numberOfLoops=5000;
        //MusicTrackSetProperty(track, kSequenceTrackProperty_LoopInfo, &loopInfo, sizeof(loopInfo));
        // NSLog(@"track length is %f", trackLen);
      //  MusicTrack tracknew = NULL;
        
         [self iterate:track index:i];
       // MusicTrackSetProperty(tracknew, kSequenceTrackProperty_LoopInfo, &loopInfo, sizeof(loopInfo));
        
    }

}
- (void) iterate: (MusicTrack) track index:(int)trackNumber
{
    
    SequenceTrack  *seqtrack=[SequenceTrack new];
     
	MusicEventIterator	iterator;
	CheckError(NewMusicEventIterator (track, &iterator), "NewMusicEventIterator");
    
    // MusicTrackCut(track, 1, 176400);
    
    MusicEventType eventType;
	MusicTimeStamp eventTimeStamp;
    UInt32 eventDataSize;
    const void *eventData;
    
    Boolean	hasCurrentEvent = NO;
    CheckError(MusicEventIteratorHasCurrentEvent(iterator, &hasCurrentEvent), "MusicEventIteratorHasCurrentEvent");
    while (hasCurrentEvent)
    {
        MusicEventIteratorGetEventInfo(iterator, &eventTimeStamp, &eventType, &eventData, &eventDataSize);
       // NSLog(@"event timeStamp %f ", eventTimeStamp);
      //  NSLog(@"track");
        
        switch (eventType) {
                
                case kMusicEventType_ExtendedTempo : {
                ExtendedTempoEvent* ext_tempo_evt = (ExtendedTempoEvent*)eventData;
              //  NSLog(@"ExtendedTempoEvent, bpm %f", ext_tempo_evt->bpm);
                self.tempo=ext_tempo_evt->bpm;
                
            }
                break ;
            case kMusicEventType_MIDIChannelMessage : {
                
                
                MIDIChannelMessage* channel_evt = (MIDIChannelMessage*)eventData;
                if(channel_evt->status == (0xC0 & 0xF0)) {
                    seqtrack.presetNumber=channel_evt->data1;
                }
                
                UInt8  b=channel_evt->status;
                b=b>>4;
                if(b == 11) {
                    
                    if (channel_evt->data1==7) {
                        
                       // float volume=channel_evt->data2/127.0f;
                        //seqtrack.volume=volume;
                        //NSLog(@"channel %X",channel_evt->status);
                        //NSLog(@"channel volume%f",volume);

                        
                    }
                }
                
                                          }
                break ;
                default :
                break ;
        }
        CheckError(MusicEventIteratorHasNextEvent(iterator, &hasCurrentEvent), "MusicEventIteratorHasCurrentEvent");
        CheckError(MusicEventIteratorNextEvent(iterator), "MusicEventIteratorNextEvent");
    }
    
    [self.tracks addObject:seqtrack];

}

-(void)pitchup
{
    
    for(int i = 0; i < [self.tracks count]; i++)
    {
        
        MusicTrack track = NULL;
        MusicTimeStamp trackLen = 0;
        
        UInt32 trackLenLen = sizeof(trackLen);
        
        MusicSequenceGetIndTrack(self.sequence, i, &track);
        
        MusicTrackGetProperty(track, kSequenceTrackProperty_TrackLength, &trackLen, &trackLenLen);
        
        
        [self iteratePitchUp:track forIndex:i];
    }

}
-(void)iteratePitchUp: (MusicTrack) track forIndex:(int)index
{
    NSDate *methodStart = [NSDate date];
    int originalEventIndex=0;
    
    
	MusicEventIterator	iterator;
	CheckError(NewMusicEventIterator (track, &iterator), "NewMusicEventIterator");
    
    
    MusicEventType eventType;
	MusicTimeStamp eventTimeStamp;
    UInt32 eventDataSize;
    const void *eventData;
    
    Boolean	hasCurrentEvent = NO;
    CheckError(MusicEventIteratorHasCurrentEvent(iterator, &hasCurrentEvent), "MusicEventIteratorHasCurrentEvent");
    while (hasCurrentEvent)
    {
        MusicEventIteratorGetEventInfo(iterator, &eventTimeStamp, &eventType, &eventData, &eventDataSize);
        switch (eventType) {
                
            case kMusicEventType_MIDINoteMessage : {
                MIDINoteMessage* note_evt = (MIDINoteMessage*)eventData;
            note_evt->note++;
                originalEventIndex++;
            }
                break ;
                
                
            default :
                break ;
                
        }
        
        CheckError(MusicEventIteratorHasNextEvent(iterator, &hasCurrentEvent), "MusicEventIteratorHasCurrentEvent");
        CheckError(MusicEventIteratorNextEvent(iterator), "MusicEventIteratorNextEvent");
    }
    
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
    NSLog(@"executionTime = %f", executionTime);

}

-(void)iteratePitchDown: (MusicTrack) track forIndex:(int)index
{
    NSDate *methodStart = [NSDate date];
    int originalEventIndex=0;
    
	MusicEventIterator	iterator;
	CheckError(NewMusicEventIterator (track, &iterator), "NewMusicEventIterator");
    
    MusicEventType eventType;
	MusicTimeStamp eventTimeStamp;
    UInt32 eventDataSize;
    const void *eventData;
    
    Boolean	hasCurrentEvent = NO;
    CheckError(MusicEventIteratorHasCurrentEvent(iterator, &hasCurrentEvent), "MusicEventIteratorHasCurrentEvent");
    while (hasCurrentEvent)
    {
        MusicEventIteratorGetEventInfo(iterator, &eventTimeStamp, &eventType, &eventData, &eventDataSize);
        switch (eventType) {
                
                
                
                
            case kMusicEventType_MIDINoteMessage : {
                MIDINoteMessage* note_evt = (MIDINoteMessage*)eventData;
                note_evt->note--;
                originalEventIndex++;
            }
                break ;
                
                
            default :
                break ;
                
        }
        
        CheckError(MusicEventIteratorHasNextEvent(iterator, &hasCurrentEvent), "MusicEventIteratorHasCurrentEvent");
        CheckError(MusicEventIteratorNextEvent(iterator), "MusicEventIteratorNextEvent");
    }
    
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
    NSLog(@"executionTime = %f", executionTime);

}
-(void)pitchDown
{
    for(int i = 0; i < [self.tracks count]; i++)
    {
        
        MusicTrack track = NULL;
        MusicTimeStamp trackLen = 0;
        
        UInt32 trackLenLen = sizeof(trackLen);
        
        MusicSequenceGetIndTrack(self.sequence, i, &track);
        
        MusicTrackGetProperty(track, kSequenceTrackProperty_TrackLength, &trackLen, &trackLenLen);
        
        
        [self iteratePitchDown:track forIndex:i];
    }

}
-(void)changePitch:(int)pitch
{
    
    if (pitch>currentPitchIncrement) {
        up=YES;
    }else
    {
        up=NO;
    }
    currentPitchIncrement=pitch;
    
    if (pitch==0) {
        return;
    }
    
    for(int i = 0; i < [self.tracks count]; i++)
    {
        
        MusicTrack track = NULL;
        MusicTimeStamp trackLen = 0;
        
        UInt32 trackLenLen = sizeof(trackLen);
        
        MusicSequenceGetIndTrack(self.sequence, i, &track);
        
        MusicTrackGetProperty(track, kSequenceTrackProperty_TrackLength, &trackLen, &trackLenLen);
        
        
        [self iteratePitch:track forIndex:i];
        
    }

    
}
- (void) iteratePitch: (MusicTrack) track forIndex:(int)index
{
    
   // SequenceTrack  *originalTrack=self.tracks[index];
    
    NSDate *methodStart = [NSDate date];
    int originalEventIndex=0;
    
    int abint=abs(currentPitchIncrement);
	MusicEventIterator	iterator;
	CheckError(NewMusicEventIterator (track, &iterator), "NewMusicEventIterator");
    
    
    MusicEventType eventType;
	MusicTimeStamp eventTimeStamp;
    UInt32 eventDataSize;
    const void *eventData;
    
    Boolean	hasCurrentEvent = NO;
    CheckError(MusicEventIteratorHasCurrentEvent(iterator, &hasCurrentEvent), "MusicEventIteratorHasCurrentEvent");
    while (hasCurrentEvent)
    {
        MusicEventIteratorGetEventInfo(iterator, &eventTimeStamp, &eventType, &eventData, &eventDataSize);
        switch (eventType) {
                
                
                
                
            case kMusicEventType_MIDINoteMessage : {
                MIDINoteMessage* note_evt = (MIDINoteMessage*)eventData;
               // NoteEvent  *originalEvent=originalTrack.notes[originalEventIndex];
               // note_evt->note++;
                    for (int i=0; i<abint; i++) {
                        
                        if (up) {
                            note_evt->note++;

                        }else
                        {
                            note_evt->note--;

                        }

                    }
                originalEventIndex++;
            }
                break ;
                
                
            default :
                break ;
                
        }
        
        CheckError(MusicEventIteratorHasNextEvent(iterator, &hasCurrentEvent), "MusicEventIteratorHasCurrentEvent");
        CheckError(MusicEventIteratorNextEvent(iterator), "MusicEventIteratorNextEvent");
    }
    
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
    NSLog(@"executionTime = %f", executionTime);
}
-(void)cleanup
{
    
    if (!self.sequence) {
        return;
    }
    UInt32 trackCount;
    CheckError(MusicSequenceGetTrackCount(self.sequence, &trackCount), "MusicSequenceGetTrackCount");
    MusicTrack track;
    for(int i = 0;i < trackCount; i++)
    {
        CheckError(MusicSequenceGetIndTrack (self.sequence,0,&track), "MusicSequenceGetIndTrack");
        CheckError(MusicSequenceDisposeTrack(self.sequence, track), "MusicSequenceDisposeTrack");
    }
    
    DisposeMusicSequence(self.sequence);
    self.sequence=nil;

    [self.tracks removeAllObjects];
}
@end
