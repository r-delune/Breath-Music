//
//  NoteEvent.h
//  MIDIFileSequence
//
//  Created by barry on 13/08/2014.
//  Copyright (c) 2014 Rockhopper Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface NoteEvent : NSObject
@property(readwrite)MIDINoteMessage  *noteMessage;
@property(readwrite)MusicTimeStamp   timeStamp;
@property (readwrite)int trackNumber;
@end
