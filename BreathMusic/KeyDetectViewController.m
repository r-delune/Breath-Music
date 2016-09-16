//
//  KeyDetectViewController.m
//  BreathMusic
//
//  Created by barry on 29/09/2014.
//  Copyright (c) 2014 rocudo. All rights reserved.
//

#import "KeyDetectViewController.h"
#import "GCDQueue.h"
@interface KeyDetectViewController ()
@property(nonatomic,strong)UITextView *hiddenTextView;
@property BOOL keyboardShown;
@property BOOL isAnimating;
@property CGRect  barFrame;
@property CGRect inverseBarFrame;
@property (nonatomic,strong)BTLEManager  *btleManagerThis;
@end

@implementation KeyDetectViewController

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDisappear:) name:UIKeyboardWillHideNotification object:nil];
    // Do any additional setup after loading the view.
    [self setupKeyDetect];
    [self setupMidi];
    
    
    self.debugTextView=[[UITextView alloc]initWithFrame:CGRectMake(0, 500, 300, 300)];
    self.debugTextView.userInteractionEnabled=YES;
    self.debugTextView.scrollEnabled=YES;
    self.debugTextView.alpha=1.0f;

    [self addButtons];
    
    /*self.btleManager=[BTLEManager new];
    self.btleManager.delegate=self;
    [self.btleManager startWithDeviceName:@"GroovTube" andPollInterval:0.01];
    [self.btleManager setTreshold:60];*/
    
    [[BTLEManager sharedInstance]setDelegate:self];
    if ([BTLEManager sharedInstance].isConnected==NO) {
        [[BTLEManager sharedInstance]startWithDeviceName:@"GroovTube" andPollInterval:0.1];
    }
    
    [self.btleManager setTreshold:60];
    //[self.view addSubview:self.debugTextView];
}
-(void)dealloc
{
    @try {
        [[NSNotificationCenter defaultCenter]removeObserver:self forKeyPath:UIKeyboardWillShowNotification];
        [[NSNotificationCenter defaultCenter]removeObserver:self forKeyPath:UIKeyboardWillHideNotification];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@",exception.description);
    }
    @finally {
        
    }
   

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)setupKeyDetect{
    _hiddenTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [_hiddenTextView setHidden:YES];
    _hiddenTextView.text = @"aa";
    _hiddenTextView.delegate = self;
    _hiddenTextView.selectedRange = NSMakeRange(1, 0);
    [self.view addSubview:_hiddenTextView];
    _hiddenTextView.inputView = [[UIView alloc] initWithFrame:CGRectZero];
    [_hiddenTextView becomeFirstResponder];
        if (_keyboardShown){
            [_hiddenTextView resignFirstResponder];
        }
}
-(void)addButtons
{
    self.leftSwitchButton=[[UIButton alloc]initWithFrame:CGRectMake(650, 906, 35, 33)];
    [self.leftSwitchButton setImage:[UIImage imageNamed:@"SWITCH-White-OFF"] forState:UIControlStateNormal];
    
    self.rightSwitchButton=[[UIButton alloc]initWithFrame:CGRectMake(700, 906, 35, 33)];
    [self.rightSwitchButton setImage:[UIImage imageNamed:@"SWITCH-Orange-OFF"] forState:UIControlStateNormal];
    
    
    self.barBGImageView=[[UIImageView alloc]initWithFrame:CGRectMake(112, 906, 388, 30)];
    [self.barBGImageView setImage:[UIImage imageNamed:@"BREATH-Black"]];
    self.barImageView=[[UIImageView alloc]initWithFrame:CGRectMake(112, 906, 0, 30)];
    [self.barImageView setImage:[UIImage imageNamed:@"BREATH-Blue"]];
    
    self.barFrame=CGRectMake(112, 906, 0, 30);
    self.inverseBarFrame=CGRectMake(388+112, 906, 0, 30);
    
    [self.view addSubview:self.leftSwitchButton];
    [self.view addSubview:self.rightSwitchButton];
    [self.view addSubview:self.barBGImageView];
    [self.view addSubview:self.barImageView];

}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
{
    
    [[GCDQueue mainQueue]queueBlock:^{
        if ( [text isEqualToString:@"\n"] ) {
            //Do whatever you want
            //orange
            [self.rightSwitchButton setImage:[UIImage imageNamed:@"SWITCH-Orange-ON"] forState:UIControlStateNormal];
            [self.leftSwitchButton setImage:[UIImage imageNamed:@"SWITCH-White-OFF"] forState:UIControlStateNormal];
            
            [[GCDQueue mainQueue]queueBlock:^{
                [self.rightSwitchButton setImage:[UIImage imageNamed:@"SWITCH-Orange-OFF"] forState:UIControlStateNormal];

            } afterDelay:0.2];
            
            NSLog(@"Return!!");
        }
        
        if([text isEqualToString:@" "])
        {
            NSLog(@"Space");
            [self.rightSwitchButton setImage:[UIImage imageNamed:@"SWITCH-Orange-OFF"] forState:UIControlStateNormal];
            [self.leftSwitchButton setImage:[UIImage imageNamed:@"SWITCH-White-ON"] forState:UIControlStateNormal];
            //white
            
            [[GCDQueue mainQueue]queueBlock:^{
                [self.leftSwitchButton setImage:[UIImage imageNamed:@"SWITCH-White-OFF"] forState:UIControlStateNormal];

            } afterDelay:0.2];
        }

    
    
    }];
       return YES;
}
- (void)keyboardWillAppear:(NSNotification *)aNotification {
    _keyboardShown = YES;
}

- (void)keyboardWillDisappear:(NSNotification *)aNotification {
    _keyboardShown = NO;
}


#pragma mark --
#pragma mark MIDI
-(MidiController*)midiController
{
    return [MidiController sharedInstance];
}
-(void)setupMidi
{
    [[self midiController]setup];
    [[self midiController]setDelegate:self];
}
#pragma mark --
#pragma mark MIDI
-(void)invert
{
    [[GCDQueue mainQueue]queueBlock:^{
        CGAffineTransform verticalFlip = CGAffineTransformMakeScale(1,-1);
        self.barImageView.transform=verticalFlip;

    }];
    
    
}
-(void)restore
{
    /*[[GCDQueue mainQueue]queueBlock:^{
        CGAffineTransform verticalFlip = CGAffineTransformMakeScale(1,1);
        self.barImageView.transform=verticalFlip;
    }];*/
    
    
    
    
        
    
}
-(void)inverseResizeView:(UIView *)view width:(int)deltaWidth height:(int)deltaHeight{
    view.frame = CGRectMake(view.frame.origin.x - deltaWidth,
                            view.frame.origin.y ,
                            view.frame.size.width + deltaWidth,
                            view.frame.size.height);
}
-(void)btleManagerConnected:(BTLEManager *)manager
{
    
}

-(void)btleManagerDisconnected:(BTLEManager *)manager
{
    
}
-(void)midiNoteBegan:(MidiController*)midi
{
    
    
    NSLog(@"midiNoteBegan");

    
    BOOL inverse=NO;
    
    if (self.isAnimating) {
        return;
    }
    
    self.isAnimating=YES;
    
    if (midi.currentdirection==midiinhale) {
      //  [self sendLogToOutput:@"exhale"];
        self.barImageView.frame=self.barFrame;
       // [self restore];
        //[self.barImageView setContentMode:UIViewContentModeLeft];

    }else if (midi.currentdirection==midiexhale)
    {
       // [self sendLogToOutput:@"inhale"];
        inverse=YES;
        self.barImageView.frame=self.inverseBarFrame;
       // [self invert];
        //[self.barImageView setContentMode:UIViewContentModeRight];
    }
    
    [[GCDQueue mainQueue]queueBlock:^{
        self.debugTextView.text=[NSString stringWithFormat:@"%@, %@",self.debugTextView.text,@"ANIMATE"];

        [UIView animateWithDuration:1 animations:^{
            //CGRect frame=self.barImageView.frame;
            // frame.size.width=388;
           // self.barImageView.frame=frame;
            if (inverse) {
                [self inverseResizeView:self.barImageView width:388 height:30];

            }else
            {
            CGRect frame=self.barImageView.frame;
                frame.size.width=388;
                self.barImageView.frame=frame;
            }
        } completion:^(BOOL finsished){
        
            [UIView animateWithDuration:0.1 animations:^{
                CGRect frame=self.barImageView.frame;
                frame.size.width=0;
                self.barImageView.frame=frame;
            } completion:^(BOOL complete){
                self.isAnimating=NO;
            }];

        
        }];
    
    }];
}
-(void)midiNoteStopped:(MidiController*)midi
{
   
}
-(void)midiNoteContinuing:(MidiController*)midi
{
    
}
-(void)sendLogToOutput:(NSString*)log
{
    [[GCDQueue globalQueue]queueBlock:^{
    
        [[GCDQueue mainQueue]queueBlock:^{
            [self.debugTextView setText:[NSString stringWithFormat:@"%@ ,%@",self.debugTextView.text, log]];
           // [self.debugTextView setText:[NSString stringWithFormat:@"%@", log]];

        }];
    }];
}

@end
