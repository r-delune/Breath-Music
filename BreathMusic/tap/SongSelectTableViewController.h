//
//  SongSelectTableViewController.h
//  BreathMusic
//
//  Created by barry on 08/09/2014.
//  Copyright (c) 2014 rocudo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SongSelectTableViewController;

@protocol SongSelectProtocol <NSObject>

-(void)songSelected:(NSString*)song;

@end

@interface SongSelectTableViewController : UITableViewController
@property(nonatomic,unsafe_unretained)id<SongSelectProtocol>delegate;
-(void)toggle;
@end
