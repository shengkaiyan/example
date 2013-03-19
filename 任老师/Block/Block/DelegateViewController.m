//
//  DelegateViewController.m
//  Block
//
//  Created by Sky on 12-12-22.
//  Copyright (c) 2012年 Sky. All rights reserved.
//

#import "DelegateViewController.h"

@interface DelegateViewController ()

@end

@implementation DelegateViewController
@synthesize delegate = _delegate;
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _arrayEmailAddress = [[NSMutableArray alloc] initWithCapacity: self.arrayEmailSuffix.count];
}

- (void)UpdateData
{
	[_arrayEmailAddress removeAllObjects];
	for (NSString *emailSuffix in self.arrayEmailSuffix) {
        [_arrayEmailAddress addObject: [NSString stringWithFormat: @"%@%@", self.emailPrefix, emailSuffix]];
	}
    
	[self.tableView reloadData];
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
    
    // 判断是否实现了委托方法 @required方法,编译器会帮助检查
    if (self.delegate && [self.delegate respondsToSelector: @selector(passSelectMailAddress:)])
    {
		[self.delegate passSelectMailAddress: selectedString];
	}
}

// delete email suffix.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *) indexPath
{
    NSString *deleteString = [self.arrayEmailSuffix objectAtIndex: indexPath.row];
    [_arrayEmailAddress removeObjectAtIndex: indexPath.row];
    [self.arrayEmailSuffix removeObjectAtIndex: indexPath.row];
    
    [tableView reloadData];
    
    // 判断是否实现了委托方法 @optional方法,如果没有实现,而被调用了,就调用了一个空的方法,会crash.
    if (self.delegate && [self.delegate respondsToSelector: @selector(passDeleteMailAddress:)])
    {
		[self.delegate passDeleteMailAddress: deleteString];
	}
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    return UITableViewCellEditingStyleDelete;
}

@end
