//
//  ScaleTableViewController.h
//  BreathMusic
//
//  Created by barry on 02/10/2014.
//  Copyright (c) 2014 rocudo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ScaleTableViewProtocol <NSObject>

-(void)scaleSelected:(NSDictionary*)scale;

@end
@interface ScaleTableViewController : UITableViewController
@property(nonatomic,unsafe_unretained)id<ScaleTableViewProtocol>delegate;
@end
