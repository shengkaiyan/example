//
//  SmsViewController.h
//  iSMS
//
//  Created by Sky on 13-2-27.
//  Copyright (c) 2013年 Sky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>
#import "Flurry.h"

@interface SmsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, MFMessageComposeViewControllerDelegate, UIAlertViewDelegate>
{
    ABAddressBookRef addressBook;
}

@property (strong, nonatomic) NSMutableArray *arrayContact;
@property (strong, nonatomic) NSMutableArray *arraySelect;
@property (nonatomic, strong) UITableView *aTableView;

@end
