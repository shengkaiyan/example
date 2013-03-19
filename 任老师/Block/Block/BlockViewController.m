//
//  BlockViewController.m
//  Block
//
//  Created by Sky on 12-12-22.
//  Copyright (c) 2012年 Sky. All rights reserved.
//

#import "BlockViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface BlockViewController ()

@end

@implementation BlockViewController
@synthesize arrayEmailSuffix = _arrayEmailSuffix;
@synthesize emailPrefix = _emailPrefix;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView.layer setBorderColor: [[UIColor grayColor] CGColor]];
    [self.tableView.layer setBorderWidth: 2];
    [self.tableView.layer setCornerRadius: 8];
    [self.tableView.layer setMasksToBounds:YES];
    
    _arrayEmailAddress = [[NSMutableArray alloc] initWithCapacity: self.arrayEmailSuffix.count];
}

-(void)setSelectCellBlock:(SelectCellBlock)block
{
    selectCellBlock = block;
}

-(void)setDeleteCellBlock:(DeleteCellBlock)block
{
    deleteCellBlock = block;
}

- (int)UpdateData
{
	[_arrayEmailAddress removeAllObjects];
    
    NSRange range = [_emailPrefix rangeOfString: @"@"];
    if (range.location != NSNotFound)  // 用户自已输入域名,隐藏
    {
        NSString *mySuffix = [_emailPrefix substringFromIndex: range.location+1];
        NSString *myPrefix = [_emailPrefix substringToIndex: range.location];
        
        if (mySuffix.length)  // @后有内容了
        {
//            NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS %@", mySuffix];
            mySuffix = [NSString stringWithFormat: @"@%@*", mySuffix];
            NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"SELF like[cd] %@", mySuffix];
            
            NSArray *filterArray = [self.arrayEmailSuffix filteredArrayUsingPredicate: filterPredicate];
            NSLog(@"Filtered array with filter %@ %@", mySuffix, filterArray);
            
            for (NSString *emailSuffix in filterArray) {
                [_arrayEmailAddress addObject: [NSString stringWithFormat: @"%@%@", myPrefix, emailSuffix]];
            }
        }
        else
        {
            for (NSString *emailSuffix in self.arrayEmailSuffix) {
                [_arrayEmailAddress addObject: [NSString stringWithFormat: @"%@%@", myPrefix, emailSuffix]];
            }
        }
    }
    else
    {
        for (NSString *emailSuffix in self.arrayEmailSuffix) {
            [_arrayEmailAddress addObject: [NSString stringWithFormat: @"%@%@", self.emailPrefix, emailSuffix]];
        }
    }

	[self.tableView reloadData];
    
    return _arrayEmailAddress.count;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _arrayEmailAddress.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
	NSUInteger row = [indexPath row];
	cell.textLabel.text = [_arrayEmailAddress objectAtIndex:row];
    
    return cell;
}

// 控制 cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 48;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    
    NSString *selectedString = [_arrayEmailAddress objectAtIndex: [indexPath row]];
    
    // 判断是否指定了block方法
    if (selectCellBlock)
    {
		selectCellBlock(selectedString);
	}
}

// delete email suffix.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *) indexPath
{
    NSString *deleteString = [self.arrayEmailSuffix objectAtIndex: indexPath.row];
    [_arrayEmailAddress removeObjectAtIndex: indexPath.row];
    [self.arrayEmailSuffix removeObjectAtIndex: indexPath.row];
    
    [tableView reloadData];
    
    // 判断是否指定了block方法
    if (deleteCellBlock)
    {
		deleteCellBlock(deleteString);
	}
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

@end
