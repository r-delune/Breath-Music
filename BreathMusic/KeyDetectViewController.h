//
//  KeyDetectViewController.h
//  BreathMusic
//
//  Created by barry on 29/09/2014.
//  Copyright (c) 2014 rocudo. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import "MidiController.h"
#define    midiinhale 61
#define    midiexhale 73
#import  "BTLEManager.h"
@interface KeyDetectViewController : UIViewController<UITextViewDelegate,MidiControllerProtocol,BTLEManagerDelegate>
-(void)setupKeyDetect;
-(MidiController*)midiController;
@property(nonatomic,strong)UITextView  *debugTextView;
@property(nonatomic,strong)UIButton  *leftSwitchButton;
@property(nonatomic,strong)UIButton  *rightSwitchButton;
@property(nonatomic,strong)UIImageView  *barBGImageView;
@property(nonatomic,strong)UIImageView  *barImageView;
@property(nonatomic,strong)BTLEManager  *btleManager;
@end
