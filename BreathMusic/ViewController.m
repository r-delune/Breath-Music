//
//  ViewController.m
//  BreathMusic
//
//  Created by barry on 05/09/2014.
//  Copyright (c) 2014 rocudo. All rights reserved.
//

#import "ViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
@interface ViewController ()
@property(nonatomic,weak)IBOutlet UIImageView  *btOnOffImageView;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    AVAudioSession *mySession = [AVAudioSession sharedInstance];
    
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    // tz change to play and record
    // Assign the Playback category to the audio session.
    NSError *audioSessionError = nil;
          [mySession setCategory: AVAudioSessionCategoryPlayback
                         error: &audioSessionError];
        
    
    
}
-(void)viewWillAppear:(BOOL)animated
{
    
    [[BTLEManager sharedInstance]setDelegate:self];
    if ([BTLEManager sharedInstance].isConnected==NO) {
        [[BTLEManager sharedInstance]startWithDeviceName:@"GroovTube" andPollInterval:0.1];
    }
    
    [self.btleManager setTreshold:60];
  }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark --
#pragma mark MIDI

-(void)midiNoteBegan:(MidiController*)midi
{
    
    [super midiNoteBegan:midi];
    
  
}
-(void)midiNoteStopped:(MidiController*)midi
{
    [super midiNoteStopped:midi];
}
-(void)midiNoteContinuing:(MidiController*)midi
{
    
}
-(void)btleManagerBreathBegan:(BTLEManager*)manager{

    NSLog(@"%s",__func__);
}


/*!
 *  Implement this delegate method to
 be notified when a breath has Stopped
 *
 *  @param manager Your instance of BTLEManager
 */


-(void)btleManagerBreathStopped:(BTLEManager*)manager
{
    NSLog(@"%s",__func__);

}

/*!
 
 *  Implement this delegate method to
 be notified when a btlemanager has connected to your device
 
 *
 *  @param manager Your instance of BTLEManager
 */


-(void)btleManagerConnected:(BTLEManager*)manager{

    [_btOnOffImageView setImage:[UIImage imageNamed:@"Bluetooth-CONNECTED"]];

}
/**
 
 *  Implement this delegate method to
 be notified when a btlemanager has disconnected from your device
 
 *
 *  @param manager Your instance of BTLEManager
 */
-(void)btleManagerDisconnected:(BTLEManager*)manager{

    [_btOnOffImageView setImage:[UIImage imageNamed:@"Bluetooth-DISCONNECTED"]];

}
/**
 *  Breath inhale was detected
 *
 *  @param manager      Your instance of BTLEManager
 *  @param percentOfmax A value from 0 -1
 */

-(void)btleManager:(BTLEManager*)manager inhaleWithValue:(float)percentOfmax{}
/**
 *  Breath inhale was detected
 *
 *  @param manager      Your instance of BTLEManager
 *  @param percentOfmax A value from 0 -1
 */
-(void)btleManager:(BTLEManager*)manager exhaleWithValue:(float)percentOfmax{}

@end
