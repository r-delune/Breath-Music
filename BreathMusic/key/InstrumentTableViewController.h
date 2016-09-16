//
//  InstrumentTableViewController.h
//  BreathMusic
//
//  Created by barry on 05/09/2014.
//  Copyright (c) 2014 rocudo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class InstrumentTableViewController;

@protocol InstrumentTableViewProtocol <NSObject>

-(void)instrumentSelected:(NSDictionary*)instrument;

@end
@interface InstrumentTableViewController : UITableViewController
@property(nonatomic,unsafe_unretained)id<InstrumentTableViewProtocol>delegate;
-(NSDictionary*)toggle;
@end
