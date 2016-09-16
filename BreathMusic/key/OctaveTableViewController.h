//
//  OctaveTableViewController.h
//  BreathMusic
//
//  Created by barry on 09/09/2014.
//  Copyright (c) 2014 rocudo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class OctaveTableViewController;

@protocol OctaveTableViewProtocol <NSObject>

-(void)ocatveSelected:(NSNumber*)octave;

@end
@interface OctaveTableViewController : UITableViewController
@property(nonatomic,unsafe_unretained)id<OctaveTableViewProtocol>delegate;
@end
