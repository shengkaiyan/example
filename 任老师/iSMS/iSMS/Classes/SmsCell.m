//
//  SmsCell.m
//  iSMS
//
//  Created by Sky on 13-2-27.
//  Copyright (c) 2013年 Sky. All rights reserved.
//

#import "SmsCell.h"

@implementation SmsCell
@synthesize lbLabel;
@synthesize imgViewSelected;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.imgViewSelected = [[UIImageView alloc] initWithFrame: CGRectMake(25, 7, 30, 30)];
        [self addSubview: self.imgViewSelected];
        
        self.lbLabel = [[UILabel alloc] initWithFrame: CGRectMake(40, 5, 200, 30)];
        self.lbLabel.backgroundColor = [UIColor clearColor];
        [self addSubview: self.lbLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
