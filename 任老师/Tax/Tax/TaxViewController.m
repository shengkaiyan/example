//
//  TaxViewController.m
//  Tax
//
//  Created by Sky on 13-3-3.
//  Copyright (c) 2013年 Sky. All rights reserved.
//

#import "TaxViewController.h"

#define MY_BANNER_UNIT_ID       @"a14e998ece389d3"

@interface TaxViewController ()

@end

InsuranceCity city[] = {
    //  热门城市
    {"北京",
        /*社保最低值, 最高值*/ 1869, 14016,
        /*公积金最低值, 最高值*/ 1400, 14016,
        /*公司部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.2, 0.1, 0.01, 0.003, 0.008, 0.12, 0.0,
        /*个人部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.08, 0.02, 0.002, 0.0, 0.0, 0.12, 0.0},
    {"上海",
        /*社保最低值, 最高值*/ 2599, 12993,
        /*公积金最低值, 最高值*/ 1280, 12993,
        /*公司部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.2, 0.12, 0.017, 0.005, 0.008, 0.07, 0.0,
        /*个人部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.08, 0.02, 0.01, 0.0, 0.0, 0.07, 0.0},
    {"广州",
        /*社保最低值, 最高值*/ 1300, 14367,
        /*公积金最低值, 最高值*/ 1300, 20505,
        /*公司部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.12, 0.08, 0.02, 0.005, 0.0085, 0.08, 0.0085,
        /*个人部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.08, 0.02, 0.01, 0.0, 0.0, 0.08, 0.0},
    {"南京",
        /*社保最低值, 最高值*/ 1973, 13678,
        /*公积金最低值, 最高值*/ 1140, 12200,
        /*公司部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.2, 0.09, 0.02, 0.005, 0.008, 0.1, 0.0,
        /*个人部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.08, 0.02, 0.01, 0.0, 0.0, 0.1, 0.0},
    {"杭州",
        /*社保最低值, 最高值*/ 1787, 8932,
        /*公积金最低值, 最高值*/ 1310, 13602,
        /*公司部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.14, 0.115, 0.02, 0.005, 0.012, 0.12, 0.0,
        /*个人部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.08, 0.02, 0.01, 0.0, 0.0, 0.12, 0.0},
    {"济南",
        /*社保最低值, 最高值*/ 1772, 8859,
        /*公积金最低值, 最高值*/ 0, 14562,
        /*公司部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.19, 0.09, 0.02, 0.005, 0.008, 0.08, 0.0,
        /*个人部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.08, 0.02, 0.01, 0.0, 0.0, 0.08, 0.0},
    {"郑州",
        /*社保最低值, 最高值*/ 1777.05, 8885.25,
        /*公积金最低值, 最高值*/ 1080, 8886,
        /*公司部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.2, 0.08, 0.02, 0.005, 0.01, 0.1, 0.0,
        /*个人部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.08, 0.02, 0.01, 0.0, 0.0, 0.1, 0.0},
    {"沈阳",
        /*社保最低值, 最高值*/ 2229, 11145,
        /*公积金最低值, 最高值*/ 1100, 11145,
        /*公司部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.19, 0.08, 0.02, 0.02, 0.008, 0.08, 0.0,
        /*个人部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.08, 0.02, 0.01, 0.0, 0.0, 0.08, 0.0},
    {"武汉",
        /*社保最低值, 最高值*/ 2282, 11411,
        /*公积金最低值, 最高值*/ 1100, 8106,
        /*公司部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.2, 0.08, 0.02, 0.005, 0.007, 0.08, 0.0,
        /*个人部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.08, 0.02, 0.01, 0.0, 0.0, 0.08, 0.0},
    {"成都",
        /*社保最低值, 最高值*/ 1700, 9481,
        /*公积金最低值, 最高值*/ 1050, 13284,
        /*公司部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.2, 0.075, 0.02, 0.006, 0.006, 0.07, 0.0,
        /*个人部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.08, 0.02, 0.01, 0.0, 0.0, 0.07, 0.0},
    //  其它城市
    {"长春",
        /*社保最低值, 最高值*/ 2073.6, 10368,
        /*公积金最低值, 最高值*/ 1000, 10368,
        /*公司部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.2, 0.07, 0.02, 0.005, 0.007, 0.07, 0.0,
        /*个人部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.08, 0.02, 0.01, 0.0, 0.0, 0.07, 0.0},
    {"重庆",
        /*社保最低值, 最高值*/ 1178, 20021,
        /*公积金最低值, 最高值*/ 0, 15486,
        /*公司部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.2, 0.09, 0.01, 0.006, 0.007, 0.07, 0.0,
        /*个人部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.08, 0.02, 0.02, 0.0, 0.0, 0.07, 0.0},
    {"东莞",
        /*社保最低值, 最高值*/ 2006, 10560,
        /*公积金最低值, 最高值*/ 1500, 20999,
        /*公司部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.1, 0.075, 0.015, 0.005, 0.005, 0.08, 0.0,
        /*个人部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.08, 0.02, 0.005, 0.0, 0.0, 0.08, 0.0},
    {"福州",
        /*社保最低值, 最高值*/ 1369, 10431,
        /*公积金最低值, 最高值*/ 0, 6845,
        /*公司部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.18, 0.08, 0.02, 0.005, 0.007, 0.08, 0.0,
        /*个人部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.08, 0.02, 0.01, 0.0, 0.0, 0.08, 0.0},
    {"哈尔滨",
        /*社保最低值, 最高值*/ 1276, 6381,
        /*公积金最低值, 最高值*/ 0, 6381,
        /*公司部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.22, 0.08, 0.01, 0.004, 0.005, 0.08, 0.0,
        /*个人部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.08, 0.02, 0.01, 0.0, 0.0, 0.08, 0.0},
    {"昆明",
        /*社保最低值, 最高值*/ 1769, 10410,
        /*公积金最低值, 最高值*/ 950, 10410,
        /*公司部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.2, 0.1, 0.01, 0.003, 0.005, 0.1, 0.0,
        /*个人部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.08, 0.02, 0.005, 0.0, 0.0, 0.1, 0.0},
    {"宁波",
        /*社保最低值, 最高值*/ 1908, 9537,
        /*公积金最低值, 最高值*/ 1310, 20735,
        /*公司部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.12, 0.11, 0.02, 0.004, 0.007, 0.08, 0.0,
        /*个人部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.08, 0.02, 0.01, 0.0, 0.0, 0.08, 0.0},
    {"南昌",
        /*社保最低值, 最高值*/ 1522, 7611,
        /*公积金最低值, 最高值*/ 1083, 9583,
        /*公司部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.19, 0.08, 0.02, 0.02, 0.008, 0.12, 0.0,
        /*个人部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.08, 0.02, 0.01, 0.0, 0.0, 0.12, 0.0},
    {"青岛",
        /*社保最低值, 最高值*/ 1638, 8190,
        /*公积金最低值, 最高值*/ 1638.15, 8190.75,
        /*公司部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.18, 0.09, 0.02, 0.007, 0.01, 0.08, 0.0,
        /*个人部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.08, 0.02, 0.01, 0.0, 0.0, 0.08, 0.0},
    {"苏州",
        /*社保最低值, 最高值*/ 2010, 12915,
        /*公积金最低值, 最高值*/ 1140, 12900,
        /*公司部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.2, 0.09, 0.02, 0.01, 0.01, 0.1, 0.0,
        /*个人部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.08, 0.02, 0.01, 0.0, 0.0, 0.1, 0.0},
    {"深圳",
        /*社保最低值, 最高值*/ 2757, 13785,
        /*公积金最低值, 最高值*/ 1500, 13785,
        /*公司部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.11, 0.045, 0.02, 0.005, 0.007, 0.13, 0.0,
        /*个人部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.08, 0.02, 0.01, 0.005, 0.0, 0.13, 0.0},
    {"天津",
        /*社保最低值, 最高值*/ 2006, 10560,
        /*公积金最低值, 最高值*/ 1310, 14508,
        /*公司部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.2, 0.1, 0.02, 0.005, 0.008, 0.11, 0.0,
        /*个人部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.08, 0.02, 0.01, 0.005, 0.0, 0.11, 0.0},
    {"无锡",
        /*社保最低值, 最高值*/ 2025, 12880,
        /*公积金最低值, 最高值*/ 1320, 9800,
        /*公司部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.2, 0.08, 0.01, 0.003, 0.009, 0.08, 0.0,
        /*个人部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.08, 0.02, 0.01, 0.0, 0.0, 0.08, 0.0},
    {"厦门",
        /*社保最低值, 最高值*/ 2305.2, 11526,
        /*公积金最低值, 最高值*/ 1100, 11526,
        /*公司部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.14, 0.08, 0.02, 0.005, 0.008, 0.12, 0.0,
        /*个人部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.08, 0.02, 0.01, 0.0, 0.0, 0.12, 0.0},
    {"珠海",
        /*社保最低值, 最高值*/ 2046, 11289,
        /*公积金最低值, 最高值*/ 1350, 10230,
        /*公司部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.1, 0.06, 0.01, 0.004, 0.007, 0.1, 0.0,
        /*个人部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.08, 0.02, 0.01, 0.0, 0.0, 0.1, 0.0},
    {"潍坊",
        /*社保最低值, 最高值*/ 1833, 9162,
        /*公积金最低值, 最高值*/ 1100, 9162,
        /*公司部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.2, 0.07, 0.02, 0.005, 0.01, 0.12, 0.0,
        /*个人部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.08, 0.02, 0.01, 0.0, 0.0, 0.12, 0.0},
    {"其它",
        /*社保最低值, 最高值*/ 2599, 12993,
        /*公积金最低值, 最高值*/ 2599, 12993,
        /*公司部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.22, 0.12, 0.017, 0.005, 0.008, 0.07, 0.0,
        /*个人部分, 养老,医疗,失业,工伤,生育,公积金,重疾*/ 0.08, 0.02, 0.01, 0.0, 0.0, 0.07, 0.0},
};

@implementation TaxViewController

- (void)TapLeftButton
{
    NSDictionary *flurryDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"appAd", @"jiebanyou", nil];
    [Flurry logEvent:@"Event_Call" withParameters: flurryDictionary timed:YES];
    
    NSURL *url = [[NSURL alloc] initWithString: @"https://itunes.apple.com/us/app/jie-ban-you/id607998928?ls=1&mt=8"];
    [[UIApplication sharedApplication] openURL: url];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return allCity.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
    
    cell.accessoryType = UITableViewCellSelectionStyleNone;
    
    if (indexPath.row == currentCityId) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    cell.textLabel.text = [allCity objectAtIndex: indexPath.row];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor blueColor];
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    currentCityId = indexPath.row;
    myCity = city[currentCityId];
    
    [self SetCity];
    
    [self Calculator];
    
    [aTableView reloadData];
}

- (void)SelectCity
{
    [tfLaborage resignFirstResponder];
    
    aTableView.hidden = !aTableView.hidden;
    
    UIImage *btnSearchImage = nil;
    if (aTableView.hidden) {
        btnSearchImage = [[UIImage imageNamed:@"down.png"] stretchableImageWithLeftCapWidth: 5 topCapHeight: 5];
    }
    else
    {
        btnSearchImage = [[UIImage imageNamed:@"up.png"] stretchableImageWithLeftCapWidth: 5 topCapHeight: 5];
    }

    [btnCity setBackgroundImage: btnSearchImage forState: UIControlStateNormal];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // UI
    self.view.backgroundColor = [UIColor grayColor];
    
    bannerView = [[GADBannerView alloc]
                                      initWithFrame:CGRectMake(0.0,
                                                               //  self.view.frame.size.height - GAD_SIZE_320x50.height,
                                                               0,
                                                               GAD_SIZE_320x50.width,
                                                               GAD_SIZE_320x50.height)];
	
    // Specify the ad's "unit identifier." This is your AdMob Publisher ID.
	bannerView.adUnitID = MY_BANNER_UNIT_ID;
	
    // Let the runtime know which UIViewController to restore after taking
    // the user wherever the ad goes and add it to the view hierarchy.
    bannerView.rootViewController = self;
    [self.view addSubview: bannerView];
	
    // Initiate a generic request to load it with an ad.
    [bannerView loadRequest:[GADRequest request]];
    
    UIButton *btnAd = [UIButton buttonWithType: UIButtonTypeCustom];
    btnAd.frame = CGRectMake(200, 50, 100, 44);
    [btnAd setBackgroundColor:[UIColor clearColor]];
    [btnAd setBackgroundImage:[UIImage imageNamed:@"ad.png"] forState:UIControlStateNormal];
    [btnAd addTarget:self action:@selector(TapLeftButton) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview: btnAd];
    
    
    tvIntroduction = [[UITextView alloc] initWithFrame: CGRectMake(10, 100, 300, 70)];
    tvIntroduction.backgroundColor = [UIColor clearColor];
    tvIntroduction.editable = NO;
    [self.view addSubview: tvIntroduction];
    
    UIImage *btnSearchDownImage = [[UIImage imageNamed:@"down.png"]
                                   stretchableImageWithLeftCapWidth: 5 topCapHeight: 5];
    btnCity = [UIButton buttonWithType: UIButtonTypeCustom];
    btnCity.frame = CGRectMake(110, 50, 80, 44);
    [btnCity setBackgroundImage: btnSearchDownImage forState: UIControlStateNormal];
    [btnCity addTarget: self action: @selector(SelectCity) forControlEvents: UIControlEventTouchUpInside];
    btnCity.tintColor = [UIColor blueColor];
    [btnCity setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
    btnCity.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview: btnCity];
    
    tfLaborage = [[UITextField alloc] initWithFrame: CGRectMake(120, 180, 140, 25)];
    tfLaborage.keyboardType = UIKeyboardTypeNumberPad;
    tfLaborage.clearButtonMode = UITextFieldViewModeAlways; // UITextFieldViewModeWhileEditing;
    tfLaborage.borderStyle = UITextBorderStyleRoundedRect;
    tfLaborage.placeholder = @"工资";
    [self.view addSubview: tfLaborage];
    
    btnTax = [UIButton buttonWithType: UIButtonTypeContactAdd];
    [btnTax addTarget: self action: @selector(Calculator) forControlEvents: UIControlEventTouchUpInside];
    CGRect frame = btnTax.frame;
    frame.origin.x = 270;
    frame.origin.y = 180;
    btnTax.frame = frame;
    [self.view addSubview: btnTax];

    tvCompany = [[UILabel alloc] initWithFrame: CGRectMake(20, 210, 150, 165)];
    tvCompany.font = [UIFont systemFontOfSize: 15];
    tvCompany.backgroundColor = [UIColor clearColor];
    tvCompany.numberOfLines = 0;
    [self.view addSubview: tvCompany];
    
    tvMyself = [[UILabel alloc] initWithFrame: CGRectMake(170, 210, 150, 165)];
    tvMyself.font = [UIFont systemFontOfSize: 15];
    tvMyself.backgroundColor = [UIColor clearColor];
    tvMyself.numberOfLines = 0;
    [self.view addSubview: tvMyself];
    
    lbOutcome = [[UILabel alloc] initWithFrame: CGRectMake(20, 380, 260, 40)];
    lbOutcome.backgroundColor = [UIColor clearColor];
    lbOutcome.numberOfLines = 2;
    lbOutcome.font = [UIFont systemFontOfSize: 15];
    [self.view addSubview: lbOutcome];
    
    lbOUtcome2 = [[UILabel alloc] initWithFrame: CGRectMake(20, 420, 300, 40)];
    lbOUtcome2.backgroundColor = [UIColor clearColor];
    lbOUtcome2.numberOfLines = 2;
    lbOUtcome2.font = [UIFont systemFontOfSize: 15];
    [self.view addSubview: lbOUtcome2];
    
    aTableView = [[UITableView alloc] initWithFrame: CGRectMake(0, 0, 320, [UIScreen mainScreen].bounds.size.height-20) style: UITableViewStylePlain];
    aTableView.delegate = self;
    aTableView.dataSource = self;
    //    aTableView.alpha = 0.5;
    [self.view addSubview: aTableView];
    aTableView.hidden = YES;
    
    // Dada
    allCity = [[NSArray alloc] initWithObjects:
               @"北京", @"上海", @"广州", @"南京", @"杭州",
               @"济南", @"郑州", @"沈阳", @"武汉", @"成都",
               @"长春", @"重庆", @"东莞", @"福州", @"哈尔滨",
               @"昆明", @"宁波", @"南昌", @"青岛", @"苏州",
               @"深圳", @"天津", @"无锡", @"夏门", @"珠海",
               @"潍坊", @"其它", nil];
    
    currentCityId = 2;
    
    myCity = city[currentCityId];
    
    [self SetCity];
}

- (void)SetCity
{
    [btnCity setTitle: [allCity objectAtIndex: currentCityId] forState: UIControlStateNormal];
    
    
    tvIntroduction.text = [NSString stringWithFormat: @"%@\n单位缴费比例\n养老: %.2f 医疗: %.2f 失业: %.2f 工伤: %.2f 生育: %.2f 重疾: %.2f 公积金: %.2f\n个人缴费比例\n养老: %.2f 医疗: %.2f 失业: %.2f 工伤: %.2f 生育: %.2f 重疾: %.2f 公积金: %.2f\n社保基数最低值 %2.f 社保基数最高值 %2.f\n公积金基数最低值 %2.f 公积金基数最低值 %2.f \n个人所得税税率表\n     级数 全月应纳税所得额 税率\
                           \
                           　　1 不超过1500元的 3%%\
                           \
                           　　2 超过1500元至4500元的部分 10%%\
                           \
                           　　3 超过4500元至9000元的部分 20%%\
                           \
                           　　4 超过9000元至35000元的部分 25%%\
                           \
                           　　5 超过35000元至55000元的部分 30%%\
                           \
                           　　6 超过55000元至80000元的部分 35%%\
                           \
                           　　7 超过80000元的部分 45%%",
                           [allCity objectAtIndex: currentCityId],
                           myCity.companyEndowmentInsurance,
                           myCity.companyHospitalizationInsurance,
                           myCity.companyIdlenessInsurance,
                           myCity.companyCompoInsurance,
                           myCity.companyProcreateInsurance,
                           myCity.companyGraveSick,
                           myCity.companyDream,
                           myCity.myselfEndowmentInsurance,
                           myCity.myselfHospitalizationInsurance,
                           myCity.myselfIdlenessInsurance,
                           myCity.myselfCompoInsurance,
                           myCity.myselfProcreateInsurance,
                           myCity.myselfGraveSick,
                           myCity.myselfDream,
                           myCity.insuranceMin,
                           myCity.insuranceMax,
                           myCity.dreamMin,
                           myCity.deremMax
                           ];
}

- (void)Calculator
{
    [tfLaborage resignFirstResponder];
    aTableView.hidden = YES;
  
    if (tfLaborage.text.length <= 0) {
        return;
    }
    
    float laborage = tfLaborage.text.floatValue;
    
    float insuraceValue = laborage;
    if (insuraceValue < myCity.insuranceMin) {
        insuraceValue = myCity.insuranceMin;
    }
    else if (insuraceValue > myCity.insuranceMax) {
        insuraceValue = myCity.insuranceMax;
    }
    
    float dreamValue = laborage;
    if (dreamValue < myCity.dreamMin) {
        dreamValue = myCity.dreamMin;
    }
    else if (dreamValue > myCity.deremMax) {
        dreamValue = myCity.deremMax;
    }
    
    // 交公积金
    float allInsurance = insuraceValue*myCity.myselfEndowmentInsurance +
    insuraceValue*myCity.myselfHospitalizationInsurance +
    insuraceValue*myCity.myselfIdlenessInsurance +
    insuraceValue*myCity.myselfCompoInsurance +
    insuraceValue*myCity.myselfProcreateInsurance +
    dreamValue*myCity.myselfDream +
    insuraceValue*myCity.myselfGraveSick;
    
    float allInsuranceCompany = insuraceValue*myCity.companyEndowmentInsurance +
    insuraceValue*myCity.companyHospitalizationInsurance +
    insuraceValue*myCity.companyIdlenessInsurance +
    insuraceValue*myCity.companyCompoInsurance +
    insuraceValue*myCity.companyProcreateInsurance +
    dreamValue*myCity.companyDream +
    insuraceValue*myCity.companyGraveSick;
    
    NSString *strCompany = [NSString stringWithFormat:
                            @"单位缴费:  %.2f\n养老:     %.2f\n医疗:     %.2f\n失业:     %.2f\n工伤:     %.2f\n生育:     %.2f\n公积金:  %.2f\n重疾:     %.2f",
                            allInsuranceCompany,
                            insuraceValue*myCity.companyEndowmentInsurance,
                            insuraceValue*myCity.companyHospitalizationInsurance,
                            insuraceValue*myCity.companyIdlenessInsurance,
                            insuraceValue*myCity.companyCompoInsurance,
                            insuraceValue*myCity.companyProcreateInsurance,
                            dreamValue*myCity.companyDream,
                            insuraceValue*myCity.companyGraveSick];
    
    tvCompany.text = strCompany;
    
    strCompany = [NSString stringWithFormat:
                  @"个人缴费:  %.2f\n养老:     %.2f\n医疗:     %.2f\n失业:     %.2f\n工伤:     %.2f\n生育:     %.2f\n公积金:  %.2f\n重疾:     %.2f",
                  allInsurance,
                  insuraceValue*myCity.myselfEndowmentInsurance,
                  insuraceValue*myCity.myselfHospitalizationInsurance,
                  insuraceValue*myCity.myselfIdlenessInsurance,
                  insuraceValue*myCity.myselfCompoInsurance,
                  insuraceValue*myCity.myselfProcreateInsurance,
                  dreamValue*myCity.myselfDream,
                  insuraceValue*myCity.myselfGraveSick];
    
    tvMyself.text = strCompany;
    
    float taxRate = laborage-allInsurance-3500;
    
    if (taxRate > 0) {
        float taxValue = [self GetTaxValue: taxRate];
        
        lbOutcome.text = [NSString stringWithFormat: @"交公积金: %.0f - %.2f - %.2f(个税)= %.2f",
                          laborage, allInsurance, taxValue, laborage-allInsurance-taxValue];
    }
    else
    {
        lbOutcome.text = [NSString stringWithFormat: @"交公积金: %.0f - %.2f = %.2f",
                          laborage, allInsurance, laborage-allInsurance];
    }
    
    // 不交公积金
    allInsurance -= dreamValue*myCity.myselfDream;
    
    taxRate = laborage-allInsurance-3500;
    
    if (taxRate > 0) {
        float taxValue = [self GetTaxValue: taxRate];
        
        lbOUtcome2.text = [NSString stringWithFormat: @"不交公积金: %.0f - %.2f - %.2f(个税)= %.2f",
                          laborage, allInsurance, taxValue, laborage-allInsurance-taxValue];
    }
    else
    {
        lbOUtcome2.text = [NSString stringWithFormat: @"不交公积金: %.0f - %.2f = %.2f",
                          laborage, allInsurance, laborage-allInsurance];
    }
}

- (float)GetTaxValue:(float)taxRate
{
    float taxValue = 0;
    if (taxRate <= 1500) {
        taxValue = taxRate * 0.03;
    }
    else if (taxRate <= 4500) {
        taxValue = (taxRate-1500) * 0.1 + 45;
    }
    else if (taxRate <= 9000) {
        taxValue = (taxRate-4500) * 0.2 + 300+45;
    }
    else if (taxRate <= 35000) {
        taxValue = (taxRate-9000) * 0.25 + 900+300+45;
    }
    else if (taxRate <= 55000) {
        taxValue = (taxRate-35000) * 0.3 + 6500+900+300+45;
    }
    else if (taxRate <= 80000) {
        taxValue = (taxRate-55000) * 0.35 + 6000+6500+900+300+45;
    }
    else {
        taxValue = (taxRate-80000) * 0.45 + 8750+6000+6500+900+300+45;
    }
    
    return taxValue;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
