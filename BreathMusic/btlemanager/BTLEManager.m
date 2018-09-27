//
//  BTLEManager.m
//  GrooveTubeMelodySmart
//
//  Created by barry on 19/08/2015.
//  Copyright (c) 2015 rocudo. All rights reserved.
//

#import "BTLEManager.h"
#import "MelodyManager.h"
#import "NSData+NSData_Conversion.h"

#define ZERO_BOTTOM 1930
#define ZERO_TOP 1990
#define DEADZONE 50


#define START_STOP_AVERAGE 10

@interface BTLEManager ()< MelodySmartDelegate, MelodyManagerDelegate>
@property(nonatomic,copy)NSString  *deviceName;
@property (nonatomic, strong) MelodySmart *melody;
@property (nonatomic, strong) MelodyManager *manager;
@property(nonatomic,strong)NSTimer  *pollTimer;
@property int startingCount;
@property int stoppingCount;
@property int zeroBottom_;
@property int zeroTop_;
@property  BOOL isNeuteralising;
@property  int samplesTaken_;
@property int neutralValueAverage_;
@property int deadZone_;
@property float rangeReduction_;
@property (nonatomic,strong)NSMutableArray  *neutralArray_;
@property     dispatch_source_t _timer;
@property dispatch_queue_t queue;

@end
@implementation BTLEManager

+ (instancetype)sharedInstance
{
    static BTLEManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BTLEManager alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

-(void)dealloc
{
    [self stop];
    dispatch_source_cancel(__timer);
    [self.melody disconnect];
    self.delegate=nil;
    self.melody=nil;
    self.manager=nil;
    
}
-(void)calibrate
{
    int sum=0;
    for (NSNumber  *number in _neutralArray_) {
        
        sum+=[number intValue];
    }
    
    _neutralValueAverage_ = sum/ [_neutralArray_ count];
    
    _zeroTop_=_neutralValueAverage_+_deadZone_;
    _zeroBottom_=_neutralValueAverage_-_deadZone_;
    
    _isNeuteralising=NO;
    
    [self ledLeftOn];
    
    
}
//GroovTube 2.0
-(void)startWithDeviceName:(NSString*)deviceName andPollInterval:(float)interval
{
    _zeroBottom_=ZERO_BOTTOM;
    _zeroTop_=ZERO_TOP;
    _deadZone_=DEADZONE;
    _rangeReduction_=1;
    self.btleState=BTLEState_Stopped;
    
    self.manager = [[MelodyManager alloc] init];
    
    self.deviceName=deviceName;
    self.manager.delegate = self;
    self.btleState=BTLEState_Stopped;
    
    __unsafe_unretained BTLEManager *weakSelf = self;
    
    
    //ios12
    //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), _queue, ^{
        if (weakSelf) {
            [weakSelf startScanning];
            
        }
        
    //});
    
    //self.pollTimer=[NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(requestBTData:) userInfo:nil repeats:YES];
    [self startTimerWithInterval:interval];
}

-(void)startTimerWithInterval:(float)interval
{
    __unsafe_unretained BTLEManager *weakSelf = self;
    __timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _queue);
    if (__timer)
    {
        dispatch_source_set_timer(__timer, dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC), interval * NSEC_PER_SEC, (1ull * NSEC_PER_SEC) / 10);
        dispatch_source_set_event_handler(__timer, ^{
            if (weakSelf) {
                [weakSelf requestBTData:nil];
                
            }
            
        });
        dispatch_resume(__timer);
    }
    
}

-(void)stopTimer
{
    //[self.pollTimer invalidate];
    // self.pollTimer=nil;
    
}
-(void)requestData
{
    
   // NSLog(@"rssi %i",[[self.melody RSSI]intValue]);
    
    NSData* data = [@"?b" dataUsingEncoding:NSUTF8StringEncoding];
    
   // NSLog(@"melody connected %i",[self.melody isConnected]);
    if ([self.melody isConnected]==NO) {
        
        [self.melody connect];
        return;
    }
    //  [self.melody setDataNotification:YES];
    self.melody.delegate=self;
    [self.melody sendData:data];
    
    
    
}
-(void)requestBTData:(NSTimer*)timer
{
    //assert([NSThread isMainThread]);
    //NSLog(@"rssi %i",[[self.melody RSSI]intValue]);
    
    NSData* data = [@"?b" dataUsingEncoding:NSUTF8StringEncoding];
    
    //  NSLog(@"melody connected %i",[self.melody isConnected]);
    if ([self.melody isConnected]==NO) {
        
        [self.melody connect];
        return;
    }
    // [self.melody setDataNotification:YES];
    self.melody.delegate=self;
    [self.melody sendData:data];
    
}
-(void)startScanning
{
    self.manager.delegate=self;
    [self.manager scanForMelody];
    self.manager.delegate=self;
    
}

-(void)stopScanning
{
    [self.manager stopScanning];
    
    
}
-(void)stop
{
    [self.pollTimer invalidate];
    self.pollTimer=nil;
    //[self.manager stopScanning];
}


-(void)connect
{
    
    self.melody = [MelodyManager foundDeviceAtIndex:0];
    self.melody.delegate = self;
    
    //ios12
    //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), _queue, ^{
        [self.melody connect];
    //});
}
#pragma mark -
#pragma mark - LED ON OFF

-(void)ledLeftOn
{
    NSData* data = [@"l1" dataUsingEncoding:NSUTF8StringEncoding];
  //  NSLog(@"%s",__func__);
    
    //[self.melody setDataNotification:YES];
    
    [self.melody sendData:data];
    
}

-(void)ledLeftOff
{
    
 //   NSLog(@"%s",__func__);
    NSData* data = [@"l0" dataUsingEncoding:NSUTF8StringEncoding];
    
    // [self.melody setDataNotification:YES];
    
    [self.melody sendData:data];
}
-(void)ledRightOn
{
    
    NSData* data = [@"r1" dataUsingEncoding:NSUTF8StringEncoding];
    
    // [self.melody setDataNotification:YES];
    
    
    [self.melody sendData:data];
    
}
-(void)ledRightOff
{
    
    NSData* data = [@"r0" dataUsingEncoding:NSUTF8StringEncoding];
    
    // [self.melody setDataNotification:YES];
    
    [self.melody sendData:data];
}

#pragma mark -
#pragma mark - MelodyManagerDelegate

- (void) melodyManagerDiscoveryDidRefresh:(MelodyManager*)manager
{
 //   NSLog(@"%s",__func__);
    
    //[foundDevices reloadData];
 //   NSLog(@"!!!!!!!!");
    if ([MelodyManager numberOfFoundDevices]>0) {
        
        
        [self connect];
        
    }
 //   NSLog(@"%@",[MelodyManager foundDeviceAtIndex:0]);
}

- (void) melodyManagerDiscoveryStatePoweredOff:(MelodyManager*)manager
{
    
 //   NSLog(@"%s",__func__);
    
 //   NSLog(@"BT IS OFF");
}
- (void)cancelTimer
{
    if (__timer) {
        dispatch_source_cancel(__timer);
        // Remove this if you are on a Deployment Target of iOS6 or OSX 10.8 and above
        __timer = nil;
    }
}

- (void) melodySmart:(MelodySmart*)m didConnectToMelody:(BOOL) result {
    
    //[self ledLeftOn];
    
    if (!_queue) {
        _queue= dispatch_queue_create("serialQ", DISPATCH_QUEUE_SERIAL);
    }
    
    self.isConnected=YES;
 //   NSLog(@"%s",__func__);
    _zeroBottom_=ZERO_BOTTOM;
    _zeroTop_=ZERO_TOP;
    _samplesTaken_=0;
    _isNeuteralising=YES;
    if (_neutralArray_) {
        [_neutralArray_ removeAllObjects];
    }else
    {
        _neutralArray_=[NSMutableArray new];
    }
    if (m == self.melody && !result) {
        self.melody = nil;
    }
    [self.melody setDataNotification:YES];
    [self.delegate btleManagerConnected:self];
}

-(void) melodySmartDidPopulateMelodyService:(MelodySmart*)m {
    /*if (m == melody) {
     UIAppDelegate.melody = melody;
     [[NSNotificationCenter defaultCenter] postNotificationName:@"MelodyDeviceUpdateNotification" object: nil];
     MMDrawerController * drawerController = (MMDrawerController *)UIAppDelegate.window.rootViewController;
     [drawerController closeDrawerAnimated:YES completion:nil];
     }*/
 //   NSLog(@"%s",__func__);
    
}

- (void) melodySmartDidDisconnectFromMelody:(MelodySmart*) melody {
    
  //  NSLog(@"disconnected %@",melody);
  //  NSLog(@"%s",__func__);
    _isConnected=NO;
    [self.delegate btleManagerDisconnected:self];
    
}
-(void)setTreshold:(int)threshold
{
    if (_neutralValueAverage_==0) {
        return;
    }
    _deadZone_=threshold;
    _zeroTop_=_neutralValueAverage_+_deadZone_;
    _zeroBottom_=_neutralValueAverage_-_deadZone_;
    //[_neutralArray_ removeAllObjects];
    //_isNeuteralising=YES;
    
}
-(void)setRangeReduction:(float)range
{
    _rangeReduction_=range;
    
}
- (void) melodySmart:(MelodySmart*)m didReceiveData:(NSData*)data
{
    NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    content =[NSString stringWithFormat:@"0x%@",content];
    // NSLog(@"blah %@",content);
    unsigned int outVal;
    NSScanner* scanner = [NSScanner scannerWithString:content];
    [scanner scanHexInt:&outVal];
    
    // NSLog(@"outval %i",outVal);
    
    if (_isNeuteralising) {
        NSNumber  *num=[NSNumber numberWithInt:outVal];
        [_neutralArray_ addObject:num];
        
        if ([_neutralArray_ count]>=100) {
            
            _isNeuteralising=NO;
            [self calibrate];
        }
        return;
    }
    
    
    //fff == 4095
    float fullmax= 4096-_zeroTop_;
    float fullmin= _zeroBottom_; //- MAX_INHALE;
    
    if (outVal<_zeroBottom_)
    {
        float value=outVal;
        
        float percent=(_zeroBottom_-value)/fullmin;
        //float percent=(_zeroBottom_)/fullmin;
        self.percentOfMax=percent;

        if (percent>1.0) {
            percent=1.0;
        }
        //  NSLog(@"pct == %f\n",percent);
        // NSLog(@"value == %f\n",value);
        // // NSLog(@"zero bottom %d\n",_zeroBottom_);
        //  NSLog(@"full min == %f\n",fullmin);
        if (self.btleState==BTLEState_Stopped) {
            //
            
            self.btleState=BTLEState_Began;
            dispatch_async(dispatch_get_main_queue(), ^{
                //       [self ledRightOn];
                [self.delegate btleManagerBreathBegan:self];
                if ([self.delegate respondsToSelector:@selector(btleManagerBreathBeganWithInhale:)]) {
                    [self.delegate btleManagerBreathBeganWithInhale:self];
                }
            });
            
        }else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.delegate btleManager:self inhaleWithValue:percent*_rangeReduction_];
            });
            
        }
        
    }else if (outVal>_zeroTop_)
    {
        
        float value=outVal;
        
        float percent=(value-_zeroTop_)/fullmax;
        
        //sometimes it goes to 1.3
  //      NSLog(@"pct == %f\n",percent);
  //      NSLog(@"value == %f\n",value);
  //      NSLog(@"zero top %d\n",_zeroTop_);
  //      NSLog(@"full max == %f\n",fullmax);
        self.percentOfMax=percent;

        if (percent>1.0) {
            percent=1.0;
        }
        if (self.btleState==BTLEState_Stopped) {
            //
            
            self.btleState=BTLEState_Began;
            dispatch_async(dispatch_get_main_queue(), ^{
                //  [self ledLeftOn];
                [self.delegate btleManagerBreathBegan:self];
                if ([self.delegate respondsToSelector:@selector(btleManagerBreathBeganWithExhale:)]) {
                    [self.delegate btleManagerBreathBeganWithExhale:self];
                }
                
            });
            
        }else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.delegate btleManager:self exhaleWithValue:percent*_rangeReduction_];
            });
            
        }
        
        
    }else
    {
        if (self.btleState!=BTLEState_Stopped) {
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // [self ledLeftOff];
                // [self ledRightOff];
                [self.delegate btleManagerBreathStopped:self];
            });
            
            
            self.btleState=BTLEState_Stopped;
            
        }
        
    }
    
    switch (self.btleState) {
        case BTLEState_Began:
            
            break;
        case BTLEState_Beginnging:
            
            break;
            
        case BTLEState_Stopped:
            
            break;
            
        case BTLEState_Stopping:
            
            break;
            
        default:
            break;
    }
    
}

-(void)handleBegan
{
    self.startingCount=0;
    self.stoppingCount=0;
}



-(void)handleStopped;
{
    self.startingCount=0;
    self.stoppingCount=0;
}
-(void)handlebeginning
{
    
}
-(void)handleStopping
{
    
    
}
-(NSString*) charToHex:(unsigned char*)data dataLen:(int)dlen
{
    NSMutableString* hexStr = [NSMutableString stringWithCapacity:dlen * 2];
    
    int i;
    // Note 'data' contains a null terminator. Subtract an extra 1
    // from 'dlen' in this loop:
    for(i = 0; i < dlen-1; i++)
        [hexStr appendFormat:@"%02x ", data[i]];
    
    return [NSString stringWithString: hexStr];
}
- (void) melodySmart:(MelodySmart*)m didReceivePioChange:(unsigned char)state WithLocation:(BcSmartPioLocation)location
{
    // NSLog(@"%s",__func__);
}

- (void) melodySmart:(MelodySmart*)m didReceivePioSettingChange:(unsigned char)state WithLocation:(BcSmartPioLocation)location {
    // NSLog(@"%s",__func__);
    
}
- (void) melodySmart:(MelodySmart*)melody didSendData:(NSError*)error
{
    // NSLog(@"%s",__func__);
    
}

- (void)melodySmart:(MelodySmart *)melody didReceiveI2cReplyWithSuccess:(BOOL)success data:(NSData *)data {
    //[i2cController didReceiveI2cReplyWithSuccess:success data:data];
}

- (void)melodySmart:(MelodySmart *)melody didReceiveCommandReply:(NSData *)data {
    //[commandsController didReceiveCommandReply:data];
}

- (void)melodySmart:(MelodySmart *)melody didDetectBootMode:(BootMode)bootMode {
    // [otauController didDetectBootMode:bootMode];
}

- (void)melodySmart:(MelodySmart *)melody didUpdateOtauState:(OtauState)state withProgress:(int)percent {
    // [otauController didUpdateOtauState:state percent:percent];
}


@end
