//
//  DBCell.h
//  Database
//
//  Created by Sky on 13-4-9.
//  Copyright (c) 2013年 Sky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBCell : UITableViewCell
{
    UILabel        *lbValue;
}

+ (id)cell;

@property (retain, nonatomic) UILabel        *lbValue;

@end
