//
//  SongViewController.h
//  BreathMusic
//
//  Created by barry on 08/09/2014.
//  Copyright (c) 2014 rocudo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeyDetectViewController.h"
@interface SongViewController : KeyDetectViewController

@property(nonatomic,weak)IBOutlet UIButton  *toggleDirectionButton;
-(IBAction)toggleButtonHit:(id)sender;
-(IBAction)test:(id)sender;
@property(nonatomic,weak)IBOutlet  UIButton  *testbutton;
-(IBAction)test2:(id)sender;
@property(nonatomic,weak)IBOutlet  UIButton  *stoptestbutton;
@end
