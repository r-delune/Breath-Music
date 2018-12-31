//
//  SongAudioEngine.m
//  BreathMusic
//
//  Created by barry on 08/09/2014.
//  Copyright (c) 2014 rocudo. All rights reserved.
//

#import "SongAudioEngine.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "GDCoreAudioUtils.h"
#import "GCDQueue.h"
#import "NoteEvent.h"
#import "SequenceData.h"
#import "Instrument.h"
#define MAX_TRACKS 1

@interface SongAudioEngine ()
{
    MIDIPortRef outputPort;
    MIDIEndpointRef virtualEndpoint;
    MIDIClientRef virtualMidi;
}

@property (readwrite) AudioUnit samplerUnit;

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
@property int presetIndex;

@property(nonatomic,strong)NSString *currentInstrument;
@property(readwrite)UInt8 currentPresetNumber;

@property int currentPrefix;

@property int numparts;
@property(nonatomic,strong)NSString  *filename;


@property int lastIndex;
@property int currentSong;

@property MusicTimeStamp fullLength;
@property MusicTimeStamp position;

@property(nonatomic,strong)NSTimer *stitchTimer;
@property(nonatomic,strong)NSMutableArray  *stitchTimes;
@property int lastCompleteStichTimeIndex;
@end
@implementation SongAudioEngine

SongAudioEngine * refToSelf;
bool _allowNextNote;

-(void)setSongWithID:(int)theid
{

}

-(void)setMidiStyle:(NSDictionary*)style 
{   
    self.tempo=[[style valueForKey:@"SongTempo"]intValue];
    self.numparts=[[style valueForKey:@"SongPartCount"]intValue];
    self.filename=[style valueForKey:@"SongFileName"];
    
}

- (id) init
{
    NSLog(@"initing");
    _allowNextNote = true;
    
    if ( self = [super init] ) {
        self.chordSequences=[NSMutableArray new];
        self.instruments=[NSMutableArray new];
        for (int i=0; i<MAX_TRACKS; i++) {
            
            Instrument  *instrument=[Instrument new];
            [self.instruments addObject:instrument];
        }
        // [self setupStereoStreamFormat];
        [self createAUGraph];
        self.stylenumber=21;
        self.beatsperbar=4;
        self.tempo=110;
        self.lastCompleteStichTimeIndex=0;
        self.position=0.0f;
    }
    
    return self;
}

-(void)createAUGraph
{
    NSLog(@"stopMidiNote MIDI");

    refToSelf=self;
    [self createMidiDestination];
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
    
    //  AUGraphAddRenderNotify(_processingGraph, renderCallback, (__bridge void*) self);
	CAShow(self.processingGraph);
    
    [self startGraph];
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
    
    NSLog(@"startGraph");
}

- (void) stopAUGraph {
    
    NSLog (@"Stopping audio processing graph");
    Boolean isRunning = false;
    CheckError(AUGraphIsRunning (self.processingGraph, &isRunning), "AUGraphIsRunning");
    
    if (isRunning) {
        CheckError(AUGraphStop(self.processingGraph), "AUGraphStop");
    }
}
#pragma mark - Sampler

- (void) setupSampler:(UInt8) pn samplerUnit:(AudioUnit)unit track:(int)track;
{
    // propagates stream formats across the connections
    
    NSLog(@"SONG MODE - SETTING UP SAMPLER");
    Boolean outIsInitialized;
    CheckError(AUGraphIsInitialized(self.processingGraph,
                                    &outIsInitialized), "AUGraphIsInitialized");
    if(!outIsInitialized) {
        return;
    }
   
    if(pn < 0 || pn > 127) {
        NSLog(@"returning as value is above 127");
        return;
    }
    
     //pn=pn-1;
    
    NSLog(@"SONG AUDIO SETUP SAMPLER set pn %d WITH TRACK %d", pn, track);
    NSURL *presetURL = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"yamaha" ofType:@"sf2"]];
        /* bankURL = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle]
         pathForResource:@"gs_instruments" ofType:@"dls"]];*/
    //pn = self.currentPresetNumber;
    //pn = self.currentPrefix;
    
    
    NSLog(@"SONG AUDIO ENGINE setupSampler PN set pn/ self.currentPresetNumber %@", [NSString stringWithFormat:@"%d",self.currentPresetNumber]);
    NSLog(@"SONG AUDIO ENGINE setupSampler PN set pn/ currentPrefix %@", [NSString stringWithFormat:@"%d",self.currentPrefix]);
    NSLog(@"track = %d", track);
    
        if (pn==0) {
            pn=73;
        }
    
    // fill out a bank preset data structure
    
    AUSamplerBankPresetData bpdata;
    if (track==9) {
        bpdata.bankURL  = (__bridge CFURLRef) presetURL;
        bpdata.bankMSB  = kAUSampler_DefaultPercussionBankMSB;//
        bpdata.bankLSB  = kAUSampler_DefaultBankLSB;///
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

-(void)loadMIDIFile
{
    CheckError(NewMusicPlayer(&_musicPlayer), "NewMusicPlayer");
    CheckError(NewMusicSequence(&_currentSequence), "NewMusicSequence");
    
    CheckError(MusicSequenceSetAUGraph(self.currentSequence, self.processingGraph),
               "MusicSequenceSetAUGraph");
    
    
    NSLog(@"loadmidi");
    
    NSMutableArray  *midifilenames=[NSMutableArray new];
    
    for (int i=0; i<self.numparts; i++) {
        int num=i+1;
        
        
        [midifilenames addObject:[NSString stringWithFormat:@"%@_part%i",self.filename,num]];
        SequenceData  *dataA=[[SequenceData alloc]init];
        [self.chordSequences addObject:dataA];

    }
    
    for (int i=0;i<[self.chordSequences count]; i++)
    {
        SequenceData  *data=self.chordSequences[i];
        NSURL *midiFileURL = [[NSURL alloc] initFileURLWithPath:
                              [[NSBundle mainBundle] pathForResource:midifilenames[i]
                                                              ofType:@"mid"]];
        
        CheckError(MusicSequenceFileLoad(data.sequence,
                                         (__bridge CFURLRef) midiFileURL,
                                         0, // can be zero in many cases
                                         kMusicSequenceLoadSMF_ChannelsToTracks), "MusicSequenceFileLoad");
        
        CheckError(MusicSequenceSetAUGraph(data.sequence, self.processingGraph),
                   "MusicSequenceSetAUGraph");
        
        [data parseEvents];
    }
    
    
    
    SequenceData  *data1=self.chordSequences[0];
    
    UInt32 trackCount;
    CheckError(MusicSequenceGetTrackCount(data1.sequence, &trackCount), "MusicSequenceGetTrackCount");
    // NSLog(@"Number of tracks: %lu", trackCount);
    if (trackCount>MAX_TRACKS) {
        trackCount=MAX_TRACKS;
    }
    
    for(int i = 0; i < trackCount; i++)
    {
        NSLog(@"LAODING MIDI FILE pn ");
        NSLog(@"LAODING MIDI FILE pn %u", (unsigned int)trackCount);
        NSLog(@"LAODING MIDI FILE pn %d", i);
        
        MusicTrack track = NULL;
        MusicTimeStamp trackLen = 0;
        UInt32 trackLenLen = sizeof(trackLen);
        MusicSequenceGetIndTrack(data1.sequence, i, &track);
        MusicTrackGetProperty(track, kSequenceTrackProperty_TrackLength, &trackLen, &trackLenLen);
        MusicTrack tracknew = NULL;
        MusicSequenceNewTrack(self.currentSequence, &tracknew);
       // MusicTrackCopyInsert(track, 0, trackLen, tracknew, 0);
        Instrument  *instrument=self.instruments[i];
        AUNode node=instrument.instrumentNode;
        MusicTrackSetDestNode(tracknew, node);
          SequenceTrack  *strack=data1.tracks[i];
         AudioUnit  unit=instrument.instrumentUnit;
         [self setupSampler:strack.presetNumber samplerUnit:unit track:i];
    }
    
    MusicSequenceSetMIDIEndpoint(self.currentSequence, virtualEndpoint);

    CheckError(MusicPlayerSetSequence(self.musicPlayer, self.currentSequence), "MusicPlayerSetSequence");
   // [self copyTracksFromSequence:data1];
    

    [self stitchMidiData];
}

-(void)stitchMidiData
{
    NSLog(@"stitchMidiData");
    if (self.stitchTimes) {
       // [self.stitchTimes removeAllObjects];
       // self.stitchTimes=nil;
        return;
    }
    
    self.stitchTimes=[NSMutableArray new];
    [self clearMainSequence];
    UInt32 trackCount;
    MusicTimeStamp test=0;
    MusicTimeStamp runningLen=0;

    for (int i=0;i<[self.chordSequences count]; i++)
    {
        SequenceData  *data=self.chordSequences[i];
        
        MusicSequence msequence=data.sequence;
         MusicSequenceSetMIDIEndpoint(data.sequence, virtualEndpoint);
        CheckError(MusicSequenceGetTrackCount(msequence, &trackCount), "MusicSequenceGetTrackCount");
        MusicTimeStamp trackLen = 0;

        for(int i = 0; i < trackCount; i++)
        {
            
            UInt32 trackLenLen = sizeof(trackLen);
            MusicTrack track = NULL;
            MusicTrack tmpTrack;
            MusicSequenceGetIndTrack(msequence, i, &tmpTrack);

            MusicTrackGetProperty(tmpTrack, kSequenceTrackProperty_TrackLength, &trackLen, &trackLenLen);
            MusicSequenceGetIndTrack(self.currentSequence, i, &track);
            MusicTrackGetProperty(track, kSequenceTrackProperty_TrackLength, &runningLen, &trackLenLen);

            MusicTrackCopyInsert(tmpTrack, 0, trackLen, track, runningLen);
        }
        
        self.fullLength+=trackLen;

        NSNumber  *value=[NSNumber numberWithFloat:floor(test)];
        
        //if ([self.stitchTimes count]>0) {
           // float last=[[self.stitchTimes lastObject]floatValue];
            
           // if (last!=runningLen) {
              //  [self.stitchTimes addObject:value];

           // }

       // }else
       // {
          [self.stitchTimes addObject:value];
      //  [self.delegate logOutput:[NSString stringWithFormat:@"new strictch time== %f",test]];

       // }
        test+=trackLen;
    }
    [[GCDQueue mainQueue]queueBlock:^{
        [self beginTimer];

    }];

}

-(void)clearMainSequence
{
    NSLog(@"CLEAR MAIN");
    
    UInt32 trackCount;

    CheckError(MusicSequenceGetTrackCount(self.currentSequence, &trackCount), "MusicSequenceGetTrackCount");
     NSLog(@"Number of tracks: %u", (unsigned int)trackCount);
    
    
    for(int i = 0; i < trackCount; i++)
    {
        MusicTimeStamp trackLen = 0;
        UInt32 trackLenLen = sizeof(trackLen);
        
        MusicTrack track = NULL;
        MusicTrack tmpTrack;
        MusicSequenceGetIndTrack(self.currentSequence, i, &tmpTrack);
        MusicTrackGetProperty(tmpTrack, kSequenceTrackProperty_TrackLength, &trackLen, &trackLenLen);
        
        
        MusicSequenceGetIndTrack(self.currentSequence, i, &track);
        
        MusicTrackClear(track, 0, trackLen);
        
        MusicTrackCut(track, 0, trackLen);
    }
}

-(void)copyTracksFromSequence:(SequenceData*)sequence
{
    UInt32 trackCount;
    
    if (!sequence) {
        return;
    }
    
    MusicSequence msequence=sequence.sequence;
    CheckError(MusicSequenceGetTrackCount(msequence, &trackCount), "MusicSequenceGetTrackCount");
    NSLog(@"Number of tracks: %u", (unsigned int)trackCount);
    

    for(int i = 0; i < trackCount; i++)
    {
        MusicTimeStamp trackLen = 0;
        UInt32 trackLenLen = sizeof(trackLen);
        
        MusicTrack track = NULL;
        MusicTrack tmpTrack;
        MusicSequenceGetIndTrack(msequence, i, &tmpTrack);
        MusicTrackGetProperty(tmpTrack, kSequenceTrackProperty_TrackLength, &trackLen, &trackLenLen);
        
        
        MusicSequenceGetIndTrack(self.currentSequence, i, &track);
        
        MusicTrackClear(track, 0, trackLen);
        
        
        MusicTrackCopyInsert(tmpTrack, 0, trackLen, track, 0);
        
        SequenceTrack  *vtrack=sequence.tracks[i];
        //AudioUnitSetParameter(_mixerUnit, kMultiChannelMixerParam_Volume, kAudioUnitScope_Input, i,vtrack.volume, 0);
        //AudioUnitSetParameter(_mixerUnit, kMultiChannelMixerParam_Volume, kAudioUnitScope_Input, i,vtrack.volume, 0);

    }
}

- (void) playMIDIFile
{
    //A USER HIT A KEY BEFORE HITTING START
    
    if (self.musicPlayer) {
        return;
    }
    if (!self.musicPlayer) {
        
        [self loadMIDIFile];
        
    }
    
    
    NSLog(@"starting music player");
    
    MusicTrack tempoTrack;
    
    MusicSequenceGetTempoTrack (self.currentSequence, &tempoTrack);
    MusicTrackNewExtendedTempoEvent(tempoTrack, 0, self.tempo);

    //self.lastSequence=self.chordSequences[1];
    
}

-(void) cleanup
{
    //8i NSLog(@"cleanup %@", _lastIndex);
    
    MusicPlayerStop(self.musicPlayer);
    
    AUGraphStop(self.processingGraph);
    AUGraphClearConnections(self.processingGraph);
    AUGraphUninitialize(self.processingGraph);
    
    for (int i=0; i<[self.chordSequences count]; i++) {
        SequenceData  *data=self.chordSequences[i];
        [data cleanup];
    }
}

-(void)playIndex:(int)index
{
    if (!self.musicPlayer) {
        return;
    }
    
    
    NSLog(@"playing sequence");
    
    Boolean isplaying;
    MusicPlayerIsPlaying(self.musicPlayer, &isplaying);
    
    
    //    CheckError(MusicPlayerStart(self.musicPlayer), "MusicPlayerStart");

    if (!isplaying) {
        //[self stitchMidiData];
       // CheckError(MusicPlayerStart(self.musicPlayer), "MusicPlayerStart");
        
    }
    
   // [self clearMainSequence];

    SequenceData  *data=self.chordSequences[index];
    MusicSequenceSetMIDIEndpoint(data.sequence, virtualEndpoint);
    MusicPlayerStop(self.musicPlayer);
    MusicPlayerSetSequence(self.musicPlayer, data.sequence);
    //[self copyTracksFromSequence:data];
   // CheckError(MusicSequenceSetAUGraph(data.sequence, self.processingGraph),
        //       "MusicSequenceSetAUGraph");
    MusicPlayerSetTime(self.musicPlayer, 0.0f);
    MusicPlayerPreroll(self.musicPlayer);
    MusicPlayerStart(self.musicPlayer);
}

-(void)setInstrument:(int)instrument
{
    instrument=instrument-1;
    self.currentPresetNumber=instrument;
    self.currentPrefix=instrument;
    NSLog(@"SET INSTRUMENT SCALE GAME set self.currentPrefix %d", self.currentPrefix);
    NSLog(@"SET INSTRUMENT SCALE GAME set self.currentPresetNumber %d", self.currentPresetNumber);
    NSURL *bankURL;
    bankURL = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle]
                                                  pathForResource:@"yamaha" ofType:@"sf2"]];
    
    // fill out a bank preset data structure
    AUSamplerBankPresetData bpdata;
    bpdata.bankURL  = (__bridge CFURLRef) bankURL;
    bpdata.bankMSB  = kAUSampler_DefaultMelodicBankMSB;
    bpdata.bankLSB  = kAUSampler_DefaultBankLSB;
    bpdata.presetID = (UInt8) instrument;
    
    ///NSLog(@"Palying ISTRU %d", _lastIndex);
    NSLog(@"SONG ENGINE setInstrument set cuyrrent prefix to %i", self.currentPrefix);
    NSLog(@"SONG ENGINE setInstrument set cuyrrent song to %i", self.currentPresetNumber);

    /*
     bankURL = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle]
     pathForResource:@"FluidR3_GM" ofType:@"sf2"]];
     */

    // fill out a bank preset data structure
    
      for(int i=0; i<[self.instruments count]; i++) {
        // Extract the sampler note from the NSValue into the samplerNode variable
        NSLog(@"SONG ENGINE %i - %@", i, self.instruments[i]);
        
        Instrument *instrument = self.instruments[i];
          
        //NSLog(@"SONG ENGINE %i - %@", i, instrument.instrumentUnit);
          NSLog(@"SONG ENGINE %i - %d", i, (int)instrument.instrumentNode);
          
        CheckError(AudioUnitSetProperty(instrument.instrumentUnit,
                                        kAUSamplerProperty_LoadPresetFromBank,
                                        kAudioUnitScope_Global,
                                        0,
                                        &bpdata,
                                        sizeof(bpdata)), "kAUSamplerProperty_LoadPresetFromBank");
          
        // set the kAUSamplerProperty_LoadPresetFromBank property
        //CheckError(AudioUnitSetProperty(self.samplerUnit,
        //                                  kAUSamplerProperty_LoadPresetFromBank,
        //                                  kAudioUnitScope_Global,
        //                                  0,
        //                                  &bpdata,
        //                                  sizeof(bpdata)), "kAUSamplerProperty_LoadPresetFromBank");
    }
}

-(void)beginBreath
{
    if (!self.musicPlayer) {
        return;
        
    }
    Boolean isplaying;
    MusicPlayerIsPlaying(self.musicPlayer, &isplaying);
    
    NSLog(@"breathing");
    //    CheckError(MusicPlayerStart(self.musicPlayer), "MusicPlayerStart");
    
    if (!isplaying) {
        
       // [self.delegate logOutput:@"not playing"];
        [self stitchMidiData];
        MusicPlayerSetTime(self.musicPlayer, self.position);
        MusicPlayerPreroll(self.musicPlayer);
        CheckError(MusicPlayerStart(self.musicPlayer), "MusicPlayerStart");
    }
}

-(void)beginTimer
{
    if (self.stitchTimer) {
        [self.stitchTimer invalidate];
        self.stitchTimer=nil;
    }
    
    self.stitchTimer=[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(stitchTimerHandler:) userInfo:nil repeats:YES];
}

-(void)stitchTimerHandler:(NSTimer*)timer
{
    BOOL  continuous=[[[NSUserDefaults standardUserDefaults]valueForKey:@"continuousBreath"]boolValue];
   /// NSLog(@"stitchTimerHandler MIDI");
    
    MusicTimeStamp  pos;
    MusicPlayerGetTime(self.musicPlayer, &pos);
   // int found=0;
    //[self.delegate logOutput:[NSString stringWithFormat:@"current pos == %f",pos]];
    
    for (int i=0; i<[self.stitchTimes count]; i++) {
        
        NSNumber  *value=self.stitchTimes[i];
       // NSLog(@"stitch value %@", value);
        
        if (pos>=[value floatValue] && _allowNextNote == true) {
            
            NSLog(@"[self.stitchTimes count] %lu", (unsigned long)[self.stitchTimes count]);
            NSLog(@"pos %f", pos);
            NSLog(@"[value floatValue] %f", [value floatValue]);
            NSLog(@"OTHER - playing next note");
            
            
            if (continuous == 0 && pos != 0.000000){
                NSLog(@"OTHER disallowing next note");
                
                _allowNextNote = false;
            }
            
            NSNumber  *newval=[NSNumber numberWithFloat:MAXFLOAT];
            self.stitchTimes[i]=newval;
            self.lastCompleteStichTimeIndex=i;
            [self.delegate stictchedSongPassedIndex:i];

            
            if (continuous == 0){
                NSLog(@"OTHER stopping next note");
                [self.delegate stopEngine];
            }
            
            //found=i;
            return;
            
        }else if (pos>=[value floatValue] && _allowNextNote == false){
         //    NSLog(@"OTHER - pos %f", pos);
         //    NSLog(@"OTHER - [value floatValue] %f", [value floatValue]);
         //  NSLog(@" OTHER Note disallowed - STOPPING ENGINE");
          //  [self.delegate stopEngine];
        }
    }
    
    if (pos>=self.fullLength) {
        [self stopBreath];
        
        NSLog(@"stitch time handler");
       // [self.delegate reset];
       // self.delegate=nil;
       // [timer invalidate];
        
    }
}

-(void)stopBreath
{
    NSLog(@"OTHER stopped breath and allowing");
    Boolean isplaying;
    MusicPlayerIsPlaying(self.musicPlayer, &isplaying);
    if (!isplaying) {
        return;
    }
    MusicPlayerStop(self.musicPlayer);
    
    BOOL  continuous=[[[NSUserDefaults standardUserDefaults]valueForKey:@"continuousBreath"]boolValue];
    
    
    _allowNextNote = true;
    
    NSLog(@"continous set to %d", continuous);
/*
    if (continuous==NO) {
        
        for (int i=0; i<[self.stitchTimes count]; i++) {
            
            MusicTimeStamp num=[self.stitchTimes[i]floatValue];
            if (num!=MAXFLOAT) {
                // NSLog(@"CONTINOUS IS NOT ON! %d", continuous);
                self.position=num;
                MusicPlayerSetTime(self.musicPlayer, self.position);
                NSNumber  *newval=[NSNumber numberWithFloat:MAXFLOAT];
                self.stitchTimes[i]=newval;
                [self.delegate stictchedSongPassedIndex:i];

                break;
                return;
            }
        }
    }*/

  //      NSLog(@"CONTINOUS IS ON! %d", continuous);
    MusicTimeStamp  pos;
    MusicPlayerGetTime(self.musicPlayer, &pos);
    self.position=pos;
    if (pos>=self.fullLength) {
        [self.delegate reset];
        if (self.stitchTimer) {
            [self.stitchTimer invalidate];
            self.stitchTimer=nil;
        }
        
    }
    
    
    if (continuous == NO){
        NSLog(@"sTOPPING");
        MusicPlayerStop(self.musicPlayer);
    }

}

#pragma mark Send Routines

void MyMIDINotifyProc2 (const MIDINotification  *message, void *refCon) {
  //  printf("MIDI Notify, messageId=%ld,", message->messageID);
    
}

- (void) setupReceiver {
    
    if (virtualMidi) {
        return;
    }
    OSStatus s = MIDIClientCreate((CFStringRef)@"How ya MIDI Client222", nil, (__bridge void *)(self), &virtualMidi);

    // Create an endpoint
    void* callbackContext = (__bridge void*) self;
    s = MIDIDestinationCreate(virtualMidi, CFSTR("Virtual Destination"), ReadProc,nil, &virtualEndpoint);

   // NSString *inName = [NSString stringWithFormat:@"Magical MIDI Destination77"];
   // s = MIDIDestinationCreate(virtualMidi, (__bridge CFStringRef)inName, ReadProc,  (__bridge void *)self, &virtualInTemp);
    
    //s = MIDIClientCreate((CFStringRef)@"How ya MIDI Client45", nil, (__bridge void *)(self), &virtualMidi);
    s = MIDIOutputPortCreate(virtualMidi, (CFStringRef)@"how ya Output Port876", &outputPort);

}

void ReadProc(const MIDIPacketList *packetList, void *readProcRefCon, void *srcConnRefCon)
{
    SongAudioEngine  *enginge=refToSelf;
    
  //  MIDIPacket *packet = (MIDIPacket *)packetList->packet;
  /*  for (int i=0; i < packetList->numPackets; i++) {
        Byte midiStatus = packet->data[0];
        Byte midiCommand = midiStatus >> 4;
        
                if (midiCommand == 0x09) {
            Byte note = packet->data[1] & 0x7F;
            Byte velocity = packet->data[2] & 0x7F;
            
           // OSStatus result = noErr;
            for (int i=0; i<[enginge.instruments count]; i++) {
                Instrument  *inst=enginge.instruments[i];
                AudioUnit payer=inst.instrumentUnit;
                MusicDeviceMIDIEvent (payer, midiStatus, note, velocity, 0);

            }
       }
        packet = MIDIPacketNext(packet);
        [enginge sendPacketList:packetList];
    }*/
    
    MIDIPacket *packet = (MIDIPacket *)packetList->packet;
    for (int i=0; i < packetList->numPackets; i++) {
        Byte midiStatus = packet->data[0];
        Byte midiCommand = midiStatus >> 4;
        // is it a note-on or note-off
       /// printf("midiCommand=%d. \n", midiCommand);
        if (midiCommand==0) {
            return;
        }
        if ((midiCommand == 0x09) ||
            (midiCommand == 0x08)) {
            Byte note = packet->data[1] & 0x7F;
            Byte velocity = packet->data[2] & 0x7F;
         UInt8 noteOn[]  = {midiCommand, note, velocity };
       
            Instrument  *inst=enginge.instruments[0];
                AudioUnit payer=inst.instrumentUnit;
                MusicDeviceMIDIEvent (payer,midiStatus,note,velocity,0);
                //  NSLog(@"midicommand");
          }
       // }
        packet = MIDIPacketNext(packet);
    }
    
    // UInt8 noteOn[]  = {192, refToSelf.currentPresetNumber , 0 };
    // [refToSelf sendBytes:noteOn size:sizeof(&noteOn)];
    [refToSelf sendPacketList:packetList];
}

#pragma mark Send Routines
- (void) sendBytes:(const UInt8*)bytes size:(UInt32)size
{
    //NSLog(@"sendBytes:%s(%u bytes to core MIDI)", __func__, unsigned(size));
    assert(size < 65536);
    Byte packetBuffer[size+100];
    MIDIPacketList *packetList = (MIDIPacketList*)packetBuffer;
    MIDIPacket     *packet     = MIDIPacketListInit(packetList);
    packet = MIDIPacketListAdd(packetList, sizeof(packetBuffer), packet, 0, size, bytes);
    
    [self sendPacketList:packetList];
}

- (void) sendPacketList:(const MIDIPacketList *)packetList
{
    int midiDestinations=MIDIGetNumberOfDestinations();
    
    for (ItemCount index = 0; index < MIDIGetNumberOfDestinations(); ++index)
    {
        MIDIEndpointRef outputEndpoint = MIDIGetDestination(index);
        CFStringRef name = nil;
        MIDIObjectGetStringProperty(outputEndpoint, kMIDIPropertyName, &name);
        CFStringRef virtualname=CFSTR("Virtual Destination");

        if (CFStringCompare(name, virtualname, 0)){
           // NSLog(@"Wrong");
            if (outputEndpoint)
            {
                // Send it
                MIDISend(outputPort, outputEndpoint, packetList);
            }
        }
    }
}

-(void)createMidiDestination
{
    [self setupReceiver];

}

@end
