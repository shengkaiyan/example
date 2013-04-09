//
//  DBCell.m
//  Database
//
//  Created by Sky on 13-4-9.
//  Copyright (c) 2013年 Sky. All rights reserved.
//

#import "DBCell.h"

@implementation DBCell

+ (id)cell
{
	DBCell *cell = [[DBCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"DBCell"];
    //	[[cell textLabel] setTextAlignment:UITextAlignmentLeft];
    //	[[cell textLabel] setFont:[UIFont systemFontOfSize:18]];
    //	[[cell textLabel] setLineBreakMode:UILineBreakModeMiddleTruncation];
    
    
    [cell setLbValue: [[UILabel alloc] init]];
    cell.lbValue.backgroundColor = [UIColor clearColor];
    cell.lbValue.numberOfLines = 0;
    [cell.contentView addSubview: [cell lbValue]];
    
	return cell;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
}


@synthesize lbValue;

@end
