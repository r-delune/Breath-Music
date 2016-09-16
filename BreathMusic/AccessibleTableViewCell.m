//
//  AccessibleTableViewCell.m
//  BreathMusic
//
//  Created by barry on 09/09/2014.
//  Copyright (c) 2014 rocudo. All rights reserved.
//

#import "AccessibleTableViewCell.h"
@interface AccessibleTableViewCell()

@property(nonatomic,strong) UIButton  *button;

@end;
@implementation AccessibleTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.isAccessibilityElement=YES;
        
        self.button =[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 30)];
        [self.contentView addSubview:self.button];
        [self.button setTitle:@"BLAHHH" forState:UIControlStateNormal];

    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
  
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (NSInteger)accessibilityElementCount {
    return 1;
}

- (id)accessibilityElementAtIndex:(NSInteger)index {
    if (index == 0) {
        return self.button;
    }    return nil;
}

- (NSInteger)indexOfAccessibilityElement:(id)element {
    if (element == self.button) {
        return 0;
    }
    return 0;
}
@end
