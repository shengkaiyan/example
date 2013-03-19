//
//  ViewController.m
//  Block
//
//  Created by Sky on 12-12-22.
//  Copyright (c) 2012年 Sky. All rights reserved.
//

#import "ViewController.h"

#define DOCUMENTDIRECTORY  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0]

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // init email address suffix
    strEmailAddressSuffixFile = [[ NSString alloc] initWithString: [DOCUMENTDIRECTORY stringByAppendingPathComponent: @"DefaultEmailAddress.plist"]];

	if ([[NSFileManager defaultManager] fileExistsAtPath: strEmailAddressSuffixFile])
	{
		arrayEmailAddressSuffix = [[NSMutableArray alloc] initWithContentsOfFile:strEmailAddressSuffixFile];
	}
	else {
		NSString *mainBundleFile = [[NSString alloc] initWithString: [[NSBundle mainBundle] pathForResource:@"DefaultEmailAddress" ofType:@"plist"]];
		
		arrayEmailAddressSuffix = [[NSMutableArray alloc] initWithContentsOfFile: mainBundleFile];
        
        [arrayEmailAddressSuffix writeToFile: strEmailAddressSuffixFile atomically: YES];
	}
    
    // init UI
    tfDelegate = [[UITextField alloc] initWithFrame: CGRectMake(20, 10, 280, 30)];
    tfDelegate.borderStyle = UITextBorderStyleRoundedRect;
    tfDelegate.delegate = self;
    tfDelegate.returnKeyType = UIReturnKeyDone;
    tfDelegate.keyboardType = UIKeyboardTypeEmailAddress;
    tfDelegate.clearButtonMode = UITextFieldViewModeWhileEditing;
    tfDelegate.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.view addSubview: tfDelegate];
    
    tfBlock = [[UITextField alloc] initWithFrame: CGRectMake(20, 70, 280, 30)];
    tfBlock.borderStyle = UITextBorderStyleRoundedRect;
    tfBlock.delegate = self;
    tfBlock.returnKeyType = UIReturnKeyDone;
    tfBlock.keyboardType = UIKeyboardTypeEmailAddress;
    tfBlock.clearButtonMode = UITextFieldViewModeWhileEditing;
    tfBlock.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.view addSubview: tfBlock];
    
    delegateViewController = [[DelegateViewController alloc] initWithStyle:UITableViewStylePlain];
    delegateViewController.delegate = self;
    delegateViewController.arrayEmailSuffix = arrayEmailAddressSuffix;
    [self.view addSubview: delegateViewController.view];
    [delegateViewController.view setFrame:CGRectMake(20, 40, 280, 0)];
    
    
    blockViewController = [[BlockViewController alloc] initWithStyle:UITableViewStylePlain];
    blockViewController.arrayEmailSuffix = arrayEmailAddressSuffix;
    [self.view addSubview:blockViewController.view];
    [blockViewController.view setFrame:CGRectMake(20, 70, 280, 0)];
    
    __block UITextField *block_tfBlock = tfBlock;
    [blockViewController setSelectCellBlock:^(NSString *selectedString) {
        if (selectedString) {
            tfBlock.text = selectedString;
            
            // why get worning;
//            [tfBlock resignFirstResponder];
            
            [block_tfBlock resignFirstResponder];
        }
    }];
    
    __block ViewController *block_viewController = self;
    [blockViewController setDeleteCellBlock:^(NSString *deletedString) {
        if (deletedString) {
            [block_viewController DeleteEmailSuffix: deletedString];
        }
    }];
}

-(void)DeleteEmailSuffix:(NSString *)deletedString
{
    UIAlertView *myalert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                      message: [NSString stringWithFormat: @"是否永久删除此邮箱后缀:%@", deletedString]
                                                     delegate: self
                                            cancelButtonTitle: @"取消"
                                            otherButtonTitles:@"确认",nil];
    myalert.tag = 100;
    [myalert show];
}

#pragma mark - UIAlertViewDelegate delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (100 == alertView.tag) {
        if (buttonIndex == 1)
        {
            BOOL isWrited = [arrayEmailAddressSuffix writeToFile: strEmailAddressSuffixFile atomically: YES];
            
            NSLog(@"arrayEmailAddressSuffix:%@\nisWrited:%d", arrayEmailAddressSuffix, isWrited);
        }
    }
}

#pragma mark - PassValueDelegate delegate
// @required
-(void)passSelectMailAddress:(NSString *)selectMail
{
    tfDelegate.text = selectMail;
    [tfDelegate resignFirstResponder];
}

// @optional 
-(void)passDeleteMailAddress:(NSString *)deleteMail
{
    [self DeleteEmailSuffix: deleteMail];
}

- (void)setViewControllerHidden:(UIViewController *)viewController Hidden:(BOOL)hidden {
    if ([viewController isKindOfClass: [DelegateViewController class]]) {
        NSInteger height = hidden ? 0 : 192;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:.2];
        [viewController.view setFrame:CGRectMake(20, 40, 280, height)];
        [UIView commitAnimations];
    }
    else
    {
        NSInteger height = hidden ? 0 : (192-48);
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:.2];
        [viewController.view setFrame:CGRectMake(20, 100, 280, height)];
        [UIView commitAnimations];
    }
}

#pragma mark - UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == tfDelegate) {
        [self setViewControllerHidden: delegateViewController Hidden: YES];
    }
    else
    {
        [self setViewControllerHidden: blockViewController Hidden: YES];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSLog(@"%@    %@",textField.text, string);
    
    if (textField == tfDelegate) {
        if (0 == range.length) {
            delegateViewController.emailPrefix = [NSString stringWithFormat:@"%@%@", textField.text, string];
        }
        else
        {
            delegateViewController.emailPrefix = [textField.text substringToIndex: range.location];
        }
        
        if ([delegateViewController.emailPrefix length]) {
            NSRange range = [delegateViewController.emailPrefix rangeOfString: @"@"];
            if (range.location == NSNotFound)  // 用户自已输入域名,隐藏
            {
                [self setViewControllerHidden: delegateViewController Hidden: NO];
                [delegateViewController UpdateData];
            }
            else
            {
                [self setViewControllerHidden: delegateViewController Hidden: YES];
            }
        }
        else
        {
            [self setViewControllerHidden: delegateViewController Hidden: YES];
        }
    }
    else
    {
        if (0 == range.length) {
            blockViewController.emailPrefix = [NSString stringWithFormat:@"%@%@", textField.text, string];
        }
        else
        {
            blockViewController.emailPrefix = [textField.text substringToIndex: range.location];
        }
        
        if ([blockViewController.emailPrefix length]) {
            int addressCount = [blockViewController UpdateData];
            if (addressCount) {
                [self setViewControllerHidden: blockViewController Hidden: NO];
            }
            else
            {
                [self setViewControllerHidden: blockViewController Hidden: YES];
            }
            
//            NSRange range = [blockViewController.emailPrefix rangeOfString: @"@"];
//            if (range.location == NSNotFound)  // 用户自已输入域名,隐藏
//            {
//                [self setViewControllerHidden: blockViewController Hidden: NO];
//                [blockViewController UpdateData];
//            }
//            else
//            {
//                [self setViewControllerHidden: blockViewController Hidden: YES];
//            }
        }
        else
        {
            [self setViewControllerHidden: blockViewController Hidden: YES];
        }
    }
    
    return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
