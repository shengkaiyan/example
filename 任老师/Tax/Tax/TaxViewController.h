//
//  TaxViewController.h
//  Tax
//
//  Created by Sky on 13-3-3.
//  Copyright (c) 2013年 Sky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADBannerView.h"
#import "Flurry/Flurry.h"

typedef struct insuranceCity
{
    // Declare one as an instance variable    
    char *cityName;
    
    float insuranceMin;  // 社保最低值
    float insuranceMax;  // 社保最高值
    
    float dreamMin;  // 社保最低值  // 买房是大多数人的梦想,所以公积金的命名用了dream.
    float deremMax;  // 社保最高值
    
    // 单位
    float companyEndowmentInsurance;  // 养老
    float companyHospitalizationInsurance;  // 医疗
    float companyIdlenessInsurance;  // 失业
    float companyCompoInsurance;  // 工伤
    float companyProcreateInsurance;  // 生育
    float companyDream;  // 公积金
    float companyGraveSick;  // 重疾,目前只有广州有这个险,看来,只有广州人才生大病.

    // 个人
    float myselfEndowmentInsurance;  // 养老
    float myselfHospitalizationInsurance;  // 医疗
    float myselfIdlenessInsurance;  // 失业
    float myselfCompoInsurance;  // 工伤
    float myselfProcreateInsurance;  // 生育
    float myselfDream;  // 公积金
    float myselfGraveSick;  // 重疾
}
InsuranceCity;

@interface TaxViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    GADBannerView *bannerView;
    
    UITableView *aTableView;
    
    UITextView *tvIntroduction;
    
    UIButton *btnCity;
    UIButton *btnTax;
    UITextField *tfLaborage;
//    UITextView *tvCompany;
//    UITextView *tvMyself;
    UILabel *tvCompany;
    UILabel *tvMyself;
    UILabel *lbOutcome;
    UILabel *lbOUtcome2;

    InsuranceCity myCity;
    
    NSArray *allCity;
    int currentCityId;
}

@end
