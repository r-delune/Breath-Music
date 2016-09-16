//
//  TapAudioEngine.m
//  BreathMusic
//
//  Created by barry on 08/09/2014.
//  Copyright (c) 2014 rocudo. All rights reserved.
//

#import "TapAudioEngine.h"
#import "SequenceData.h"
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "GDCoreAudioUtils.h"
#import "GCDQueue.h"
#import "NoteEvent.h"
#import "SequenceData.h"
#import "Instrument.h"
#define MAX_TRACKS 20

@interface TapAudioEngine ()

@property (nonatomic) UInt8 presetNumber;
@property (nonatomic) MusicPlayer introMusicPlayer;
@property (readwrite) AUGraph processingGraph;
@property (readwrite) AUNode ioNode;
@property (readwrite) AudioUnit mixerUnit;

@property (readwrite) AudioUnit ioUnit;
@property (readwrite) int currentPitchIncrement;

@property (nonatomic,strong) SequenceData  *introMusicSequence;

@property (nonatomic, readwrite)int tempo;
@property(nonatomic,strong)NSString  *firstChord;

@property(nonatomic,strong)NSMutableArray  *instruments;

@property int currentBeat;
@property(nonatomic,strong)NSString *currentSongName;

@end


@implementation TapAudioEngine

-(void)cleanup
{
    MusicPlayerStop(self.introMusicPlayer);
    AUGraphStop(_processingGraph);
    AUGraphUninitialize(_processingGraph);
    DisposeAUGraph(_processingGraph);
 //   [self.introMusicSequence cleanup];
}
-(void)songSelected:(NSString*)songname
{

   // [self cleanup];
    
    [self createAUGraph];
   self.tempo=110;
    
    self.currentSongName=songname;
    
    [self playMidiFile];
}
-(int)getTheTempo
{
    return self.tempo;
}
-(void)tempoDown
{
    self.tempo-=5;
    
    if (self.tempo<=10) {
        self.tempo=10;
    }
    MusicTrack tempoTrack;
    MusicSequenceGetTempoTrack (self.introMusicSequence.sequence, &tempoTrack);
    MusicTrackNewExtendedTempoEvent(tempoTrack, 0, self.tempo);

}

-(void)tempoUp
{
    self.tempo+=5;
    MusicTrack tempoTrack;
    MusicSequenceGetTempoTrack (self.introMusicSequence.sequence, &tempoTrack);
    MusicTrackNewExtendedTempoEvent(tempoTrack, 0, self.tempo);
}
- (id) init
{
    if ( self = [super init] ) {
        self.instruments=[NSMutableArray new];
        for (int i=0; i<MAX_TRACKS; i++) {
            
            Instrument  *instrument=[Instrument new];
            [self.instruments addObject:instrument];
        }
        // [self setupStereoStreamFormat];
       
        
        
        
        // [self setupSampler:self.presetNumber];
        
    }
    
    return self;
}

#pragma mark - Audio setup


-(void)createAUGraph
{
    
    OSStatus result = noErr;
	AUNode ioNode, mixerNode;
    
    
    // Specify the common portion of an audio unit's identify, used for both audio units
    // in the graph.
	AudioComponentDescription cd = {};
	cd.componentManufacturer     = kAudioUnitManufacturer_Apple;
    
    // Instantiate an audio processing graph
	result = NewAUGraph (&_processingGraph);
    NSCAssert (result == noErr, @"Unable to create an AUGraph object. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
	//Specify the Sampler unit, to be used as the first node of the graph
	cd.componentType = kAudioUnitType_MusicDevice;
	cd.componentSubType = kAudioUnitSubType_Sampler;
	
    
    // Node which will be used to play our midi not with a particular sound font
    AUNode node;
    // Create nodes for all the voices
    for(int i=0; i<MAX_TRACKS; i++) {
        
        Instrument  *instrument=self.instruments[i];
        // Create a new sampler note
        
        result = AUGraphAddNode (_processingGraph, &cd, &node);
        instrument.instrumentNode=node;
        // Check for any errors
        
        // Encode the node and add it to the array of sampler notes for later
    }
    
    
	// Specify the Output unit, to be used as the second and final node of the graph
	cd.componentType = kAudioUnitType_Output;
	cd.componentSubType = kAudioUnitSubType_RemoteIO;
    
    // Add the Output unit node to the graph
	result = AUGraphAddNode (_processingGraph, &cd, &ioNode);
    NSCAssert (result == noErr, @"Unable to add the Output unit to the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    // Add the mixer unit to the graph
    cd.componentType = kAudioUnitType_Mixer;
    cd.componentSubType = kAudioUnitSubType_MultiChannelMixer;
    
    result = AUGraphAddNode (_processingGraph, &cd, &mixerNode);
    NSCAssert (result == noErr, @"Unable to add the Output unit to the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    
    // Open the graph
	result = AUGraphOpen (_processingGraph);
    NSCAssert (result == noErr, @"Unable to open the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    // Now that the graph is open get references to all the nodes and store
    // them as audio units
    
    AudioUnit samplerUnit;
    // Loop over the sampler notes
    
    for(int i=0; i<[self.instruments count]; i++) {
        // Extract the sampler note from the NSValue into the samplerNode variable
        
        Instrument *instrument=self.instruments[i];
        node=instrument.instrumentNode;
        // Get a reference to the sampler node and store it in the samplerUnit variable
        result = AUGraphNodeInfo (_processingGraph, node, 0, &samplerUnit);
        instrument.instrumentUnit=samplerUnit;
        
        NSCAssert (result == noErr, @"Unable to obtain a reference to the Sampler unit. Error code: %d '%.4s'", (int) result, (const char *)&result);
        
    }
    
    
    // Create a new mixer unit. This is necessary because we have a number of sampler
    // units which we need to output through the speakers. Each of these channels needs
    // to be mixed together to create one output
	result = AUGraphNodeInfo (_processingGraph, mixerNode, 0, &_mixerUnit);
    NSCAssert (result == noErr, @"Unable to obtain a reference to the Sampler unit. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
	// Obtain a reference to the I/O unit from its node
	result = AUGraphNodeInfo (_processingGraph, ioNode, 0, &_ioUnit);
    NSCAssert (result == noErr, @"Unable to obtain a reference to the I/O unit. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    // Define the number of input busses
    UInt32 busCount   = [self.instruments count];
    
    // Set the input channels property on the mixer unit
    result = AudioUnitSetProperty (
                                   _mixerUnit,
                                   kAudioUnitProperty_ElementCount,
                                   kAudioUnitScope_Input,
                                   0,
                                   &busCount,
                                   sizeof (busCount)
                                   );
    NSCAssert (result == noErr, @"AudioUnitSetProperty Set mixer bus count. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    // Connect the nodes to the mixer node
    for(int i=0; i<[self.instruments count]; i++) {
        // Extract the sampler unit
        Instrument *instrument=self.instruments[i];
        node=instrument.instrumentNode;
        
        
        // Connect the sampler unit to the mixer unit
        result = AUGraphConnectNodeInput(_processingGraph, node, 0, mixerNode, i);
        
        // Set the volume of the channel
       // AudioUnitSetParameter(_mixerUnit, kMultiChannelMixerParam_Volume, kAudioUnitScope_Input, i,1, 0);
        
        NSCAssert (result == noErr, @"Couldn't connect speech synth unit output (0) to mixer input (1). Error code: %d '%.4s'", (int) result, (const char *)&result);
    }
    
    // Connect the output of the mixer node to the input of he io node
    result = AUGraphConnectNodeInput (_processingGraph, mixerNode, 0, ioNode, 0);
    NSCAssert (result == noErr, @"Unable to interconnect the nodes in the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
   // AUGraphAddRenderNotify(_processingGraph, renderCallback, (__bridge void*) self);
    
	CAShow(self.processingGraph);
    
}
- (void) startGraph
{
    if (self.processingGraph) {
        // this calls the AudioUnitInitialize function of each AU in the graph.
        // validates the graph's connections and audio data stream formats.
        // propagates stream formats across the connections
        Boolean outIsInitialized;
        CheckError(AUGraphIsInitialized(self.processingGraph,
                                        &outIsInitialized), "AUGraphIsInitialized");
        if(!outIsInitialized)
            CheckError(AUGraphInitialize(self.processingGraph), "AUGraphInitialize");
        
        Boolean isRunning;
        CheckError(AUGraphIsRunning(self.processingGraph,
                                    &isRunning), "AUGraphIsRunning");
        if(!isRunning)
            CheckError(AUGraphStart(self.processingGraph), "AUGraphStart");
    }
}
#pragma mark - Sampler

- (void) setupSampler:(UInt8) pn samplerUnit:(AudioUnit)unit track:(int)track;
{
    // propagates stream formats across the connections
    Boolean outIsInitialized;
    CheckError(AUGraphIsInitialized(self.processingGraph,
                                    &outIsInitialized), "AUGraphIsInitialized");
    if(!outIsInitialized) {
        return;
    }
    if(pn < 0 || pn > 127) {
        return;
    }
    NSURL *presetURL = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"yamaha" ofType:@"sf2"]];
    /* bankURL = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle]
     pathForResource:@"gs_instruments" ofType:@"dls"]];*/
    NSLog(@"set pn %d", pn);
    
    // fill out a bank preset data structure
    AUSamplerBankPresetData bpdata;
    if (track==9) {
        bpdata.bankURL  = (__bridge CFURLRef) presetURL;
        bpdata.bankMSB  = kAUSampler_DefaultPercussionBankMSB;
        bpdata.bankLSB  = kAUSampler_DefaultBankLSB;
        bpdata.presetID = (UInt8) pn;
        
    }else
    {
        bpdata.bankURL  = (__bridge CFURLRef) presetURL;
        bpdata.bankMSB  = kAUSampler_DefaultMelodicBankMSB;
        bpdata.bankLSB  = kAUSampler_DefaultBankLSB;
        bpdata.presetID = (UInt8) pn;
        
    }
    
    
    // set the kAUSamplerProperty_LoadPresetFromBank property
    CheckError(AudioUnitSetProperty(unit,
                                    kAUSamplerProperty_LoadPresetFromBank,
                                    kAudioUnitScope_Global,
                                    0,
                                    &bpdata,
                                    sizeof(bpdata)), "kAUSamplerProperty_LoadPresetFromBank");
    
    // AudioUnitAddRenderNotify(self.samplerUnit, synthRenderCallback, (__bridge void *)(self));
    
    NSLog (@"sampler ready");
}
-(void)loadMIDIFileIntro
{
      NSLog(@"PLAYMIDIFILEINTRO");
    
    self.introMusicSequence=[SequenceData new];
    CheckError(NewMusicPlayer(&_introMusicPlayer), "NewMusicPlayer");
    NSURL *midiFileURL = [[NSURL alloc] initFileURLWithPath:
                          [[NSBundle mainBundle] pathForResource:self.currentSongName
                                                          ofType:@"MID"]];
    
    CheckError(MusicSequenceFileLoad(self.introMusicSequence.sequence,
                                     (__bridge CFURLRef) midiFileURL,
                                     0, // can be zero in many cases
                                     kMusicSequenceLoadSMF_ChannelsToTracks), "MusicSequenceFileLoad");
    
    
    
    
    
    UInt32 trackCount;
    CheckError(MusicSequenceGetTrackCount(self.introMusicSequence.sequence, &trackCount), "MusicSequenceGetTrackCount");
    // NSLog(@"Number of tracks: %lu", trackCount);
    
    [_introMusicSequence parseEvents];
    
    if (trackCount>MAX_TRACKS) {
        trackCount=MAX_TRACKS;
    }
    CheckError(MusicSequenceSetAUGraph(self.introMusicSequence.sequence, self.processingGraph),
               "MusicSequenceSetAUGraph");
    for(int i = 0; i < trackCount; i++)
    {
        
        Instrument  *instrument=self.instruments[i];
        AUNode  node=instrument.instrumentNode;
        // AudioUnit unit=instrument.instrumentUnit;
        
        MusicTrack track = NULL;
        MusicTimeStamp trackLen = 0;
        
        UInt32 trackLenLen = sizeof(trackLen);
        
        MusicSequenceGetIndTrack(_introMusicSequence.sequence, i, &track);
        MusicTrackSetDestNode(track, node);
        
        MusicTrackGetProperty(track, kSequenceTrackProperty_TrackLength, &trackLen, &trackLenLen);
        
            
            MusicTrackLoopInfo loopInfo = { trackLen, 0 };
            loopInfo.numberOfLoops=5000;
            MusicTrackSetProperty(track, kSequenceTrackProperty_LoopInfo, &loopInfo, sizeof(loopInfo));
            
            SequenceTrack  *vtrack=self.introMusicSequence.tracks[i];
           //CheckError( AudioUnitSetParameter(_mixerUnit, kMultiChannelMixerParam_Volume, kAudioUnitScope_Input, i,vtrack.volume, 0),"broken");
        
        
        
    }
    
    
    
    CheckError(MusicPlayerSetSequence(_introMusicPlayer,self.introMusicSequence.sequence), "MusicPlayerSetSequence");
    CheckError(MusicPlayerPreroll(_introMusicPlayer), "MusicPlayerPreroll");
}

-(void)playMidiFile
{
    
    NSLog(@"PLAYMIDIFILE");
   /* self.currentBeat=-1;
    [self loadMIDIFileIntro];
    
    
    UInt32 trackCount;
    CheckError(MusicSequenceGetTrackCount(self.introMusicSequence.sequence, &trackCount), "MusicSequenceGetTrackCount");
    // NSLog(@"Number of tracks: %lu", trackCount);
    
    [_introMusicSequence parseEvents];
    
    if (trackCount>MAX_TRACKS) {
        trackCount=MAX_TRACKS;
    }
    
    for (int i=0; i<trackCount; i++) {
        Instrument *instrument=self.instruments[i];
        AudioUnit  unit=instrument.instrumentUnit;
        SequenceTrack  *strack=self.introMusicSequence.tracks[i];
        [self setupSampler:strack.presetNumber samplerUnit:unit track:i];
    }
    [self startGraph];
    MusicTrack tempoTrack;
    
    MusicSequenceGetTempoTrack (self.introMusicSequence.sequence, &tempoTrack);
    MusicTrackNewExtendedTempoEvent(tempoTrack, 0, self.tempo);
    
    CheckError(MusicPlayerStart(self.introMusicPlayer), "MusicPlayerStart");*/
    
    self.currentBeat=-1;
    [self loadMIDIFileIntro];
    
    
    UInt32 trackCount;
    CheckError(MusicSequenceGetTrackCount(self.introMusicSequence.sequence, &trackCount), "MusicSequenceGetTrackCount");
    // NSLog(@"Number of tracks: %lu", trackCount);
    
    [_introMusicSequence parseEvents];
    
    if (trackCount>MAX_TRACKS) {
        trackCount=MAX_TRACKS;
    }
    
    for (int i=0; i<trackCount; i++) {
        Instrument *instrument=self.instruments[i];
        AudioUnit  unit=instrument.instrumentUnit;
        SequenceTrack  *strack=self.introMusicSequence.tracks[i];
        [self setupSampler:strack.presetNumber samplerUnit:unit track:i];
    }
    [self startGraph];
    MusicTrack tempoTrack;
    
    MusicSequenceGetTempoTrack (self.introMusicSequence.sequence, &tempoTrack);
    MusicTrackNewExtendedTempoEvent(tempoTrack, 0, self.tempo);
    
    CheckError(MusicPlayerStart(self.introMusicPlayer), "MusicPlayerStart");


}
@end
