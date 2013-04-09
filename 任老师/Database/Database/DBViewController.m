//
//  DBViewController.m
//  Database
//
//  Created by Sky on 13-4-9.
//  Copyright (c) 2013年 Sky. All rights reserved.
//

#import "DBViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DBCell.h"

@interface DBViewController ()

@end

@implementation DBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    db = [[DB alloc] init];

    self.view.backgroundColor = [UIColor whiteColor];
    
    tvSqlContent = [[UITextView alloc] initWithFrame: CGRectMake(1, 1, 240, 120)];
    [tvSqlContent.layer setBorderColor: [[self colorFromHexString: @"bfbfbf"] CGColor]];
    [tvSqlContent.layer setBorderWidth: 1];
    [tvSqlContent.layer setCornerRadius: 4];
    [tvSqlContent.layer setMasksToBounds:YES];
    tvSqlContent.textColor = [UIColor blueColor];
    tvSqlContent.autocapitalizationType = UITextAutocapitalizationTypeNone;
    tvSqlContent.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.view addSubview: tvSqlContent];
    
    UIButton *btnDone = [UIButton buttonWithType: UIButtonTypeRoundedRect];  // UIButtonTypeCustom
    [btnDone setTitle: @"Done" forState: UIControlStateNormal];
    [btnDone setFrame: CGRectMake(245, tvSqlContent.frame.size.height - 110, 70, 30)];
    [btnDone addTarget: self action: @selector(Done) forControlEvents: UIControlEventTouchUpInside];
    [btnDone setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
    [self.view addSubview: btnDone];
    
    UIButton *btnClear = [UIButton buttonWithType: UIButtonTypeRoundedRect];  // UIButtonTypeCustom
    [btnClear setTitle: @"Clear" forState: UIControlStateNormal];
    [btnClear setFrame: CGRectMake(245, tvSqlContent.frame.size.height - 70, 70, 30)];
    [btnClear addTarget: self action: @selector(Clear) forControlEvents: UIControlEventTouchUpInside];
    [btnClear setTitleColor: [UIColor redColor] forState: UIControlStateNormal];
    [self.view addSubview: btnClear];
    
    UIButton *btnExecute = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [btnExecute setTitle: @"Execute" forState: UIControlStateNormal];
    [btnExecute setFrame: CGRectMake(245, tvSqlContent.frame.size.height - 30, 70, 30)];
    [btnExecute addTarget: self action: @selector(Execute) forControlEvents: UIControlEventTouchUpInside];
    [btnExecute setTitleColor: [UIColor blueColor] forState: UIControlStateNormal];
    [self.view addSubview: btnExecute];
    
    atableview = [[UITableView alloc] initWithFrame: CGRectMake(0, tvSqlContent.frame.size.height+2, 320, self.view.frame.size.height-tvSqlContent.frame.size.height-2) style: UITableViewStylePlain];
    atableview.delegate = self;
    atableview.dataSource = self;
    [self.view addSubview: atableview];
    
    arraySqlResult = [[NSMutableArray alloc] initWithCapacity: 0];
    
    if (![db getDatabase])
    {
        [arraySqlResult addObject: @"Database load failed."];
    }
}

- (void)Done
{
    [tvSqlContent resignFirstResponder];
}

- (void)Clear
{
    tvSqlContent.text = @"";
}

- (void)Execute
{
    NSString *strSql = [tvSqlContent.text lowercaseString];
    if (strSql.length <= 0) {
        return;
    }
    
    [arraySqlResult removeAllObjects];
    
    // table operation
    if ([strSql hasPrefix: @"select"]) {
        NSArray *arrtemp = [db selectSql: strSql];
        
        if (0 == arrtemp.count) {
            [arraySqlResult addObject: @"Select is failed."];
        }
        else
        {
            for (NSDictionary *dict in arrtemp) {
                [arraySqlResult addObject: [self DeleteSpace: [dict description]]];
            }
        }
    }
    else if ([strSql hasPrefix: @"insert"]) {
        long result = [db insertSql: strSql];
        if (result>0) {
            [arraySqlResult addObject: [NSString stringWithFormat: @"Insert is Ok. id:%ld", result]];
        }
        else
        {
            [arraySqlResult addObject: @"Insert is failed."];
        }
    }
    else if ([strSql hasPrefix: @"update"]) {
        if ([db updateSql: strSql]) {
            [arraySqlResult addObject: @"Update is Ok."];
        }
        else
        {
            [arraySqlResult addObject: @"Update is failed."];
        }
    }
    else if ([strSql hasPrefix: @"delete"]) {
        if ([db deleteSql: strSql]) {
            [arraySqlResult addObject: @"Delete is Ok."];
        }
        else
        {
            [arraySqlResult addObject: @"Delete is failed."];
        }
    }
    // database operation
    else if ([strSql hasPrefix: @"create"]) {
        if ([[db getDatabase] DisposeTable: strSql]) {
            [arraySqlResult addObject: @"Create Table is OK."];
        }
        else
        {
            [arraySqlResult addObject: @"Create Table is failed."];
        }
    }
    
    [atableview reloadData];
}

- (NSString *)DeleteSpace:(NSString *)str
{
    NSString *deleteSpace = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    deleteSpace = [deleteSpace stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    NSError *error = NULL;
    NSRegularExpression *regexSpace = [NSRegularExpression regularExpressionWithPattern: @"   "
                                                                                options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators //这个是为了匹配多行
                                                                                  error:&error];
    
    NSRegularExpression *regexNewline = [NSRegularExpression regularExpressionWithPattern: @"\n"
                                                                                  options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators //这个是为了匹配多行
                                                                                    error:&error];
    
    
    while (YES) {
        NSTextCheckingResult *tmpResultSpace = [regexSpace firstMatchInString:deleteSpace options:0 range:NSMakeRange(0, [deleteSpace length])];
        NSTextCheckingResult *tmpResultNewline = [regexNewline firstMatchInString:deleteSpace options:0 range:NSMakeRange(0, [deleteSpace length])];
        
        if (!tmpResultSpace && !tmpResultNewline) {
            break;
        }
        
        deleteSpace = [deleteSpace stringByReplacingOccurrencesOfString: @"   " withString: @" "];
        deleteSpace = [deleteSpace stringByReplacingOccurrencesOfString: @"\n" withString: @" "];
    }
    
    return deleteSpace;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arraySqlResult.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DBCell";
    
    DBCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier];
    if (!cell) {
        cell = [DBCell cell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.lbValue.text = [arraySqlResult objectAtIndex: indexPath.row];
    
    CGFloat contentWidth = 300;
    
    // 计算出内容的高宽
    CGFloat height = [self neededHeightForDescription: [arraySqlResult objectAtIndex: indexPath.row] withTableWidth: contentWidth Font: [UIFont systemFontOfSize: 15] LineBreakMode: UILineBreakModeWordWrap];
    
    if (height<44) {
        height = 44.0;
    }

    cell.lbValue.frame = CGRectMake(10, 0, 300, height);

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat contentWidth = 300;

    // 计算出内容的高宽
    CGFloat height = [self neededHeightForDescription: [arraySqlResult objectAtIndex: indexPath.row] withTableWidth: contentWidth Font: [UIFont systemFontOfSize: 15] LineBreakMode: UILineBreakModeWordWrap];
    
    if (height<44) {
        height = 44.0;
    }
    
    return height;
}

#pragma TOOL ----
- (CGFloat)neededHeightForDescription:(NSString *)description withTableWidth:(NSUInteger)tableWidth Font:(UIFont *)font LineBreakMode:(UILineBreakMode)lineBreakMode
{
	CGSize labelSize = [description sizeWithFont: font constrainedToSize:CGSizeMake(tableWidth, MAXFLOAT) lineBreakMode: lineBreakMode];
    
	return labelSize.height;
}

- (UIColor*)colorFromHexString:(NSString *)hexString{
	NSString *cleanString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
	if([cleanString length] == 3) {
		cleanString = [NSString stringWithFormat:@"%@%@%@%@%@%@",
					   [cleanString substringWithRange:NSMakeRange(0, 1)],[cleanString substringWithRange:NSMakeRange(0, 1)],
					   [cleanString substringWithRange:NSMakeRange(1, 1)],[cleanString substringWithRange:NSMakeRange(1, 1)],
					   [cleanString substringWithRange:NSMakeRange(2, 1)],[cleanString substringWithRange:NSMakeRange(2, 1)]];
	}
	if([cleanString length] == 6) {
		cleanString = [cleanString stringByAppendingString:@"ff"];
	}
	
	unsigned int baseValue;
	[[NSScanner scannerWithString:cleanString] scanHexInt:&baseValue];
	
	float red = ((baseValue >> 24) & 0xFF)/255.0f;
	float green = ((baseValue >> 16) & 0xFF)/255.0f;
	float blue = ((baseValue >> 8) & 0xFF)/255.0f;
	float alpha = ((baseValue >> 0) & 0xFF)/255.0f;
	
	return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
