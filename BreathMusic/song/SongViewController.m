//
//  SongViewController.m
//  BreathMusic
//
//  Created by barry on 08/09/2014.
//  Copyright (c) 2014 rocudo. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "UIGlossyButton.h"

#import "UIView+LayerEffects.h"
#import "SongViewController.h"
#import "SongModeTableViewController.h"
#import "SongAudioEngine.h"
#import "GCDQueue.h"
#import "InstrumentTableViewController.h"
#import  "BTLEManager.h"
@interface SongViewController ()<SongModeTableViewProtocol,InstrumentTableViewProtocol,SongEngineProtocol,BTLEManagerDelegate>
-(IBAction)mainMenu:(id)sender;
-(IBAction)songButtonHit:(id)sender;
@property(nonatomic,weak)IBOutlet UIGlossyButton  *songSelectButton;
@property(nonatomic,strong)UIPopoverController  *popover;
@property(nonatomic,strong)NSMutableArray  *songButtons;
@property(nonatomic,strong)NSMutableArray  *songParts;
@property(nonatomic,strong)SongAudioEngine  *audioEngine;

@property (nonatomic,strong) InstrumentTableViewController *instrumenttableViewController;

@property(nonatomic,weak)IBOutlet  UIGlossyButton  *button1;
@property(nonatomic,weak)IBOutlet  UIGlossyButton  *button2;
@property(nonatomic,weak)IBOutlet  UIGlossyButton  *button3;
@property(nonatomic,weak)IBOutlet  UIGlossyButton  *button4;
@property(nonatomic,weak)IBOutlet  UIGlossyButton  *button5;
@property(nonatomic,weak)IBOutlet  UIGlossyButton  *button6;
@property(nonatomic,weak)IBOutlet  UIGlossyButton  *button7;
@property(nonatomic,weak)IBOutlet  UIGlossyButton  *button8;
@property(nonatomic,weak)IBOutlet UIGlossyButton  *instrumentButton;
@property NSInteger lasttime;

@property(nonatomic,strong)SongModeTableViewController *tableViewController;
@property(nonatomic,strong)NSArray  *buttonArray;

@property(nonatomic,strong)NSDictionary  *lastsong;
@property int numparts;

@property BOOL useInhale;
@property int buttonIndex;
@property(nonatomic,strong)BTLEManager  *btleManager;
-(IBAction)button1hit:(id)sender;
-(IBAction)button2hit:(id)sender;
-(IBAction)button3hit:(id)sender;
-(IBAction)button4hit:(id)sender;
-(IBAction)button5hit:(id)sender;
-(IBAction)button6hit:(id)sender;
-(IBAction)button7hit:(id)sender;
-(IBAction)button8hit:(id)sender;

-(IBAction)instrumentButtonHit:(id)sender;
@end

@implementation SongViewController

bool _allowNextNote = true;
int _currentIndex;

-(void)logOutput:(NSString *)log
{
    [super sendLogToOutput:log];
}
-(void)stictchedSongPassedIndex:(int)index
{
    _currentIndex = index;
    
    BOOL  continuous=[[[NSUserDefaults standardUserDefaults]valueForKey:@"continuousBreath"]boolValue];

   // if (continuous == 0 && _allowNextNote == false){
    
        /// [self.audioEngine stopBreath];
        
    //    NSLog(@"STOPPED AT INDEX %d", index);
        
  //  }else if (_allowNextNote == true){
    
    
    NSLog(@"stictchedSongPassedIndex index %d", index);
        

    //if (_allowNextNote == true){
        if (index>=[self.buttonArray count]) {
            return;
        }
    
        [[GCDQueue mainQueue]queueBlock:^{
            [self highlightButton:self.buttonArray[index]];
            [super sendLogToOutput:[NSString stringWithFormat:@"highlight %i",index]];
        }];
   // }
  //  }else{
       /// NSLog(@"CONTINOUS OFF - DISALLOWING NEXT NOTE");
        ///_allowNextNote = false;
       
   // }

}
-(IBAction)instrumentButtonHit:(id)sender
{
    NSLog(@"%s",__func__);
    UIButton *button = (UIButton*)sender;
    
    self.instrumenttableViewController = [[InstrumentTableViewController alloc] initWithStyle:UITableViewStylePlain];
    
    self.instrumenttableViewController.delegate=self;
    _popover= [[UIPopoverController alloc] initWithContentViewController:self.instrumenttableViewController];
    [_popover presentPopoverFromRect:CGRectMake(button.frame.size.width / 2, button.frame.size.height / 1, 1, 1) inView:button permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}
-(void)instrumentSelected:(NSDictionary *)instrument
{
    NSLog(@"%s",__func__);
    NSString *name=[instrument valueForKey:@"InstrumentName"];
    //self.instrumentButton.titleLabel.text=[NSString stringWithFormat:@"Instrument : %@",instrument];
    [self.instrumentButton setTitle:[NSString stringWithFormat:@"Instrument : %@",name] forState:UIControlStateNormal];
    [_popover dismissPopoverAnimated:YES];
    
    int presetNumber=[[instrument valueForKey:@"InstrumentNumber"]intValue];
    [self.audioEngine setInstrument:presetNumber ];
    
    
}
-(IBAction)button1hit:(id)sender
{
    
    [self.audioEngine playIndex:0];
}
-(IBAction)button2hit:(id)sender{

    [self.audioEngine playIndex:1];

}
    
    
    
-(IBAction)button3hit:(id)sender{
    [self.audioEngine playIndex:2];

}
-(IBAction)button4hit:(id)sender{
    [self.audioEngine playIndex:3];

}
-(IBAction)button5hit:(id)sender{
    [self.audioEngine playIndex:4];

}
-(IBAction)button6hit:(id)sender{
    [self.audioEngine playIndex:5];

}
-(IBAction)button7hit:(id)sender{
    [self.audioEngine playIndex:6];

}
-(IBAction)button8hit:(id)sender{
    
    [self.audioEngine playIndex:7];
    
}
-(void)reset
{
    NSLog(@"%s",__func__);
    [self songSelected:self.lastsong];
}
-(void)songSelected:(NSDictionary *)dict
{
    
    NSLog(@"%s",__func__);
    self.buttonIndex=-1;
    self.lastsong=dict;
    [self.popover dismissPopoverAnimated:YES];

    [self highlightButton:self.button1];
    
    NSString  *styleName=[dict valueForKey:@"SongDisplayName"];
    [self sendLogToOutput:styleName];
    
    [[GCDQueue mainQueue]queueBlock:^{
    //SongDisplayName
    //SongFileName
    //SongPartCount
        
        self.button1.alpha=0;
        self.button2.alpha=0;
        self.button3.alpha=0;
        self.button4.alpha=0;
        self.button5.alpha=0;
        self.button6.alpha=0;
        self.button7.alpha=0;
        self.button8.alpha=0;
        
        self.numparts=[[dict valueForKey:@"SongPartCount"]intValue];
        
        for (int i=0; i<self.numparts; i++) {
            
            [self.buttonArray[i] setAlpha:1.0];
        }

    
    [self.songSelectButton setTitle:styleName forState:UIControlStateNormal];

    
        //self.instrumentButton.titleLabel.text = @"Instrument : Flute";
        [self.instrumentButton setTitle: @"Instrument : Flute" forState:UIControlStateNormal];

       // [self pushButtonForIndex:0];
       // [self.audioEngine stitchMidiData];
    }];

    if (self.audioEngine) {
        [self.audioEngine cleanup];
    }
    
    self.audioEngine=nil;
    self.audioEngine = [[SongAudioEngine alloc] init];
    
    
    
    [self.audioEngine setMidiStyle:dict];
    
    
    [self.audioEngine playMIDIFile];
    //if ([self.instrumentButton.titleLabel.text isEqualToString:@"Instrument : Flute"]) {
    //    [self.audioEngine setInstrument:73 ];
        
    //}
}
-(IBAction)songButtonHit:(id)sender
{
    NSLog(@"%s",__func__);
    UIButton *button = (UIButton*)sender;
    
    SongModeTableViewController *tableViewController = [[SongModeTableViewController alloc] initWithStyle:UITableViewStylePlain];
    
    tableViewController.delegate=self;
    _popover= [[UIPopoverController alloc] initWithContentViewController:tableViewController];
    [_popover presentPopoverFromRect:CGRectMake(button.frame.size.width / 2, button.frame.size.height / 1, 1, 1) inView:button permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];

}
-(IBAction)toggleButtonHit:(id)sender

{
    
    if (self.useInhale) {
        self.useInhale=NO;
        [self.toggleDirectionButton setImage:[UIImage imageNamed:@"SWITCH-Breath-EXHALE"] forState:UIControlStateNormal];
        
    }else
    {
        self.useInhale=YES;
        [self.toggleDirectionButton setImage:[UIImage imageNamed:@"SWITCH-Breath-INHALE"] forState:UIControlStateNormal];
    }

}
-(IBAction)mainMenu:(id)sender
{
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
-(void)viewWillDisappear:(BOOL)animated
{
    [[GCDQueue mainQueue]queueBlock:^{
    
        [self.audioEngine cleanup];
    }];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.buttonIndex=0;
   // [self midiNoteBegan:nil];
    self.buttonArray=@[self.button1,self.button2,self.button3,self.button4,self.button5,self.button6,self.button7,self.button8];
    // Do any additional setup after loading the view.
   //36:58:97)
    [self.button1 useWhiteLabel: YES];
    self.button1.buttonTintColor = [UIColor colorWithRed:54.0/255.0 green:88.0/255.0 blue:151.0/255.0 alpha:1];
    [self.button1 setShadow:[UIColor lightGrayColor] opacity:0.8 offset:CGSizeMake(0, 1) blurRadius: 4];
  //  [self.button1 setGradientType:kUIGlossyButtonGradientTypeLinearSmoothBrightToNormal];
    
    
    [self.button2 useWhiteLabel: YES];
    self.button2.buttonTintColor = [UIColor colorWithRed:54.0/255.0 green:88.0/255.0 blue:151.0/255.0 alpha:1];
    [self.button2 setShadow:[UIColor lightGrayColor] opacity:0.8 offset:CGSizeMake(0, 1) blurRadius: 4];
  //  [self.button2 setGradientType:kUIGlossyButtonGradientTypeLinearSmoothBrightToNormal];
    
    [self.button3 useWhiteLabel: YES];
    self.button3.buttonTintColor = [UIColor colorWithRed:54.0/255.0 green:88.0/255.0 blue:151.0/255.0 alpha:1];
    [self.button3 setShadow:[UIColor lightGrayColor] opacity:0.8 offset:CGSizeMake(0, 1) blurRadius: 4];
  //  [self.button3 setGradientType:kUIGlossyButtonGradientTypeLinearSmoothBrightToNormal];
    
    [self.button4 useWhiteLabel: YES];
    self.button4.buttonTintColor = [UIColor colorWithRed:54.0/255.0 green:88.0/255.0 blue:151.0/255.0 alpha:1];
    [self.button4 setShadow:[UIColor lightGrayColor] opacity:0.8 offset:CGSizeMake(0, 1) blurRadius: 4];
  //  [self.button4 setGradientType:kUIGlossyButtonGradientTypeLinearSmoothBrightToNormal];
    
    [self.button5 useWhiteLabel: YES];
    self.button5.buttonTintColor = [UIColor colorWithRed:54.0/255.0 green:88.0/255.0 blue:151.0/255.0 alpha:1];
    [self.button5 setShadow:[UIColor lightGrayColor] opacity:0.8 offset:CGSizeMake(0, 1) blurRadius: 4];
  //  [self.button5 setGradientType:kUIGlossyButtonGradientTypeLinearSmoothBrightToNormal];
    
    [self.button6 useWhiteLabel: YES];
    self.button6.buttonTintColor = [UIColor colorWithRed:54.0/255.0 green:88.0/255.0 blue:151.0/255.0 alpha:1];
    [self.button6 setShadow:[UIColor lightGrayColor] opacity:0.8 offset:CGSizeMake(0, 1) blurRadius: 4];
  //  [self.button6 setGradientType:kUIGlossyButtonGradientTypeLinearSmoothBrightToNormal];
    
    [self.button7 useWhiteLabel: YES];
    self.button7.buttonTintColor = [UIColor colorWithRed:54.0/255.0 green:88.0/255.0 blue:151.0/255.0 alpha:1];
    [self.button7 setShadow:[UIColor lightGrayColor] opacity:0.8 offset:CGSizeMake(0, 1) blurRadius: 4];
   // [self.button7 setGradientType:kUIGlossyButtonGradientTypeLinearSmoothBrightToNormal];
    
    [self.button8 useWhiteLabel: YES];
    self.button8.buttonTintColor = [UIColor colorWithRed:54.0/255.0 green:88.0/255.0 blue:151.0/255.0 alpha:1];
    [self.button8 setShadow:[UIColor lightGrayColor] opacity:0.8 offset:CGSizeMake(0, 1) blurRadius: 4];
  //  [self.button8 setGradientType:kUIGlossyButtonGradientTypeLinearSmoothBrightToNormal];
    
    [self.songSelectButton useWhiteLabel: YES];
    self.songSelectButton.buttonTintColor = [UIColor colorWithRed:54.0/255.0 green:88.0/255.0 blue:151.0/255.0 alpha:1];
    [self.songSelectButton setShadow:[UIColor lightGrayColor] opacity:0.8 offset:CGSizeMake(0, 1) blurRadius: 4];
   // [self.songSelectButton setGradientType:kUIGlossyButtonGradientTypeLinearSmoothBrightToNormal];
    
    [self.instrumentButton useWhiteLabel: YES];
    self.instrumentButton.buttonTintColor = [UIColor colorWithRed:54.0/255.0 green:88.0/255.0 blue:151.0/255.0 alpha:1];
    [self.instrumentButton setShadow:[UIColor lightGrayColor] opacity:0.8 offset:CGSizeMake(0, 1) blurRadius: 4];
   // [self.instrumentButton setGradientType:kUIGlossyButtonGradientTypeLinearSmoothBrightToNormal];
    
   // self.testbutton.alpha=0.0;
   // self.stoptestbutton.alpha=0.0;
    
}
-(void)viewWillAppear:(BOOL)animated
{
    
    [[BTLEManager sharedInstance]setDelegate:self];
    if ([BTLEManager sharedInstance].isConnected==NO) {
        [[BTLEManager sharedInstance]startWithDeviceName:@"GroovTube" andPollInterval:0.1];
    }
    
    [self.btleManager setTreshold:60];
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"BreathMusicSongList" ofType:@"plist"];
    
    NSArray *songs = [NSArray arrayWithContentsOfFile:plistPath];
    [self songSelected:songs[0]];
    plistPath = [[NSBundle mainBundle] pathForResource:@"MIDIInstrumentList" ofType:@"plist"];
    NSArray *instruments = [NSArray arrayWithContentsOfFile:plistPath];

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
        self.buttonIndex--;
        if (self.buttonIndex<0) {
            self.buttonIndex=self.numparts-1;
        }
        NSLog(@"Return!!");
    }
    
    if([text isEqualToString:@"\n"])
    {
        NSLog(@"Space");
        self.buttonIndex++;
        if (self.buttonIndex>=self.numparts) {
            self.buttonIndex=0;
        }

    }
    
    [self pushButtonForIndex:self.buttonIndex];
    return YES;
}

-(void)pushButtonForIndex:(int)index
{
NSLog(@"%s",__func__);
    switch (index) {
        case 0:
            [self button1hit:nil];
            [self highlightButton:self.button1];
            break;
        case 1:
            [self button2hit:nil];
            [self highlightButton:self.button2];


            break;
        case 2:
            [self button3hit:nil];
            [self highlightButton:self.button3];

            break;
        case 3:
            [self button4hit:nil];
            [self highlightButton:self.button4];

            break;
        case 4:
            [self button5hit:nil];
            [self highlightButton:self.button5];

            break;
        case 5:
            [self button6hit:nil];
            [self highlightButton:self.button6];
            
            break;
        case 6:
            [self button7hit:nil];
            [self highlightButton:self.button7];
            
            break;
        case 7:
            [self button8hit:nil];
            [self highlightButton:self.button8];
            
            break;
            
        default:
            break;
    }
}
-(void)highlightButton:(UIButton*)button
{
    NSLog(@"%s",__func__);
    
    [[GCDQueue mainQueue]queueBlock:^{
        for (UIButton  *abutton in self.buttonArray) {
            
            if (abutton == button) {
                abutton.titleLabel.textColor=[UIColor orangeColor];
            }else
            {
                abutton.titleLabel.textColor=[UIColor whiteColor];
                
            }
        }
    }];
    
}
#pragma mark --
#pragma mark MIDI
-(void)btleManagerBreathBegan:(BTLEManager*)manager{}
-(void)btleManagerBreathBeganWithInhale:(BTLEManager*)manager{

    NSLog(@"%s",__func__);
    if (!self.useInhale) {
      ///  NSLog(@"NOTE DISALLOWED");
        return;
    }


    MidiController  *midi=[MidiController new];
    midi.currentdirection=midiexhale;
    [super midiNoteBegan:midi];
    [self.audioEngine beginBreath];
    
    self.audioEngine.delegate=self;

}
-(void)btleManagerBreathBeganWithExhale:(BTLEManager*)manager{

    NSLog(@"%s",__func__);

    if (self.useInhale || _allowNextNote == false) {
       //  NSLog(@"NOTE DISALLOWED");
        return;
    }
    


    MidiController  *midi=[MidiController new];
    midi.currentdirection=midiinhale;
       [super midiNoteBegan:midi];
    [self.audioEngine beginBreath];
    
    self.audioEngine.delegate=self;

}

-(void)btleManagerBreathStopped:(BTLEManager*)manager{
    [self.audioEngine stopBreath];
    //_allowNextNote = true;
    /////NSLog(@"STOPPED  - ALLOWING NEXT NOTE");

}

-(void)stopEngine{
 [self.audioEngine stopBreath];
}

-(void)btleManagerConnected:(BTLEManager*)manager{}
-(void)btleManagerDisconnected:(BTLEManager*)manager{}

-(void)btleManager:(BTLEManager*)manager inhaleWithValue:(float)percentOfmax{
    
    BOOL  continuous=[[[NSUserDefaults standardUserDefaults]valueForKey:@"continuousBreath"]boolValue];
    
     MidiController  *midi=[MidiController new];
    /// if (_allowNextNote == true){
        
         midi.velocity=127.0*percentOfmax;
         midi.currentdirection=midiexhale;
         [self midiNoteContinuing:midi];
      //   NSLog(@"ALLOWED");
   /// }else{
     //   NSLog(@"NEXT IN NOTE DISALLOWED");
        //midi.velocity=0;
        //midi.currentdirection=0;
        /// [self.audioEngine stopBreath];
   // }

  ///  if (continuous == 0){
      //  NSLog(@"DISALLOWING NEXT NOTE");
    //    _allowNextNote = false;
   // }
}
-(void)btleManager:(BTLEManager*)manager exhaleWithValue:(float)percentOfmax{
    BOOL  continuous=[[[NSUserDefaults standardUserDefaults]valueForKey:@"continuousBreath"]boolValue];
    
    MidiController  *midi=[MidiController new];
    
   // if (_allowNextNote == true){
 //       MidiController  *midi=[MidiController new];
        midi.velocity=127.0*percentOfmax;
        midi.currentdirection=midiinhale;
        [self midiNoteContinuing:midi];
       // NSLog(@"ALLOWED");
   // }else{
   //     if (continuous == 0){
   //         NSLog(@"DISALLOWING NEXT NOTE");
         //   _allowNextNote = false;
   //     }
        
 //   }
        

    
}
-(void)midiNoteBegan:(MidiController*)midi
{
    
    NSLog(@"%s",__func__);
      if (midi.currentdirection==midiexhale) {
        
        
        if (self.useInhale) {
            [self.audioEngine beginBreath];
            
            self.audioEngine.delegate=self;
            // [self.audioEngine beginBreath];
            
        }else
        {
            return;

        }
        
    }else if (midi.currentdirection==midiinhale)
    {
        if (!self.useInhale) {
            [self.audioEngine beginBreath];
            
            self.audioEngine.delegate=self;
            //[self.audioEngine beginBreath];
            
        }else
        {
            return;

        }
    }

    
    

}
-(void)midiNoteStopped:(MidiController*)midi
{
    NSLog(@"%s",__func__);
    ///_allowNextNote = true;
   /* [super midiNoteStopped:midi];
    if (!self.tableViewController) {
        self.tableViewController = [[SongModeTableViewController alloc] initWithStyle:UITableViewStylePlain];
        
        self.tableViewController.delegate=self;
        
    }
    
    [self.tableViewController toggle];*/
    [self.audioEngine stopBreath];
    


}
-(IBAction)test2:(id)sender
{
    [self midiNoteStopped:nil];
}
-(IBAction)test:(id)sender;
{
    self.audioEngine.delegate=self;

    [self.audioEngine beginBreath];

}
-(void)midiNoteContinuing:(MidiController*)midi
{
   /// NSLog(@"%s",__func__);
    
   // if (_allowNextNote == true){
    
    if (midi.currentdirection==midiexhale) {
        
        
        if (self.useInhale) {
            // [self.audioEngine beginBreath];
            
        }else
        {
            return;
            
        }
        
    }else if (midi.currentdirection==midiinhale)
    {
        if (!self.useInhale) {
            //[self.audioEngine beginBreath];
            
        }else
        {
            return;
            
        }
    }

    NSTimeInterval  now=[[NSDate date]timeIntervalSince1970];
    
    if ((now-self.lasttime)<1)
    {
        self.lasttime=[[NSDate date]timeIntervalSince1970];
        return;
    }
    
    self.lasttime=[[NSDate date]timeIntervalSince1970];
    
    float setting=[[[NSUserDefaults standardUserDefaults]valueForKey:@"threshold"]floatValue];
    
   // [super sendLogToOutput:[NSString stringWithFormat:@"settting == %f \n",setting]];
   // [super sendLogToOutput:[NSString stringWithFormat:@"velocity == %f \n",midi.velocity]];
    if (midi.velocity<setting) {
        
        [self.audioEngine stopBreath];

        return;
        
        
    }
    [super midiNoteBegan:midi];
    
    /*if (midi.currentdirection==midiexhale) {
        
        
        if (self.useInhale) {
            [self.audioEngine beginBreath];
            
        }
        
    }else if (midi.currentdirection==midiinhale)
    {
        if (!self.useInhale) {
            [self.audioEngine beginBreath];
            
        }
    }*/
   // }
}
-(void)sendLogToOutput:(NSString*)log
{
    [super sendLogToOutput:log];
}
@end
