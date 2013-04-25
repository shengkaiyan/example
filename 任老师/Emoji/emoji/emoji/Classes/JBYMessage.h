//
//  JBYMessage.h
//  Trip
//
//  Created by Sky on 12-12-7.
//  Copyright (c) 2012年 Sky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JBYMessage : NSObject
{
    NSInteger       uid;  // 会员ID
    NSInteger       m_id;  // 私信ID
    NSInteger       content_type;  // 私信内容类型 1:文字 2:图片 3:语音 4:地理位置
    NSString        *content;  // 根据不同的 content_type 具有不同的 含义
    NSInteger       type;  // 针对当前用户,私信的类型: 0:发送 1:接收
    NSString        *create_time;  // 发送时间:(YYYYMMDD:HH:mi:SS)
    NSNumber        *create_time_l;  // 以秒为单位,结伴信息发布时间
    NSString        *nick_name;
    NSString        *profile_image_url;
}

@property (strong, nonatomic) NSString        *nick_name;
@property (strong, nonatomic) NSString        *profile_image_url;
@property (assign, nonatomic) NSInteger       uid;  // 会员ID
@property (assign, nonatomic) NSInteger       m_id;  // 私信ID
@property (assign, nonatomic) NSInteger       content_type;  // 私信内容类型 1:文字 2:图片 3:语音 4:地理位置
@property (strong, nonatomic) NSString        *content;  // 根据不同的 content_type 具有不同的 含义
@property (assign, nonatomic) NSInteger       type;  // 针对当前用户,私信的类型: 0:发送 1:接收
@property (strong, nonatomic) NSString        *create_time;  // 发送时间:(YYYYMMDD:HH:mi:SS)
@property (strong, nonatomic) NSNumber        *create_time_l;  // 以秒为单位,结伴信息发布时间

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
