//
//  TapViewController.m
//  BreathMusic
//
//  Created by barry on 08/09/2014.
//  Copyright (c) 2014 rocudo. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "UIGlossyButton.h"

#import "UIView+LayerEffects.h"
#import "TapViewController.h"
#import "TapAudioEngine.h"
#import "SongSelectTableViewController.h"
#import "PulsingHaloLayer.h"
#import "APLElevatorControl.h"
#import "GCDQueue.h"
#import  "BTLEManager.h"
@interface TapViewController ()<SongSelectProtocol,BTLEManagerDelegate>
-(IBAction)goToMainMenu:(id)sender;

@property(nonatomic,weak)IBOutlet  UIGlossyButton  *songSelectButton;
@property(nonatomic,weak)IBOutlet  UILabel  *bpmLabel;
@property (weak, nonatomic) IBOutlet APLElevatorControl *elevatorControl;
@property (nonatomic, weak) PulsingHaloLayer *halo;
@property(nonatomic,strong)SongSelectTableViewController *tableViewController;
-(IBAction)songButtonTapped:(id)sender;
@property(nonatomic,strong)NSDate *lastDate;
@property(nonatomic,strong)UIPopoverController  *popover;

@property(nonatomic,strong)TapAudioEngine  *audioengine;
@property(nonatomic,strong)BTLEManager  *btleManager;
@property NSInteger lastBPM;

@end

@implementation TapViewController

- (IBAction)floorChanged:(APLElevatorControl *)elevatorControl
{
    //self.floorPlanView.floor = elevatorControl.floor;
   // self.titleView.floor = elevatorControl.floor;
    
    if (self.elevatorControl.floor>self.lastBPM) {
        [self.audioengine tempoUp];
    }else
    {
        [self.audioengine tempoDown];

    }
    
    self.lastBPM=elevatorControl.floor;
    
   // self.halo.pulseInterval=self.lastBPM/60.0;
   // float duration=self.lastBPM/60.0;
  //  self.halo.pulseInterval=0;
// self.halo.animationDuration=duration;
    [self addCircle];
    
    self.bpmLabel.text=[NSString stringWithFormat:@"BPM : %li",(long)elevatorControl.floor];
    NSLog(@"%li",(long)elevatorControl.floor);
}
-(void)addCircle

{
    if (self.halo) {
        [self.halo removeFromSuperlayer];
        self.halo=nil;
    }
    PulsingHaloLayer *layer = [PulsingHaloLayer layer];
    self.halo = layer;
    self.halo.position = CGPointMake(355, 480);
    [self.view.layer insertSublayer:self.halo above:self.elevatorControl.layer];
    self.halo.radius=300;
    self.halo.pulseInterval=0;
    float duration=60.0/self.lastBPM;

    self.halo.animationDuration= self.halo.animationDuration=duration;
}
/*
 
 UIView *view = [[UIView alloc] initWithFrame:CGRectMake(200, 200, 100, 100)];
 view.backgroundColor = [UIColor blueColor];
 view.layer.cornerRadius = 50;
 
 [self.view addSubview:view];
 
 CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
 scaleAnimation.duration = 0.2;
 scaleAnimation.repeatCount = HUGE_VAL;
 scaleAnimation.autoreverses = YES;
 scaleAnimation.fromValue = [NSNumber numberWithFloat:1.2];
 scaleAnimation.toValue = [NSNumber numberWithFloat:0.8];
 
 [view.layer addAnimation:scaleAnimation forKey:@"scale"];
 */
-(void)songSelected:(NSString *)song
{
    [[GCDQueue mainQueue]queueBlock:^{
      //  [_popover dismissPopoverAnimated:YES];
        [self.audioengine cleanup];
        [self.audioengine songSelected:song];
        [self.songSelectButton setTitle:song forState:UIControlStateNormal];
        self.lastBPM=[self.audioengine getTheTempo];
        self.elevatorControl.floor=self.lastBPM;
        [self addCircle];
        [self sendLogToOutput:song];
        self.bpmLabel.text=[NSString stringWithFormat:@"BPM %i",[self.audioengine getTheTempo]];

        [self.popover dismissPopoverAnimated:YES];
    }];
    

}
-(IBAction)songButtonTapped:(id)sender
{
    UIButton *button = (UIButton*)sender;
    
    SongSelectTableViewController *tableViewController = [[SongSelectTableViewController alloc] initWithStyle:UITableViewStylePlain];
    
    tableViewController.delegate=self;
    _popover= [[UIPopoverController alloc] initWithContentViewController:tableViewController];
    [_popover presentPopoverFromRect:CGRectMake(button.frame.size.width / 2, button.frame.size.height / 1, 1, 1) inView:button permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];

}

-(IBAction)goToMainMenu:(id)sender
{
    [self.audioengine cleanup];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.lastDate=[NSDate date];
   // [self.tapUpButton setAccessibilityTraits:UIAccessibilityTraitAdjustable];
  // [ self.tapDownButton setAccessibilityTraits:UIAccessibilityTraitAdjustable];
    self.audioengine=[[TapAudioEngine alloc]init];
   // self.bpmLabel.alpha=0.0;
   // [self songSelected:@"themorningdew"];
   // [self.songSelectButton setTitle:@"themorningdew" forState:UIControlStateNormal];
    self.elevatorControl.alpha=0.0;
    // Do any additional setup after loading the view.
    
    
    [self.songSelectButton useWhiteLabel: YES];
    self.songSelectButton.buttonTintColor = [UIColor colorWithRed:54.0/255.0 green:88.0/255.0 blue:151.0/255.0 alpha:1];
    [self.songSelectButton setShadow:[UIColor lightGrayColor] opacity:0.8 offset:CGSizeMake(0, 1) blurRadius: 4];
   // [self.songSelectButton setGradientType:kUIGlossyButtonGradientTypeLinearSmoothBrightToNormal];
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
{
    [super textView:textView shouldChangeTextInRange:range replacementText:text];

    if ( [text isEqualToString:@" "] ) {
        //Do whatever you want
        
        NSLog(@"Return!!");
       // [self.elevatorControl decrementFloor];
        //[self floorChanged:self.elevatorControl];
        [self.audioengine tempoDown];
        self.bpmLabel.text=[NSString stringWithFormat:@"BPM %i",[self.audioengine getTheTempo]];

    }
    
    if([text isEqualToString:@"\n"])
    {
        NSLog(@"Space");
       // [self.elevatorControl incrementFloor];
       // [self floorChanged:self.elevatorControl];
        [self.audioengine tempoUp];
        self.bpmLabel.text=[NSString stringWithFormat:@"BPM %i",[self.audioengine getTheTempo]];


    }
    return YES;
}

#pragma mark --
#pragma mark MIDI
-(void)btleManagerBreathBegan:(BTLEManager*)manager{}
-(void)btleManagerBreathBeganWithInhale:(BTLEManager*)manager{

    
    MidiController  *midi=[MidiController new];
    midi.currentdirection=midiexhale;
    [super midiNoteBegan:midi];
    [self.audioengine tempoDown];
    self.bpmLabel.text=[NSString stringWithFormat:@"BPM %i",[self.audioengine getTheTempo]];



}
-(void)btleManagerBreathBeganWithExhale:(BTLEManager*)manager{
    NSLog(@"%s",__func__);

    MidiController  *midi=[MidiController new];
    midi.currentdirection=midiinhale;
    [super midiNoteBegan:midi];
    [self.audioengine tempoUp];
    self.bpmLabel.text=[NSString stringWithFormat:@"BPM %i",[self.audioengine getTheTempo]];

}

-(void)btleManagerBreathStopped:(BTLEManager*)manager{
    [self midiNoteStopped:nil];

}

-(void)btleManagerConnected:(BTLEManager*)manager{}
-(void)btleManagerDisconnected:(BTLEManager*)manager{}

-(void)btleManager:(BTLEManager*)manager inhaleWithValue:(float)percentOfmax{}
-(void)btleManager:(BTLEManager*)manager exhaleWithValue:(float)percentOfmax{}
-(void)midiNoteBegan:(MidiController*)midi
{
    [super midiNoteBegan:midi];
    
    [super sendLogToOutput:[NSString stringWithFormat:@"note == %i",midi.currentdirection]];
    if (midi.currentdirection==midiexhale) {
        
        [self.audioengine tempoDown];
        self.bpmLabel.text=[NSString stringWithFormat:@"BPM %i",[self.audioengine getTheTempo]];
    }else if (midi.currentdirection==midiinhale)
    {
        [self.audioengine tempoUp];
        self.bpmLabel.text=[NSString stringWithFormat:@"BPM %i",[self.audioengine getTheTempo]];
    }
    
    
    

}
-(void)midiNoteStopped:(MidiController*)midi
{
    [super midiNoteStopped:midi];
}
-(void)midiNoteContinuing:(MidiController*)midi
{
    
}
-(void)sendLogToOutput:(NSString*)log
{
    [super sendLogToOutput:log];

}

@end
