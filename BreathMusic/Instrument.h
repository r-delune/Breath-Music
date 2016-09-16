//
//  Instrument.h
//  SAM
//
//  Created by barry on 21/08/2014.
//  Copyright (c) 2014 rocudo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface Instrument : NSObject
@property (readwrite)AUNode  instrumentNode;
@property(readwrite)AudioUnit instrumentUnit;
@end
