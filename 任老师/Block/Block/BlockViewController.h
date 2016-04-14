//
//  BlockViewController.h
//  Block
//
//  Created by Sky on 12-12-22.
//  Copyright (c) 2012年 Sky. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^SelectCellBlock)(NSString *selectedString);
typedef void (^DeleteCellBlock)(NSString *deletedString);

@interface BlockViewController : UITableViewController
{
    SelectCellBlock selectCellBlock;
    DeleteCellBlock deleteCellBlock;
    
    NSMutableArray *_arrayEmailSuffix;
    NSString *_emailPrefix;
    
    NSMutableArray *_arrayEmailAddress;
}

@property (nonatomic, strong) NSMutableArray *arrayEmailSuffix;
@property (nonatomic, strong) NSString *emailPrefix;

- (int)UpdateData;

- (int)UpdateDat2;

- (int)UpdateDat3;

-(void)setSelectCellBlock:(SelectCellBlock)block;
-(void)setDeleteCellBlock:(DeleteCellBlock)block;

@end
