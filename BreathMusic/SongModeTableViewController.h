//
//  SongModeTableViewController.h
//  BreathMusic
//
//  Created by barry on 08/09/2014.
//  Copyright (c) 2014 rocudo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SongModeTableViewController;

@protocol SongModeTableViewProtocol <NSObject>

-(void)songSelected:(NSDictionary*)dict;
-(void)stopEngine;

@end
@interface SongModeTableViewController : UITableViewController
@property(nonatomic,unsafe_unretained)id<SongModeTableViewProtocol>delegate;

-(void)toggle;
@end
