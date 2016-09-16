//
//  KeyViewController.m
//  BreathMusic
//
//  Created by barry on 05/09/2014.
//  Copyright (c) 2014 rocudo. All rights reserved.
//

#import "KeyViewController.h"
#import "KeyTableViewController.h"
#import "InstrumentTableViewController.h"
#import "ScaleAudioEngine.h"
#import "GCDQueue.h"
#import "ScaleTableViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIGlossyButton.h"

#import "UIView+LayerEffects.h"
#import  "BTLEManager.h"
@interface KeyViewController ()<KeyTableViewProtocol,InstrumentTableViewProtocol,ScaleTableViewProtocol,BTLEManagerDelegate>

@property(nonatomic,strong)UIPopoverController  *popover;
@property(nonatomic,weak)IBOutlet UIGlossyButton  *keyButton;
@property(nonatomic,weak)IBOutlet UIGlossyButton  *instrumentButton;
@property(nonatomic,strong)ScaleAudioEngine  *engine;


@property(readwrite)int currentOctave;
@property (nonatomic,strong) KeyTableViewController *keytableViewController;
@property (nonatomic,strong) InstrumentTableViewController *instrumenttableViewController;
@property(nonatomic,strong)NSArray  *buttonArray;
@property(nonatomic,strong)NSTimer   *keyTimer;
@property int notIndex;

@property(nonatomic,weak)IBOutlet  UIGlossyButton  *button1;
@property(nonatomic,weak)IBOutlet  UIGlossyButton  *button2;
@property(nonatomic,weak)IBOutlet  UIGlossyButton  *button3;
@property(nonatomic,weak)IBOutlet  UIGlossyButton  *button4;
@property(nonatomic,weak)IBOutlet  UIGlossyButton  *button5;
@property(nonatomic,weak)IBOutlet  UIGlossyButton  *button6;
@property(nonatomic,weak)IBOutlet  UIGlossyButton  *button7;
@property(nonatomic,weak)IBOutlet  UIGlossyButton  *button8;
@property(nonatomic,weak)IBOutlet  UIGlossyButton  *scaleButton;


@property BOOL  gotFirstVelocity;
@property NSTimeInterval  lasttime;

-(IBAction)keyButtonPressed:(id)sender;
-(IBAction)instrumentButtonPressed:(id)sender;
-(IBAction)goToMainMenu:(id)sender;
-(IBAction)scaleButtonHit:(id)sender;

-(IBAction)do2Hit:(id)sender;

-(IBAction)doHit:(id)sender;
-(IBAction)raHit:(id)sender;
-(IBAction)meHit:(id)sender;
-(IBAction)faHit:(id)sender;
-(IBAction)soHit:(id)sender;
-(IBAction)laHit:(id)sender;
-(IBAction)tiHit:(id)sender;

@end

@implementation KeyViewController

-(IBAction)do2Hit:(id)sender{
    
    [self.engine playNote:@"Do2"];
    
    // [sender accessibilityActivate];
    
    
}
-(IBAction)doHit:(id)sender{

    [self.engine playNote:@"Do"];
    
   // [sender accessibilityActivate];
    

}

-(IBAction)raHit:(id)sender{
    [self.engine playNote:@"Ra"];
   // [sender accessibilityActivate];


}
-(IBAction)meHit:(id)sender{
    [self.engine playNote:@"Mi"];
   // [sender accessibilityActivate];


}
-(IBAction)faHit:(id)sender{
    [self.engine playNote:@"Fa"];
   // [sender accessibilityActivate];


}
-(IBAction)soHit:(id)sender{
    [self.engine playNote:@"So"];
   // [sender accessibilityActivate];


}
-(IBAction)laHit:(id)sender{
    [self.engine playNote:@"La"];
   // [sender accessibilityActivate];


}
-(IBAction)tiHit:(id)sender{
    [self.engine playNote:@"Ti"];
   // [sender accessibilityActivate];


}

-(IBAction)goToMainMenu:(id)sender
{
    [self.engine cleanup];
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(IBAction)scaleButtonHit:(id)sender

{
    UIButton *button = (UIButton*)sender;

    ScaleTableViewController  *stvc=[[ScaleTableViewController alloc]initWithStyle:UITableViewStylePlain];
    stvc.delegate=self;
    _popover= [[UIPopoverController alloc] initWithContentViewController:stvc];

    [_popover presentPopoverFromRect:CGRectMake(button.frame.size.width / 2, button.frame.size.height / 1, 1, 1) inView:button permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];

}
-(IBAction)keyButtonPressed:(id)sender
{
    UIButton *button = (UIButton*)sender;
    
   self.keytableViewController = [[KeyTableViewController alloc] initWithStyle:UITableViewStylePlain];
    
    self.keytableViewController.delegate=self;
    _popover= [[UIPopoverController alloc] initWithContentViewController:self.keytableViewController];
    [_popover presentPopoverFromRect:CGRectMake(button.frame.size.width / 2, button.frame.size.height / 1, 1, 1) inView:button permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];

}
-(IBAction)instrumentButtonPressed:(id)sender
{
    UIButton *button = (UIButton*)sender;

    self.instrumenttableViewController = [[InstrumentTableViewController alloc] initWithStyle:UITableViewStylePlain];
    
    self.instrumenttableViewController.delegate=self;
    _popover= [[UIPopoverController alloc] initWithContentViewController:self.instrumenttableViewController];
    [_popover presentPopoverFromRect:CGRectMake(button.frame.size.width / 2, button.frame.size.height / 1, 1, 1) inView:button permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}
-(void)instrumentSelected:(NSDictionary *)instrument
{
    
    NSString *name=[instrument valueForKey:@"InstrumentName"];
    //self.instrumentButton.titleLabel.text=[NSString stringWithFormat:@"Instrument : %@",instrument];
    [self.instrumentButton setTitle:[NSString stringWithFormat:@"Instrument : %@",name] forState:UIControlStateNormal];
    [_popover dismissPopoverAnimated:YES];
    
    int presetNumber=[[instrument valueForKey:@"InstrumentNumber"]intValue];
    [self.engine setInstrument:presetNumber ];
    
    
}
-(void)keySelected:(NSString *)key
{
    [self.keyButton setTitle:[NSString stringWithFormat:@"Key : %@",key] forState:UIControlStateNormal];
    NSLog(@"KEY %@",key);
    [_popover dismissPopoverAnimated:YES];
    
    [self.engine setKey:key];
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
    self.gotFirstVelocity=NO;
    self.buttonArray=@[self.button1,self.button2,self.button3,self.button4,self.button5,self.button6,self.button7,self.button8];
    self.engine=[[ScaleAudioEngine alloc]init];
    [self.engine setup];
    self.keytableViewController = [[KeyTableViewController alloc] initWithStyle:UITableViewStylePlain];
    self.instrumenttableViewController = [[InstrumentTableViewController alloc] initWithStyle:UITableViewStylePlain];
    
    self.lasttime=[[NSDate date]timeIntervalSince1970];
   // [self midiNoteBegan:nil];
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"ScaleData" ofType:@"plist"];

    NSArray *scales = [NSArray arrayWithContentsOfFile:plistPath];
    self.engine.currentScale=scales[0];
  /*  [[GCDQueue mainQueue]queueBlock:^{
        [self startTimerWithInterval:1];

    } afterDelay:3];*/
    // Do any additional setup after loading the view.
    
    
    [self.button1 useWhiteLabel: YES];
    self.button1.buttonTintColor =[UIColor colorWithRed:54.0/255.0 green:88.0/255.0 blue:151.0/255.0 alpha:1];
    [self.button1 setShadow:[UIColor lightGrayColor] opacity:0.8 offset:CGSizeMake(0, 1) blurRadius: 4];
  //  [self.button1 setGradientType:kUIGlossyButtonGradientTypeLinearSmoothBrightToNormal];
    
    
    [self.button2 useWhiteLabel: YES];
    self.button2.buttonTintColor = [UIColor colorWithRed:54.0/255.0 green:88.0/255.0 blue:151.0/255.0 alpha:1];
    [self.button2 setShadow:[UIColor lightGrayColor] opacity:0.8 offset:CGSizeMake(0, 1) blurRadius: 4];
   // [self.button2 setGradientType:kUIGlossyButtonGradientTypeLinearSmoothBrightToNormal];
    
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
   // [self.button6 setGradientType:kUIGlossyButtonGradientTypeLinearSmoothBrightToNormal];
    
    [self.button7 useWhiteLabel: YES];
    self.button7.buttonTintColor = [UIColor colorWithRed:54.0/255.0 green:88.0/255.0 blue:151.0/255.0 alpha:1];
    [self.button7 setShadow:[UIColor lightGrayColor] opacity:0.8 offset:CGSizeMake(0, 1) blurRadius: 4];
   // [self.button7 setGradientType:kUIGlossyButtonGradientTypeLinearSmoothBrightToNormal];
    
    [self.button8 useWhiteLabel: YES];
    self.button8.buttonTintColor = [UIColor colorWithRed:54.0/255.0 green:88.0/255.0 blue:151.0/255.0 alpha:1];
    [self.button8 setShadow:[UIColor lightGrayColor] opacity:0.8 offset:CGSizeMake(0, 1) blurRadius: 4];
   // [self.button8 setGradientType:kUIGlossyButtonGradientTypeLinearSmoothBrightToNormal];
    
    [self.scaleButton useWhiteLabel: YES];
    self.scaleButton.buttonTintColor = [UIColor colorWithRed:54.0/255.0 green:88.0/255.0 blue:151.0/255.0 alpha:1];
    [self.scaleButton setShadow:[UIColor lightGrayColor] opacity:0.8 offset:CGSizeMake(0, 1) blurRadius: 4];
   // [self.scaleButton setGradientType:kUIGlossyButtonGradientTypeLinearSmoothBrightToNormal];
    
    [self.instrumentButton useWhiteLabel: YES];
    self.instrumentButton.buttonTintColor = [UIColor colorWithRed:54.0/255.0 green:88.0/255.0 blue:151.0/255.0 alpha:1];
    [self.instrumentButton setShadow:[UIColor lightGrayColor] opacity:0.8 offset:CGSizeMake(0, 1) blurRadius: 4];
  //  [self.instrumentButton setGradientType:kUIGlossyButtonGradientTypeLinearSmoothBrightToNormal];
    
   }
-(void)viewWillAppear:(BOOL)animated
{

    [[BTLEManager sharedInstance]setDelegate:self];
    if ([BTLEManager sharedInstance].isConnected==NO) {
        [[BTLEManager sharedInstance]startWithDeviceName:@"GroovTube" andPollInterval:0.1];
    }
    
    [self.btleManager setTreshold:60];

}
-(void)btleManagerBreathBegan:(BTLEManager*)manager{}
-(void)btleManagerBreathBeganWithInhale:(BTLEManager*)manager{

    NSLog(@"EXHALLING STILL");

    
    float setting=[[[NSUserDefaults standardUserDefaults]valueForKey:@"threshold"]floatValue];
    
    float velocity=manager.percentOfMax*1280;
    if (velocity<=setting) {
        return;
    }
    NSTimeInterval  now=[[NSDate date]timeIntervalSince1970];
    
    if ((now-self.lasttime)<0.15)
    {
        self.lasttime=[[NSDate date]timeIntervalSince1970];
        return;
    }
    MidiController  *midi=[MidiController new];
    midi.currentdirection=midiexhale;
    [super midiNoteBegan:midi];
    self.lasttime=[[NSDate date]timeIntervalSince1970];
    
        self.notIndex--;
        if (self.notIndex<0) {
            self.notIndex=6;
        }
        [self highlightButton:self.buttonArray[self.notIndex]];
    
    
    [self playForIndex:self.notIndex];

}


-(void)btleManagerBreathBeganWithExhale:(BTLEManager*)manager{

    NSLog(@"EXHALLING STILL");
    
    
    float setting=[[[NSUserDefaults standardUserDefaults]valueForKey:@"threshold"]floatValue];
    
    float velocity=manager.percentOfMax*1280;
    if (velocity<=setting) {
        return;
    }
    NSTimeInterval  now=[[NSDate date]timeIntervalSince1970];
    
    if ((now-self.lasttime)<0.15)
    {
        self.lasttime=[[NSDate date]timeIntervalSince1970];
        return;
    }
    
    MidiController  *midi=[MidiController new];
    midi.currentdirection=midiinhale;
    [super midiNoteBegan:midi];
    
    self.lasttime=[[NSDate date]timeIntervalSince1970];
    
    self.notIndex++;
    
    if (self.notIndex>7) {
        self.notIndex=0;
    }
    [self highlightButton:self.buttonArray[self.notIndex]];
    
    [self playForIndex:self.notIndex];

}

-(void)btleManagerBreathStopped:(BTLEManager*)manager{
    [self midiNoteStopped:nil];

    NSLog(@"func %s",__func__);

}

-(void)btleManagerConnected:(BTLEManager*)manager{


    NSLog(@"func %s",__func__);

}
-(void)btleManagerDisconnected:(BTLEManager*)manager{

    NSLog(@"func %s",__func__);

}

-(void)btleManager:(BTLEManager*)manager inhaleWithValue:(float)percentOfmax{

    NSLog(@"func %s",__func__);

}
-(void)btleManager:(BTLEManager*)manager exhaleWithValue:(float)percentOfmax{

    NSLog(@"func %s",__func__);

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillDisappear:(BOOL)animated
{
    [[GCDQueue mainQueue]queueBlock:^{
        
        [self.keyTimer invalidate];
        self.keyTimer=nil;
        [self.engine cleanup];

    }];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
{
    [super textView:textView shouldChangeTextInRange:range replacementText:text];
    
    if ( [text isEqualToString:@"\n"] ) {
        //Do whatever you want
        
        NSLog(@"Return!!");
        
        self.notIndex++;
        
        if (self.notIndex>7) {
            self.notIndex=0;
        }
        [self highlightButton:self.buttonArray[self.notIndex]];
    }
    
    if([text isEqualToString:@" "])
    {
        NSLog(@"Space");
        self.notIndex--;
        if (self.notIndex<0) {
            self.notIndex=7;
        }
        [self highlightButton:self.buttonArray[self.notIndex]];
        
    }
    
    [self playForIndex:self.notIndex];

    return YES;
}
#pragma mark --
#pragma mark MIDI

-(void)midiNoteBegan:(MidiController*)midi
{
    NSLog(@"EXHALLING STILL");

    NSTimeInterval  now=[[NSDate date]timeIntervalSince1970];
    
    if ((now-self.lasttime)<0.15)
    {
        self.lasttime=[[NSDate date]timeIntervalSince1970];
        return;
    }
    [super midiNoteBegan:midi];

    self.lasttime=[[NSDate date]timeIntervalSince1970];

    [super sendLogToOutput:[NSString stringWithFormat:@"note == %i",midi.currentdirection]];
    if (midi.currentdirection==midiinhale) {
        
        self.notIndex++;
        
        if (self.notIndex>7) {
            self.notIndex=0;
        }
        [self highlightButton:self.buttonArray[self.notIndex]];
        
    }else if (midi.currentdirection==midiexhale)
    {
        self.notIndex--;
        if (self.notIndex<0) {
            self.notIndex=6;
        }
        [self highlightButton:self.buttonArray[self.notIndex]];
    }

    [self playForIndex:self.notIndex];
}
-(void)midiNoteStopped:(MidiController*)midi
{
    [super midiNoteStopped:midi];

    self.gotFirstVelocity=NO;
}
-(void)midiNoteContinuing:(MidiController*)midi
{
    
   /* if (!self.gotFirstVelocity) {
        
        if (midi.velocity>0) {
            
            
            self.gotFirstVelocity=YES;
            
            float v=midi.velocity;
            if (v>100) {
                v=100;
            }
            
            [self.engine setTheVelocity:10.0/v];
            [[GCDQueue mainQueue]queueBlock:^{
                [self startTimerWithInterval:10.0/v];
                
            }];
            [self sendLogToOutput:[NSString stringWithFormat:@"%f",midi.velocity]];

        }
    }*/
    
   
    
}
-(void)sendLogToOutput:(NSString*)log
{
    [super sendLogToOutput:log];

}

-(void)startTimerWithInterval:(float)interval
{
   /* if (self.keyTimer) {
        [self.keyTimer invalidate];
        self.keyTimer=nil;
    }
    self.octaveIndex=3;
    self.notIndex=0;

    [self ocatveSelected:[NSNumber numberWithInt:self.octaveIndex]];

    if (self.keyTimer) {
        [self.keyTimer invalidate];
        self.keyTimer=nil;
    }
  self.keyTimer=  [NSTimer scheduledTimerWithTimeInterval:interval
                                     target:self
                                   selector:@selector(timerFunction:)
                                   userInfo:nil
                                    repeats:YES];*/
}

-(void)stopTimer
{

}
-(void)highlightButton:(UIButton*)button
{
    [[GCDQueue mainQueue]queueBlock:^{
        for (UIButton  *abutton in self.buttonArray) {
            
            if (abutton == button) {
                abutton.titleLabel.textColor=[UIColor greenColor];
            }else
            {
                abutton.titleLabel.textColor=[UIColor whiteColor];
                
            }
        }
    }];
    
}

-(void)timerFunction:(NSTimer*)timer

{
   /* NSLog(@" timer ");
    if (self.notIndex>=7) {
        
        self.notIndex=0;
        
        self.octaveIndex++;
        
        
        if (self.octaveIndex>=6) {
            
            [timer invalidate];
            timer=nil;
            return;
        }
        
        [self ocatveSelected:[NSNumber numberWithInt:self.octaveIndex]];

        
    }
    [self playForIndex:self.notIndex];
    
    [self highlightButton:self.buttonArray[self.notIndex]];
    self.notIndex++;*/


}
-(void)scaleSelected:(NSDictionary*)scaleIndex
{
    //self.engine.currentScaleIndex=scaleIndex;
    self.engine.currentScale=scaleIndex;
    [self.scaleButton setTitle:[scaleIndex valueForKey:@"ScaleName"] forState:UIControlStateNormal];
    [_popover dismissPopoverAnimated:YES];

   /* switch (scaleIndex) {
        case 0:
            [self.scaleButton setTitle:@"Major" forState:UIControlStateNormal];
            break;
            
        case 1:
            [self.scaleButton setTitle:@"Hava Nagila" forState:UIControlStateNormal];

            break;
        case 2:
            [self.scaleButton setTitle:@"Pentatonic" forState:UIControlStateNormal];

            break;
            
        default:
            break;
    }*/
}
-(void)playForIndex:(int)index
{
    
    switch (index) {
        case 0:
            [self doHit:nil];
            break;
        case 1:
            [self raHit:nil];
            break;
        case 2:
            [self meHit:nil];
            break;
        case 3:
            
            [self faHit:nil];
            break;
        case 4:
            [self soHit:nil];
            break;
        case 5:
            [self laHit:nil];
            break;
        case 6:
            [self tiHit:nil];
            break;
        case 7:
            [self do2Hit:nil];
            break;
            
        default:
            break;
    }
    
}

@end
