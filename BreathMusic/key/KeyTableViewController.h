//
//  KeyTableViewController.h
//  BreathMusic
//
//  Created by barry on 05/09/2014.
//  Copyright (c) 2014 rocudo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KeyTableViewController;

@protocol KeyTableViewProtocol <NSObject>

-(void)keySelected:(NSString*)key;

@end

@interface KeyTableViewController : UITableViewController
@property(nonatomic,unsafe_unretained)id<KeyTableViewProtocol>delegate;
-(NSString*)toggleKey;
@end
