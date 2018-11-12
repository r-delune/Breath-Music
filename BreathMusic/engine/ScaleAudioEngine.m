//
//  ScaleAudioEngine.m
//  BreathMusic
//
//  Created by barry on 05/09/2014.
//  Copyright (c) 2014 rocudo. All rights reserved.
//

#import "ScaleAudioEngine.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "GDCoreAudioUtils.h"
@interface ScaleAudioEngine ()
{
    MIDIClientRef      client;
    MIDIPortRef        outputPort;
    UInt32 currentNote;

}

@property (readwrite) AUGraph processingGraph;
@property (readwrite) AUNode samplerNode;
@property (readwrite) AUNode ioNode;
@property (readwrite) AudioUnit samplerUnit;
@property (readwrite) AudioUnit ioUnit;

@property(nonatomic,strong)NSString *currentKey;
@property(readwrite)int currentOctave;
@property(nonatomic,strong)NSString *currentInstrument;
@property(readwrite)UInt8 currentPresetNumber;

@property int currentPrefix;

@property UInt32  velocity;
@property(nonatomic,strong)NSTimer  *midiStopTimer;
@end
@implementation ScaleAudioEngine
-(void)stopTimer
{
    if (self.midiStopTimer) {
        [self.midiStopTimer invalidate];
        self.midiStopTimer=nil;
    }
}
-(void)startTimer
{
    if (self.midiStopTimer) {
        [self stopTimer];
    }
    self.midiStopTimer=[NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(midiStopTiemrFunction:) userInfo:nil repeats:NO];
}
-(void)midiStopTiemrFunction:(NSTimer*)timer
{
 
    [self stopTimer];
    UInt32 midiStatus;
   
    midiStatus = 0x80;      // note on message
    
    MusicDeviceMIDIEvent (_samplerUnit,
                          midiStatus,
                          0,
                          100,
                          0);
    UInt8 kMIDIMessage_ControlModeChange = 0xB0;
    UInt8 kMIDIMessage_ControlTypeAllSoundOff = 0x58;
    
    MusicDeviceMIDIEvent(_samplerUnit, kMIDIMessage_ControlModeChange, kMIDIMessage_ControlTypeAllSoundOff, 0, 0);
    
    //UInt8 noteOff[] = { 0x80, 100, 0   };
    UInt8 noteOff[] = { 0x58, 0, 0   };

    [self sendBytes:noteOff size:sizeof(noteOff)];
    const int kMIDINoteOff = 0x8 << 4;

    MusicDeviceMIDIEvent(_samplerUnit, kMIDINoteOff, currentNote, 127, 0);
}
-(void)setup
{
    OSStatus s = MIDIClientCreate((CFStringRef)@"How ya MIDI Client", nil, (__bridge void *)(self), &client);
    
    s = MIDIOutputPortCreate(client, (CFStringRef)@"how ya Output Port", &outputPort);

    //BD
    //self.currentPresetNumber=7;
    self.currentOctave=3;
    [self createAUGraph];
    [self startGraph];
    [self setupSampler:self.currentPresetNumber];
    //[self setupSampler:self.currentPrefix];
    NSLog(@"Setting up sampler with %hhu", self.currentPresetNumber);
    NSLog(@"Setting up sampler prefix with %d", self.currentPrefix);
}
#pragma mark - Audio setup
- (BOOL) createAUGraph
{
    NSLog(@"Creating the graph");
    
    CheckError(NewAUGraph(&_processingGraph),
			   "NewAUGraph");
    
    // create the sampler
    // for now, just have it play the default sine tone
	AudioComponentDescription cd = {};
	cd.componentType = kAudioUnitType_MusicDevice;
	cd.componentSubType = kAudioUnitSubType_Sampler;
	cd.componentManufacturer = kAudioUnitManufacturer_Apple;
	cd.componentFlags = 0;
	cd.componentFlagsMask = 0;
	CheckError(AUGraphAddNode(self.processingGraph, &cd, &_samplerNode), "AUGraphAddNode");
    
    
    // I/O unit
    AudioComponentDescription iOUnitDescription;
    iOUnitDescription.componentType          = kAudioUnitType_Output;
    iOUnitDescription.componentSubType       = kAudioUnitSubType_RemoteIO;
    iOUnitDescription.componentManufacturer  = kAudioUnitManufacturer_Apple;
    iOUnitDescription.componentFlags         = 0;
    iOUnitDescription.componentFlagsMask     = 0;
    
    CheckError(AUGraphAddNode(self.processingGraph, &iOUnitDescription, &_ioNode), "AUGraphAddNode");
    
    // now do the wiring. The graph needs to be open before you call AUGraphNodeInfo
	CheckError(AUGraphOpen(self.processingGraph), "AUGraphOpen");
    
	CheckError(AUGraphNodeInfo(self.processingGraph, self.samplerNode, NULL, &_samplerUnit),
               "AUGraphNodeInfo");
    
    CheckError(AUGraphNodeInfo(self.processingGraph, self.ioNode, NULL, &_ioUnit),
               "AUGraphNodeInfo");
    
    AudioUnitElement ioUnitOutputElement = 0;
    AudioUnitElement samplerOutputElement = 0;
    CheckError(AUGraphConnectNodeInput(self.processingGraph,
                                       self.samplerNode, samplerOutputElement, // srcnode, inSourceOutputNumber
                                       self.ioNode, ioUnitOutputElement), // destnode, inDestInputNumber
               "AUGraphConnectNodeInput");
    
    
	NSLog (@"AUGraph is configured");
	CAShow(self.processingGraph);
    
    return YES;
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
        self.playing = YES;
    }
}
- (void) setupSampler:(UInt8) pn;
{
    Boolean outIsInitialized;
    CheckError(AUGraphIsInitialized(self.processingGraph,
                                    &outIsInitialized), "AUGraphIsInitialized");
    if(!outIsInitialized) {
        return;
    }
    if(pn < 0 || pn > 127) {
        return;
    }
    NSURL *bankURL;
   
    bankURL = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle]
                                                  pathForResource:@"yamaha" ofType:@"sf2"]];
    NSLog(@"BD SETTING PN set pn %d", pn);
    
    AUSamplerBankPresetData bpdata;
    bpdata.bankURL  = (__bridge CFURLRef) bankURL;
    bpdata.bankMSB  = kAUSampler_DefaultMelodicBankMSB;
    bpdata.bankLSB  = kAUSampler_DefaultBankLSB;
    bpdata.presetID = (UInt8) pn;
    
    CheckError(AudioUnitSetProperty(self.samplerUnit,
                                    kAUSamplerProperty_LoadPresetFromBank,
                                    kAudioUnitScope_Global,
                                    0,
                                    &bpdata,
                                    sizeof(bpdata)), "kAUSamplerProperty_LoadPresetFromBank");
    
    NSLog (@"sampler ready");
}

-(void)setOctave:(int)octave
{
    self.currentOctave=octave;
}
-(void)setKey:(NSString *)key
{
    self.currentKey=key;
}
-(void)setInstrument:(int)instrument
{
    NSLog(@"SET self.currentPresetNumber/ INSTRUMENT set pn %d", instrument);
    
    instrument=instrument-1;
    self.currentPresetNumber=instrument;
    
    self.currentPrefix=instrument;
    
    NSURL *bankURL;
     bankURL = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle]
                                                  pathForResource:@"yamaha" ofType:@"sf2"]];
    
    
    // fill out a bank preset data structure
    AUSamplerBankPresetData bpdata;
    bpdata.bankURL  = (__bridge CFURLRef) bankURL;
    bpdata.bankMSB  = kAUSampler_DefaultMelodicBankMSB;
    bpdata.bankLSB  = kAUSampler_DefaultBankLSB;
    bpdata.presetID = (UInt8) instrument;
    
    // set the kAUSamplerProperty_LoadPresetFromBank property
    CheckError(AudioUnitSetProperty(self.samplerUnit,
                                    kAUSamplerProperty_LoadPresetFromBank,
                                    kAudioUnitScope_Global,
                                    0,
                                    &bpdata,
                                    sizeof(bpdata)), "kAUSamplerProperty_LoadPresetFromBank");
}
//pentatonic
-(UInt32)noteForString3:(NSString*)noteString
{
    UInt32  offset=0;
    
    if ([noteString isEqualToString:@"Do"]) {
        offset=0;
    }else if ([noteString isEqualToString:@"Ra"])
    {
        offset=2;
    }else if ([noteString isEqualToString:@"Mi"])
    {
        offset=5;
        
    }else if ([noteString isEqualToString:@"Fa"])
    {        offset=7;
        
        
    }else if ([noteString isEqualToString:@"So"])
    {
        offset=9;
        
    }else if ([noteString isEqualToString:@"La"])
    {
        offset=12;
        
    }else if ([noteString isEqualToString:@"Ti"])
    {
        offset=14;
        
    }else if ([noteString isEqualToString:@"Do2"])
    {
        offset=17;
        
    }
    UInt32 result=0;
    
    UInt32 root=[self rootForKey:self.currentKey];
    
    result= ( self.currentOctave*12)+(root+offset);
        
    
    return result;


}
//hava
-(UInt32)noteForString2:(NSString*)noteString
{
    UInt32  offset=0;
    
    if ([noteString isEqualToString:@"Do"]) {
        offset=0;
    }else if ([noteString isEqualToString:@"Ra"])
    {
        offset=1;
    }else if ([noteString isEqualToString:@"Mi"])
    {
        offset=4;
        
    }else if ([noteString isEqualToString:@"Fa"])
    {        offset=5;
        
        
    }else if ([noteString isEqualToString:@"So"])
    {
        offset=7;
        
    }else if ([noteString isEqualToString:@"La"])
    {
        offset=8;
        
    }else if ([noteString isEqualToString:@"Ti"])
    {
        offset=10;
        
    }else if ([noteString isEqualToString:@"Do2"])
    {
        offset=12;
        
    }
    UInt32 result=0;
    
    UInt32 root=[self rootForKey:self.currentKey];
    
   
    
        result= ( self.currentOctave*12)+(root+offset);
        
    
    return result;

}
-(UInt32)rootForKey:(NSString*)key
{
    UInt32  offset=12;
    
    
    
    if ([key isEqualToString:@"C Major"]) {
        offset=0;
    }else if ([key isEqualToString:@"D Major"])
    {
        offset=2;
    }else if ([key isEqualToString:@"E Major"])
    {
        offset=4;
        
    }else if ([key isEqualToString:@"F Major"])
    {        offset=5;
        
        
    }else if ([key isEqualToString:@"G Major"])
    {
        offset=7;
        
    }else if ([key isEqualToString:@"A Major"])
    {
        offset=9;
        
    }else if ([key isEqualToString:@"B Major"])
    {
        offset=11;
        
    }
    
    else if ([key isEqualToString:@"B Major"])
    {
        offset=11;
        
    }
    return offset;
}
-(UInt32)noteForString:(NSString*)noteString
{
    
    UInt32  offset=0;
    
    int index;
    
    NSArray  *currentscaleNotes=[[self.currentScale valueForKey:@"ScaleNotes"]componentsSeparatedByString:@","];
    
    if ([noteString isEqualToString:@"Do"]) {
       // offset=0;
        index=0;
    }else if ([noteString isEqualToString:@"Ra"])
    {
        index=1;
       // offset=2;
    }else if ([noteString isEqualToString:@"Mi"])
    {
        index=2;
        //offset=4;

    }else if ([noteString isEqualToString:@"Fa"])
    {       // offset=5;

        index=3;

    }else if ([noteString isEqualToString:@"So"])
    {
        index=4;

               // offset=7;

    }else if ([noteString isEqualToString:@"La"])
    {
              // offset=9;
        index=5;

    }else if ([noteString isEqualToString:@"Ti"])
    {
        index=6;

       // offset=11;

    }else if ([noteString isEqualToString:@"Do2"])
    {
        index=7;

       // offset=12;
        
    }
    UInt32 result=0;
    
   /* UInt32 root=[self rootForKey:self.currentKey];
          result= ( self.currentOctave*12)+(root+offset);*/
    
    result = [currentscaleNotes[index]intValue];

    
    return result;
}
-(void)playNote:(NSString*)note
{
    NSLog(@"play sampler note");
    
    [self stopTimer];
    UInt32 midiStatus;
    UInt32 anote;
    UInt32 velocity;
    midiStatus = 0x80;      // note on message
    anote= [self noteForString:note];

    MusicDeviceMIDIEvent (_samplerUnit,
                          midiStatus,
                          0,
                          100,
                          0);
    UInt8 kMIDIMessage_ControlModeChange = 0xB0;
    UInt8 kMIDIMessage_ControlTypeAllSoundOff = 0x58;
    //UInt8 noteOff[] = { 0x80, 0, 0   };
UInt8 noteOff[] = { 0x58, 0, 0   };
    MusicDeviceMIDIEvent(_samplerUnit, kMIDIMessage_ControlModeChange, kMIDIMessage_ControlTypeAllSoundOff, 0, 0);
    [self sendBytes:noteOff size:sizeof(noteOff)];

    midiStatus = 0x90;      // note on message
    //velocity = self.velocity;
    //velocity = 44;
    
    //CHANGED - BRIAN, WAS 44
    
    velocity = 90;
    
    const int kMIDINoteOff = 0x8 << 4;
    if (currentNote) {
        MusicDeviceMIDIEvent(_samplerUnit, kMIDINoteOff, currentNote, 127, 0);

    }
    MusicDeviceMIDIEvent (_samplerUnit,
                                     midiStatus,
                                     anote,
                                     velocity,
                          0);
    
    currentNote=anote;
    
     UInt8 noteOn[]  = { 0x90, anote, 127 };
    
    [self sendBytes:noteOn size:sizeof(noteOn)];
    
    
    [self startTimer];
}
-(void)setTheVelocity:(UInt32)velocity
{
    self.velocity=velocity;
}
-(void)cleanup
{
    [self stopTimer];
    AUGraphStop(_processingGraph);
    AUGraphUninitialize(_processingGraph);
    DisposeAUGraph(_processingGraph);
    
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
    for (ItemCount index = 0; index < MIDIGetNumberOfDestinations(); ++index)
    {
        MIDIEndpointRef outputEndpoint = MIDIGetDestination(index);
        if (outputEndpoint)
        {
            // Send it
            MIDISend(outputPort, outputEndpoint, packetList);
        }
    }
}

@end
