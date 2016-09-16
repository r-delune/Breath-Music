//
//  SettingsViewController.h
//  BreathMusic
//
//  Created by barry on 20/10/2014.
//  Copyright (c) 2014 rocudo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController
@property(nonatomic,weak)IBOutlet UISlider  *thresholdSlider;
@property(nonatomic,weak)IBOutlet UILabel   *valueLabel;
-(IBAction)valueChanged:(id)sender;
-(IBAction)mainMenu:(id)sender;
@end
