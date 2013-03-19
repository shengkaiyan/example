//
//  SmsViewController.m
//  iSMS
//
//  Created by Sky on 13-2-27.
//  Copyright (c) 2013年 Sky. All rights reserved.
//

#import "SmsViewController.h"
#import "SmsCell.h"
#import "pinyin.h"
#import "AppDelegate.h"

@interface SmsViewController ()

@end

@implementation SmsViewController
@synthesize aTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#define LEFT_NAV_BUTTON_FRAME                       CGRectMake(10, 0, 100, 44)
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIButton *btnBack = [UIButton buttonWithType: UIButtonTypeCustom];
    [btnBack setFrame: LEFT_NAV_BUTTON_FRAME];
    [btnBack setBackgroundColor:[UIColor clearColor]];
    [btnBack setBackgroundImage:[UIImage imageNamed:@"ad.png"] forState:UIControlStateNormal];
    [btnBack addTarget:self action:@selector(TapLeftButton) forControlEvents:UIControlEventTouchDown];
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithCustomView:btnBack];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle: @"send" style: UIBarButtonItemStyleDone target: self action: @selector(SendSms)];
    self.navigationItem.rightBarButtonItem = buttonItem;
    
    aTableView = [[UITableView alloc] initWithFrame: CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height-44) style: UITableViewStylePlain];
    aTableView.delegate = self;
    aTableView.dataSource = self;
    [self.view addSubview: aTableView];
    
    [self InitAddressBook];
    [self InitContact];
    
    self.arraySelect = [[NSMutableArray alloc] init];
}

#pragma mark -  UIAlertViewDelegate Protocol
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==1){
        MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
        picker.messageComposeDelegate = self;
        
        [self.navigationController presentModalViewController: picker animated: YES];
    }
}

- (void)TapLeftButton
{
    NSDictionary *flurryDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"appAd", @"jiebanyou", nil];
    [Flurry logEvent:@"Event_Call" withParameters: flurryDictionary timed:YES];
    
    NSURL *url = [[NSURL alloc] initWithString: @"https://itunes.apple.com/us/app/jie-ban-you/id607998928?ls=1&mt=8"];
    [[UIApplication sharedApplication] openURL: url];
}

- (void)SendSms
{
    if ([self.arraySelect count]) {
        MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
        picker.messageComposeDelegate = self;
        
        NSMutableArray *arrayNumber = [[NSMutableArray alloc] initWithCapacity: self.arraySelect.count];
        for (NSDictionary *dict in self.arraySelect) {
            [arrayNumber addObject: [dict objectForKey: @"value"]];
        }
        
        picker.recipients = arrayNumber;
        
        [self.navigationController presentModalViewController: picker animated:YES];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"我自己手动输入手机号码."
                                                            message: nil
                                                           delegate: self
                                                  cancelButtonTitle: @"取消"
                                                  otherButtonTitles: @"确定", nil];
        [alertView show];
    }
}

#pragma mark MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
    
    [controller dismissModalViewControllerAnimated:NO];
    switch (result)
    {
        case MessageComposeResultCancelled:
            //debug_NSLog(@"Result: SMS sending canceled");
            break;
        case MessageComposeResultSent:
        {
            [self ShowAlertView: @"短信发送成功！"];
            
            break;
        }
        case MessageComposeResultFailed:
        {
            [self ShowAlertView: @"短信发送失败！"];
            
            break;
        }
        default:
            //debug_NSLog(@"Result: SMS not sent");
            break;
    }
    [self dismissModalViewControllerAnimated:YES];
}

- (void)ShowAlertView:(NSString *)title
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: title
                                                        message: nil
                                                       delegate: nil
                                              cancelButtonTitle: nil
                                              otherButtonTitles: NSLocalizedString(@"确认",@""), nil];
    [alertView show];
}

- (void)InitAddressBook
{
    addressBook = nil;
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0)
    {
        addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        //等待同意后向下执行
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error)
                                                 {
                                                     dispatch_semaphore_signal(sema);
                                                 });
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        dispatch_release(sema);
    }
    else
    {
        addressBook = ABAddressBookCreate();
    }
}

- (NSString *) filterOutSymbol: (NSString *) resouse
						Filter: (NSString *) filter
{
	NSString *result = nil;
	NSCharacterSet *cs = [NSCharacterSet  characterSetWithCharactersInString: filter]; // filter out . -()
	NSArray *split = [resouse componentsSeparatedByCharactersInSet:cs];
	result = [split componentsJoinedByString:@""];
	
	return result;
}

- (void)InitContact
{
    if (!addressBook) {
        return;
    }
    
    NSLog(@"begin InitContact");
    NSArray *persons = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex personCount = CFArrayGetCount(CFBridgingRetain(persons));
    
    self.arrayContact = [[NSMutableArray alloc] initWithCapacity: personCount];
    
    for (int i = 0; i < 27; i++) [self.arrayContact addObject: [[NSMutableArray alloc] init]];
	
	for (CFIndex personIndex = 0; personIndex < personCount; personIndex++)
	{
		ABRecordRef         person = CFArrayGetValueAtIndex(CFBridgingRetain(persons), personIndex);
		CFTypeRef phoneValue = ABRecordCopyValue(person, kABPersonPhoneProperty);
		int phoneCount = ABMultiValueGetCount(phoneValue);
		
		if (0 == phoneCount) {
			if (phoneValue) {
				CFRelease(phoneValue);
			}
			continue;
		}
        
        ABRecordID recordId = ABRecordGetRecordID(person);
		CFStringRef name = ABRecordCopyCompositeName(person);
		NSString *sysId = [[NSString alloc] initWithFormat: @"%d", (int)recordId];
		NSString *key = nil;
		NSString *strName = nil;
		
		if (name && [(__bridge NSString*)name length]>0) {
			strName = [[NSString alloc] initWithString: (__bridge NSString*)name];
			
			NSString *strFirstLetter = [[NSString alloc] initWithString: [(__bridge NSString*)name substringToIndex: 1]];
			if ([strFirstLetter length] > 0)
				key = [[[NSString alloc] initWithFormat:@"%c",pinyinFirstLetter([strFirstLetter characterAtIndex:0])] uppercaseString];
		}
		else {
			strName = @"No Name";
			
			key = @"#";
		}
        
		NSUInteger firstLetter = [ALPHA rangeOfString:key].location;
		if (firstLetter != NSNotFound) {
			NSMutableDictionary *rowData = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                            key, @"key",
                                            @"name", @"type",
                                            strName, @"value",
											//  @"0", @"selected",
                                            sysId, @"sysId",
                                            nil];
			
			[[self.arrayContact objectAtIndex:firstLetter] addObject: rowData];
		}
        
		for (CFIndex phoneIndex = 0; phoneIndex < phoneCount; phoneIndex++)
		{
			CFTypeRef phoneNumber = ABMultiValueCopyValueAtIndex(phoneValue, phoneIndex);
			NSString *niceStr =  [self filterOutSymbol: (__bridge NSString *)phoneNumber Filter:@"+*#-.,() "];
			
			if (firstLetter != NSNotFound) {
				NSMutableDictionary *rowData = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
												key, @"key",
												@"number", @"type",
												strName, @"name",
												niceStr, @"value",
												@"0", @"selected",
												sysId, @"sysId",
												nil];
				
				[[self.arrayContact objectAtIndex:firstLetter] addObject: rowData];
			}
			
			CFRelease(phoneNumber);
		}
		
		if (name) {
			CFRelease(name);
		}
		
		if (phoneValue) {
			CFRelease(phoneValue);
		}
    }
    
    for (NSArray *arr in self.arrayContact) {
        for (NSDictionary *dict in arr) {
            NSLog(@"%@", dict);
        }
    }
    
    NSLog(@"end InitContact");
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 27;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[self.arrayContact objectAtIndex:section] count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    SmsCell *cell = (SmsCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SmsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
	
	NSMutableDictionary *dictValue = [[self.arrayContact objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if ([[dictValue objectForKey: @"type"] isEqualToString: @"name"]) {
		cell.lbLabel.frame = CGRectMake(80, 5, 200, 30);
		cell.lbLabel.font = [UIFont boldSystemFontOfSize: 18];
//		cell.imgViewSelected.hidden = YES;
        
        ABRecordRef recordRef = ABAddressBookGetPersonWithRecordID(addressBook, [[dictValue objectForKey: @"sysId"] intValue]);
        
        NSData *imageData = nil;
        if (recordRef) {
            imageData = (__bridge NSData *)ABPersonCopyImageDataWithFormat(recordRef, kABPersonImageFormatThumbnail);
        }
        
        if (imageData) {
            cell.imgViewSelected.image = [UIImage imageWithData:imageData];
        }
        else {
            cell.imgViewSelected.image = [UIImage imageNamed:@"avatar_thumbnail.png"];
        }
	}
	else {
		cell.lbLabel.frame = CGRectMake(80, 5, 200, 30);
		cell.lbLabel.font = [UIFont systemFontOfSize: 16];
		cell.imgViewSelected.hidden = NO;
		
		if ([[dictValue objectForKey: @"selected"] boolValue]) {
			cell.imgViewSelected.image = [UIImage imageNamed:@"checkbox_selectedTag.png"];
		}
		else {
			cell.imgViewSelected.image = [UIImage imageNamed:@"checkbox_unselectedTag.png"];
		}
	}
	
	cell.lbLabel.text = [dictValue objectForKey: @"value"];
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{ 		
    return 40; 
}

// an array which has values for index - like A,B,C etc.
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
	NSMutableArray *indices = [NSMutableArray arrayWithObject:UITableViewIndexSearch];
	for (int i = 0; i < 27; i++) {
		if ([[self.arrayContact objectAtIndex:i] count]){
			[indices addObject:[[ALPHA substringFromIndex:i] substringToIndex:1]];
		}
	}
    //[indices addObject:@"\ue057"]; // <-- using emoji
	return indices;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	return [ALPHA rangeOfString:title].location;
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
	if ([[self.arrayContact objectAtIndex:section] count] == 0)
	{
		return nil;
	}
	
	return [NSString stringWithFormat:@"%@", [[ALPHA substringFromIndex:section] substringToIndex:1]];
}

#pragma mark -
#pragma mark Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	
	NSMutableDictionary *dictValue = [[self.arrayContact objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	if ([[dictValue objectForKey: @"type"] isEqualToString: @"number"]) {
		if ([[dictValue objectForKey: @"selected"] boolValue]) {
			[self.arraySelect removeObject:dictValue];
			[dictValue setObject: @"0" forKey:@"selected"];
		}
		else {
			[dictValue setObject: @"1" forKey:@"selected"];
            [self.arraySelect addObject:dictValue];
		}
		
		[tableView reloadData];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
