//
//  TapAudioEngine.h
//  BreathMusic
//
//  Created by barry on 08/09/2014.
//  Copyright (c) 2014 rocudo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TapAudioEngine : NSObject
-(void)tempoUp;
-(void)tempoDown;
-(void)cleanup;
-(void)songSelected:(NSString*)songname;
-(int)getTheTempo;
@end
