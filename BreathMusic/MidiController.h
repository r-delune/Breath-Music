//
//  MidiController.h
//  BreathMusic
//
//  Created by barry on 29/09/2014.
//  Copyright (c) 2014 rocudo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class  MidiController;

@protocol MidiControllerProtocol <NSObject>

-(void)midiNoteBegan:(MidiController*)midi;
-(void)midiNoteStopped:(MidiController*)midi;
-(void)midiNoteContinuing:(MidiController*)midi;
-(void)sendLogToOutput:(NSString*)log;

@end
@interface MidiController : NSObject
+ (instancetype)sharedInstance;
@property(nonatomic,unsafe_unretained)id<MidiControllerProtocol>delegate;
-(void)continueMidiNote:(int)pvelocity;
-(void)stopMidiNote;
-(void)midiNoteBegan:(int)direction vel:(int)pvelocity;
-(void)setup;
-(void)sendValue:(int)note onoff:(int)onoff;
@property float speed;
@property float velocity;
@property int currentdirection;

@end
