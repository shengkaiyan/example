//
//  DBViewController.h
//  Database
//
//  Created by Sky on 13-4-9.
//  Copyright (c) 2013年 Sky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DB.h"

@interface DBViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    UITableView *atableview;
    UITextView *tvSqlContent;
    
    NSMutableArray *arraySqlResult;
    
    DB *db;
}

@end
