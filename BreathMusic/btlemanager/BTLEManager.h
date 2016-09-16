//
//  BTLEManager.h
//  BTLEManager
//
//  Created by barry on 06/10/2015.
//  Copyright © 2015 rocudo. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for BTLEManager.
FOUNDATION_EXPORT double BTLEManagerVersionNumber;

//! Project version string for BTLEManager.
FOUNDATION_EXPORT const unsigned char BTLEManagerVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <BTLEManager/PublicHeader.h>
//
//  BTLEManager.h
//  GrooveTubeMelodySmart
//
//  Created by barry on 19/08/2015.
//  Copyright (c) 2015 rocudo. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MAX_INHALE 2000
#define MAX_EXHALE 2000

typedef enum BT_LE_State:NSUInteger

{
    BTLEState_Beginnging,
    BTLEState_Began,
    BTLEState_Stopping,
    BTLEState_Stopped
    
}BT_LE_State;
@class BTLEManager;

@protocol BTLEManagerDelegate <NSObject>

/*!
 *  Implement this delegate method to
 be notified when a breath has begun
 *
 *  @param manager Your instance of BTLEManager
 */
-(void)btleManagerBreathBeganWithExhale:(BTLEManager*)manager;
-(void)btleManagerBreathBeganWithInhale:(BTLEManager*)manager;
-(void)btleManagerBreathBegan:(BTLEManager*)manager;


/*!
 *  Implement this delegate method to
 be notified when a breath has Stopped
 *
 *  @param manager Your instance of BTLEManager
 */


-(void)btleManagerBreathStopped:(BTLEManager*)manager;
/*!
 
 *  Implement this delegate method to
 be notified when a btlemanager has connected to your device
 
 *
 *  @param manager Your instance of BTLEManager
 */


-(void)btleManagerConnected:(BTLEManager*)manager;
/**
 
 *  Implement this delegate method to
 be notified when a btlemanager has disconnected from your device
 
 *
 *  @param manager Your instance of BTLEManager
 */
-(void)btleManagerDisconnected:(BTLEManager*)manager;
/**
 *  Breath inhale was detected
 *
 *  @param manager      Your instance of BTLEManager
 *  @param percentOfmax A value from 0 -1
 */

-(void)btleManager:(BTLEManager*)manager inhaleWithValue:(float)percentOfmax;
/**
 *  Breath inhale was detected
 *
 *  @param manager      Your instance of BTLEManager
 *  @param percentOfmax A value from 0 -1
 */
-(void)btleManager:(BTLEManager*)manager exhaleWithValue:(float)percentOfmax;

@end

@interface BTLEManager : NSObject

/**
 *  Setup
 *
 *  @param deviceName The name of the device youre connecting to
 *  @param interval   How frequently you would like to poll the device for data
 */

-(void)startWithDeviceName:(NSString*)deviceName andPollInterval:(float)interval;
-(void)disconnect;
/**
 *  Distance of dead zone from calibrated center
 *
 *  @param range Reccommened minimum = 60
 */
-(void)setTreshold:(int)threshold;
/**
 *
 *
 */
-(void)setRangeReduction:(float)range;

@property(nonatomic,unsafe_unretained)id<BTLEManagerDelegate>delegate;
@property BT_LE_State  btleState;
@property BOOL isConnected;
+ (instancetype)sharedInstance;
@property float percentOfMax;

@end



