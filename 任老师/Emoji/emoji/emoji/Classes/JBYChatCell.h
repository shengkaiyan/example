//
//  JBYChatCell.h
//  emoji
//
//  Created by Sky on 13-4-25.
//  Copyright (c) 2013年 Sky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JBYChatCell : UITableViewCell
{
    UIImageView     *ivProfile;
    UIButton        *btnProfile;
    UILabel         *lbName;
    UILabel         *lbTime;
    UILabel         *lbContent;
    UIImageView     *ivBubble;
}

@property (strong, nonatomic) UIImageView     *ivProfile;
@property (strong, nonatomic) UIButton        *btnProfile;
@property (strong, nonatomic) UILabel         *lbName;
@property (strong, nonatomic) UILabel         *lbTime;
@property (strong, nonatomic) UILabel         *lbContent;
@property (strong, nonatomic) UIImageView     *ivBubble;

@property (assign, nonatomic) BOOL isSend;

@property (assign, nonatomic) BOOL isHideName;
@property (assign, nonatomic) BOOL isShowTime;
@property (assign, nonatomic) BOOL isAdjustProfile;

+ (id)cell:(NSString *)cellIdentifier;

@end