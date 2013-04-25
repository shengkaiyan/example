//
//  JBYChatCell.m
//  emoji
//
//  Created by Sky on 13-4-25.
//  Copyright (c) 2013年 Sky. All rights reserved.
//

#import "JBYChatCell.h"

#import <QuartzCore/QuartzCore.h>

// ivProfile border
#define IVPROFILE_BORDER_COLOR                      [[JBYChatCell colorFromHexString: @"bfbfbf"] CGColor] // [[UIColor grayColor] CGColor]
#define IVPROFILE_BORDER_WIDTH                      1.0
#define IVPROFILE_BORDER_RADIUS                     4.0


@implementation JBYChatCell
@synthesize ivProfile;
@synthesize btnProfile;
@synthesize lbName;
@synthesize lbTime;
@synthesize lbContent;
@synthesize ivBubble;
@synthesize isAdjustProfile;

+ (UIColor*)colorFromHexString:(NSString *)hexString{
	NSString *cleanString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
	if([cleanString length] == 3) {
		cleanString = [NSString stringWithFormat:@"%@%@%@%@%@%@",
					   [cleanString substringWithRange:NSMakeRange(0, 1)],[cleanString substringWithRange:NSMakeRange(0, 1)],
					   [cleanString substringWithRange:NSMakeRange(1, 1)],[cleanString substringWithRange:NSMakeRange(1, 1)],
					   [cleanString substringWithRange:NSMakeRange(2, 1)],[cleanString substringWithRange:NSMakeRange(2, 1)]];
	}
	if([cleanString length] == 6) {
		cleanString = [cleanString stringByAppendingString:@"ff"];
	}
	
	unsigned int baseValue;
	[[NSScanner scannerWithString:cleanString] scanHexInt:&baseValue];
	
	float red = ((baseValue >> 24) & 0xFF)/255.0f;
	float green = ((baseValue >> 16) & 0xFF)/255.0f;
	float blue = ((baseValue >> 8) & 0xFF)/255.0f;
	float alpha = ((baseValue >> 0) & 0xFF)/255.0f;
	
	return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (CGFloat)neededHeightForDescription:(NSString *)description withTableWidth:(NSUInteger)tableWidth Font:(UIFont *)font LineBreakMode:(UILineBreakMode)lineBreakMode
{
	CGSize labelSize = [description sizeWithFont: font constrainedToSize:CGSizeMake(tableWidth, MAXFLOAT) lineBreakMode: lineBreakMode];
    
	return labelSize.height;
}

+ (CGSize)sizeForDescription:(NSString *)description withTableWidth:(NSUInteger)tableWidth Font:(UIFont *)font LineBreakMode:(UILineBreakMode)lineBreakMode
{
	CGSize labelSize = [description sizeWithFont: font constrainedToSize:CGSizeMake(tableWidth, MAXFLOAT) lineBreakMode: lineBreakMode];
    
	return labelSize;
}

+ (id)cell:(NSString *)cellIdentifier
{
	JBYChatCell *cell = [[JBYChatCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier: cellIdentifier];
    
    [cell setIvBubble: [[UIImageView alloc] init]];
    [cell addSubview: [cell ivBubble]];
    
    [cell setBtnProfile: [UIButton buttonWithType: UIButtonTypeCustom]];
    [[cell btnProfile] setFrame: CGRectMake(0, 10, 46, 46)];
    [cell addSubview: [cell btnProfile]];
    
    [cell setLbTime: [[UILabel alloc] initWithFrame: CGRectMake(194, 6, 65, 20)]];
    [[cell lbTime] setFont: [UIFont systemFontOfSize: 10]];
    cell.lbTime.backgroundColor = [UIColor clearColor];
    [[cell lbTime] setTextColor: [UIColor redColor]];
    [cell.lbTime setTextAlignment: UITextAlignmentRight];
    [cell addSubview: [cell lbTime]];
    
    [cell setLbContent: [[UILabel alloc] initWithFrame: CGRectMake(12, 30, 250, 20)]];
    [[cell lbContent] setFont: [UIFont systemFontOfSize: 15]];
    cell.lbContent.backgroundColor = [UIColor clearColor];
    cell.lbContent.numberOfLines = 0;
    cell.lbContent.lineBreakMode = UILineBreakModeWordWrap;
    [[cell lbContent] setTextColor: [UIColor grayColor]];
    [cell.ivBubble addSubview: [cell lbContent]];
    
    [cell setLbName: [[UILabel alloc] initWithFrame: CGRectMake(12, 6, 150, 20)]];
    [[cell lbName] setFont: [UIFont systemFontOfSize: 15]];
    cell.lbName.backgroundColor = [UIColor clearColor];
    [cell.ivBubble addSubview: [cell lbName]];
    
    [cell setIvProfile: [[UIImageView alloc] initWithFrame: CGRectMake(6, 16, 34, 34)]];
    [cell.ivProfile.layer setBorderColor: IVPROFILE_BORDER_COLOR];
    [cell.ivProfile.layer setBorderWidth: IVPROFILE_BORDER_WIDTH];
    [cell.ivProfile.layer setCornerRadius: IVPROFILE_BORDER_RADIUS];
    [cell.ivProfile.layer setMasksToBounds:YES];
    [cell addSubview: [cell ivProfile]];
    
	return cell;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
    
    CGFloat ivBubble_Y = 6;
    
    CGSize bubbleSize = [JBYChatCell sizeForDescription: lbContent.text withTableWidth: 250 Font: [UIFont systemFontOfSize: 15] LineBreakMode: UILineBreakModeWordWrap];
    
    CGFloat lbContentHeight = [JBYChatCell neededHeightForDescription: lbContent.text withTableWidth: 250 Font: [UIFont systemFontOfSize: 15] LineBreakMode: UILineBreakModeWordWrap];
    CGRect frame = self.lbContent.frame;
    
    CGFloat bubbleWidth = bubbleSize.width;
    bubbleWidth += 20;
    if (bubbleWidth > 268) {
        bubbleWidth = 268;
    }
    
    if (bubbleWidth < 40) {
        bubbleWidth = 40;
    }
    
    UIImage *bubbleImage;
    if (self.isSend) {
        int bubbleQuotiety = 40;
        
        if (self.isHideName) {
            bubbleQuotiety = 10;
            
            if (lbContentHeight < 28) {
                lbContentHeight = 28;
            }
            
            frame.origin.y = 6;
            
            if (self.isShowTime) {
                [lbTime setFrame: CGRectMake(130, 0, 65, 20)];
                [lbTime setTextAlignment: NSTextAlignmentCenter];
                
                ivBubble_Y = 20;
            }
        }
        else
        {
            [lbTime setFrame: CGRectMake(6, 12, 65, 20)];
            [lbTime setTextAlignment: NSTextAlignmentLeft];
            [lbName setFrame: CGRectMake(106, 6, 150, 20)];  // 112+150 = 262
            [lbName setTextAlignment: NSTextAlignmentRight];
            
            if (lbContentHeight > 8*20)
                lbContentHeight = 8*20;
            
            bubbleWidth = 268;
        }
        
        bubbleImage = [[UIImage imageNamed:@"chat_send_nor.png"]
                       stretchableImageWithLeftCapWidth:10 topCapHeight:25];
        self.ivBubble.image = bubbleImage;
        self.ivBubble.frame = CGRectMake(320-46-bubbleWidth, ivBubble_Y, bubbleWidth, lbContentHeight+bubbleQuotiety);
        //        frame.size.width = bubbleWidth;
        //        ivBubble.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        //        lbContent.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        
        if (self.isAdjustProfile) {
            [ivProfile setFrame: CGRectMake(280, 8, 34, 34)];
            [btnProfile setFrame: CGRectMake(274, 2, 46, 46)];
        }
        else
        {
            [ivProfile setFrame: CGRectMake(280, 16, 34, 34)];
            [btnProfile setFrame: CGRectMake(274, 10, 46, 46)];
        }
        
        frame.origin.x = 6;
    }
    else
    {
        int bubbleQuotiety = 40;
        
        if (self.isHideName) {
            bubbleQuotiety = 10;
            
            if (lbContentHeight < 28) {
                lbContentHeight = 28;
            }
            
            frame.origin.y = 6;
            
            if (self.isShowTime) {
                [lbTime setFrame: CGRectMake(130, 0, 65, 20)];
                [lbTime setTextAlignment: NSTextAlignmentCenter];
                
                ivBubble_Y = 20;
            }
        }
        else
        {
            [lbTime setFrame: CGRectMake(240, 12, 65, 20)];
            [lbTime setTextAlignment: NSTextAlignmentRight];
            [lbName setFrame: CGRectMake(12, 6, 150, 20)];  // 112+150 = 262
            [lbName setTextAlignment: NSTextAlignmentLeft];
            
            if (lbContentHeight > 8*20)
                lbContentHeight = 8*20;
            
            bubbleWidth = 268;
        }
        
        //        frame.size.width = bubbleWidth;
        self.ivBubble.frame = CGRectMake(46, ivBubble_Y, bubbleWidth, lbContentHeight+bubbleQuotiety);
        bubbleImage = [[UIImage imageNamed:@"chat_receive_nor.png"]
                       stretchableImageWithLeftCapWidth:30 topCapHeight:30];
        self.ivBubble.image = bubbleImage;
        //        ivBubble.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        //        lbContent.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        
        if (self.isAdjustProfile) {
            [ivProfile setFrame: CGRectMake(6, 8, 34, 34)];
            [btnProfile setFrame: CGRectMake(0, 2, 46, 46)];
        }
        else
        {
            [ivProfile setFrame: CGRectMake(6, 16, 34, 34)];
            [btnProfile setFrame: CGRectMake(0, 10, 46, 46)];
        }
        
        frame.origin.x = 12;
    }
    
    frame.size.height = lbContentHeight;
    
    self.lbContent.frame = frame;
}

@end
