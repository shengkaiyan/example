//
//  ViewController.h
//  Block
//
//  Created by Sky on 12-12-22.
//  Copyright (c) 2012年 Sky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DelegateViewController.h"
#import "BlockViewController.h"

@interface ViewController : UIViewController<UITextFieldDelegate, PassValueDelegate, UIAlertViewDelegate>
{
    NSString *strEmailAddressSuffixFile;
    NSMutableArray *arrayEmailAddressSuffix;
    
    UITextField *tfDelegate;
    UITextField *tfBlock;
    
    DelegateViewController *delegateViewController;
    BlockViewController *blockViewController;
}

@end
