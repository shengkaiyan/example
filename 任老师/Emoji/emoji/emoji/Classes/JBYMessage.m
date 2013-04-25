//
//  JBYMessage.m
//  Trip
//
//  Created by Sky on 12-12-7.
//  Copyright (c) 2012年 Sky. All rights reserved.
//

#import "JBYMessage.h"

@implementation JBYMessage

@synthesize nick_name;
@synthesize profile_image_url;
@synthesize uid;  // 会员ID
@synthesize m_id;  // 私信ID
@synthesize content_type;  // 私信内容类型 1:文字 2:图片 3:语音 4:地理位置
@synthesize content;  // 根据不同的 content_type 具有不同的 含义
@synthesize type;  // 针对当前用户,私信的类型: 0:发送 1:接收
@synthesize create_time;  // 发送时间:(YYYYMMDD:HH:mi:SS)
@synthesize create_time_l;  // 以秒为单位,结伴信息发布时间

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init])
    {
        self.nick_name = [dictionary objectForKey: @"nick_name"];
        self.profile_image_url = [dictionary objectForKey: @"profile_image_url"];
        self.uid = [[dictionary objectForKey: @"uid"] intValue];
        self.m_id = [[dictionary objectForKey: @"m_id"] intValue];
        self.content_type = [[dictionary objectForKey: @"content_type"] intValue];
        self.content = [dictionary objectForKey: @"content"];
        self.type = [[dictionary objectForKey: @"type"] intValue];
        self.create_time = [dictionary objectForKey: @"create_time"];
        self.create_time_l = [NSNumber numberWithDouble: [[dictionary objectForKey: @"create_time_l"] doubleValue]];
    }
    
    return self;
}

-(void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject: nick_name forKey:@"nick_name"];
    [encoder encodeObject: profile_image_url forKey:@"profile_image_url"];
    [encoder encodeInteger: uid forKey:@"uid"];
    [encoder encodeInteger: m_id forKey:@"m_id"];
    [encoder encodeInteger: content_type forKey:@"content_type"];
    [encoder encodeObject: content forKey:@"content"];
    [encoder encodeInteger: type forKey:@"type"];
    [encoder encodeObject: create_time forKey:@"create_time"];
    [encoder encodeObject: create_time_l forKey: @"create_time_l"];
}

-(id) initWithCoder:(NSCoder *)decoder {
    nick_name = [decoder decodeObjectForKey:@"nick_name"];
    profile_image_url = [decoder decodeObjectForKey:@"profile_image_url"];
    uid = [decoder decodeIntegerForKey:@"uid"];
    m_id = [decoder decodeIntegerForKey:@"m_id"];
    content_type = [decoder decodeIntegerForKey:@"content_type"];
    content = [decoder decodeObjectForKey:@"content"];
    type = [decoder decodeIntegerForKey:@"type"];
    create_time = [decoder decodeObjectForKey:@"create_time"];
    create_time_l = [decoder decodeObjectForKey: @"create_time_l"];
    
    return self;
}

@end
