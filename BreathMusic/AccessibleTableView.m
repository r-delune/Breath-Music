//
//  AccessibleTableView.m
//  BreathMusic
//
//  Created by barry on 09/09/2014.
//  Copyright (c) 2014 rocudo. All rights reserved.
//

#import "AccessibleTableView.h"

@implementation AccessibleTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(BOOL)isAccessibilityElement {
    return YES;
}

- (NSInteger)accessibilityElementCount {
    return 7;
}


- (NSString *)accessibilityLabel {
    return nil;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
