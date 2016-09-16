//
//  SettingsViewController.m
//  BreathMusic
//
//  Created by barry on 20/10/2014.
//  Copyright (c) 2014 rocudo. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()
@property(nonatomic,weak)IBOutlet  UISwitch *continuousBreathSwtich;
-(IBAction)switchTap:(id)sender;
@end

@implementation SettingsViewController
-(IBAction)switchTap:(id)sender

{
    
    NSNumber  *num=[NSNumber numberWithBool:self.continuousBreathSwtich.isOn];
    [[NSUserDefaults standardUserDefaults]setValue:num forKey:@"continuousBreath"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    float value=[[[NSUserDefaults standardUserDefaults]valueForKey:@"threshold"]floatValue];
    self.valueLabel.text=[NSString stringWithFormat:@"%0.2f",self.thresholdSlider.value];

    [self.thresholdSlider setValue:value];
    
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{

    BOOL isON=[[[NSUserDefaults standardUserDefaults]valueForKey:@"continuousBreath"]boolValue];
    
    [self.continuousBreathSwtich setOn:isON];
    float value=[[[NSUserDefaults standardUserDefaults]valueForKey:@"threshold"]floatValue];
    self.valueLabel.text=[NSString stringWithFormat:@"%0.2f",self.thresholdSlider.value];

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(IBAction)valueChanged:(id)sender

{
    self.valueLabel.text=[NSString stringWithFormat:@"%0.2f",self.thresholdSlider.value];
    
    [[NSUserDefaults standardUserDefaults]setValue:[NSNumber numberWithFloat:self.thresholdSlider.value] forKey:@"threshold"];

}

-(IBAction)mainMenu:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
