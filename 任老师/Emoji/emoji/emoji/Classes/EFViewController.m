//
//  EFViewController.m
//  emoji
//
//  Created by Sky on 13-4-23.
//  Copyright (c) 2013年 Sky. All rights reserved.
//

#import "EFViewController.h"
#import "EFFaceBoard.h"
#import "NSString+Additions.h"
#import "JBYMessage.h"
#import "JBYChatCell.h"


#import "RegexKitLite.h"
#import "SCGIFImageView.h"
#import "MarkupParser.h"
#import "NSAttributedString+Attributes.h"
#import <QuartzCore/QuartzCore.h>

#define CHAT_BACKGROUND_COLOR [UIColor colorWithRed:0.859f green:0.886f blue:0.929f alpha:1.0f]

#define VIEW_WIDTH    self.view.frame.size.width
#define VIEW_HEIGHT    self.view.frame.size.height
#define DISTANCE_TABLEVIEW_CHATBAR 0

#define RESET_CHAT_BAR_HEIGHT    SET_CHAT_BAR_HEIGHT(kChatBarHeight1)
#define EXPAND_CHAT_BAR_HEIGHT    SET_CHAT_BAR_HEIGHT(kChatBarHeight4)
#define    SET_CHAT_BAR_HEIGHT(HEIGHT)\
CGRect chatContentFrame = aTableView.frame;\
chatContentFrame.size.height = VIEW_HEIGHT - HEIGHT-DISTANCE_TABLEVIEW_CHATBAR;\
[UIView beginAnimations:nil context:NULL];\
[UIView setAnimationDuration:0.1f];\
aTableView.frame = chatContentFrame;\
chatBar.frame = CGRectMake(chatBar.frame.origin.x, chatContentFrame.size.height+DISTANCE_TABLEVIEW_CHATBAR,\
VIEW_WIDTH, HEIGHT);\
[UIView commitAnimations]


static CGFloat const kSentDateFontSize  = 13.0f;
static CGFloat const kMessageFontSize   = 15.0f;   // 15.0f, 14.0f
static CGFloat const kMessageTextWidth  = 180.0f;
static CGFloat const kContentHeightMax  = 84.0f;  // 80.0f, 76.0f
static CGFloat const kChatBarHeight1    = 44.0f;
static CGFloat const kChatBarHeight4    = 94.0f;

static const int kWeiboMaxWordCount = 140;

@interface EFViewController ()

@end

@implementation EFViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        dictEmoji = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"dictEmoji" ofType:@"plist"]];
    }
    return self;
}

- (UIColor*)colorFromHexString:(NSString *)hexString{
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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    arrayChat = [[NSMutableArray alloc] init];
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    frame.size.height -= (kChatBarHeight1+20+DISTANCE_TABLEVIEW_CHATBAR);
    
    aTableView = [[UITableView alloc] initWithFrame: frame style: UITableViewStylePlain];
    aTableView.delegate = self;
    aTableView.dataSource = self;
    aTableView.contentInset = UIEdgeInsetsMake(7.0f, 0.0f, 0.0f, 0.0f);
    aTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleHeight;
    aTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    aTableView.backgroundColor = [self colorFromHexString: @"#f3f3f3"];
    [self.view addSubview: aTableView];
    
    // Listen for keyboard.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];

    // Create chatBar.
    chatBar = [[UIImageView alloc] initWithFrame:
               CGRectMake(0.0f, self.view.frame.size.height-kChatBarHeight1,
                          self.view.frame.size.width, kChatBarHeight1)];
    chatBar.clearsContextBeforeDrawing = NO;
    chatBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleWidth;
    chatBar.image = [[UIImage imageNamed:@"ChatBar.png"]
                     stretchableImageWithLeftCapWidth:18 topCapHeight:20];
    chatBar.userInteractionEnabled = YES;
    
    // Create chatInput.
    chatInput = [[UITextView alloc] initWithFrame:CGRectMake(10.0f, 9.0f, 234.0f, 22.0f)];
    chatInput.contentSize = CGSizeMake(234.0f, 22.0f);
    chatInput.delegate = self;
    chatInput.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    chatInput.scrollEnabled = NO; // not initially
    chatInput.scrollIndicatorInsets = UIEdgeInsetsMake(5.0f, 0.0f, 4.0f, -2.0f);
    chatInput.clearsContextBeforeDrawing = NO;
    chatInput.font = [UIFont systemFontOfSize:kMessageFontSize];
    chatInput.dataDetectorTypes = UIDataDetectorTypeAll;
    chatInput.backgroundColor = [UIColor clearColor];
    previousContentHeight = chatInput.contentSize.height;
    [chatBar addSubview:chatInput];
    
    //表情按钮
    faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    faceButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
    [faceButton setBackgroundImage:[UIImage imageNamed:@"face"] forState:UIControlStateNormal];
    [faceButton addTarget:self action:@selector(disFaceKeyboard) forControlEvents:UIControlEventTouchUpInside];
    faceButton.frame = CGRectMake(chatBar.frame.size.width - 100.0f, 5.0f, 34.0f, 34.0f);
    [chatBar addSubview:faceButton];
    
    voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    voiceButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
    [voiceButton setBackgroundImage:[UIImage imageNamed:@"Voice"] forState:UIControlStateNormal];
    [voiceButton addTarget:self action:@selector(ChangeSpeakState) forControlEvents:UIControlEventTouchUpInside];
    voiceButton.frame = CGRectMake(10.0f, 5.0f, 34.0f, 34.0f);
    [chatBar addSubview:voiceButton];
    
    speakButton = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    speakButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
    [speakButton setTitle:@"按住说话" forState: UIControlStateNormal];
    [speakButton addTarget:self action:@selector(startSpeak) forControlEvents:UIControlEventTouchDown];
    [speakButton addTarget:self action:@selector(endSpeak) forControlEvents:UIControlEventTouchUpInside];
    [speakButton addTarget:self action:@selector(cancelSpeak) forControlEvents:UIControlEventTouchUpOutside];
    speakButton.frame = CGRectMake(40.0f, 5.0f, 134.0f, 34.0f);
    [chatBar addSubview:speakButton];
    speakButton.hidden = YES;
    
    // Create sendButton.
    sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sendButton.clearsContextBeforeDrawing = NO;
    sendButton.frame = CGRectMake(chatBar.frame.size.width - 51.0f, 0.0f, 44.0f, 44.0f);//CGRectMake(chatBar.frame.size.width - 70.0f, 8.0f, 64.0f, 26.0f);
    sendButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | // multi-line input
    UIViewAutoresizingFlexibleLeftMargin;                       // landscape
    UIImage *sendButtonBackground = [UIImage imageNamed:@"right.png"]; //[UIImage imageNamed:@"SendButton.png"];
    [sendButton setBackgroundImage:sendButtonBackground forState:UIControlStateNormal];
    [sendButton setBackgroundImage:sendButtonBackground forState:UIControlStateDisabled];
    sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    sendButton.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    //    [sendButton setTitle:@"Send" forState:UIControlStateNormal];
    UIColor *shadowColor = [[UIColor alloc] initWithRed:0.325f green:0.463f blue:0.675f alpha:1.0f];
    [sendButton setTitleShadowColor:shadowColor forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(sendMessage)
         forControlEvents:UIControlEventTouchUpInside];
    //    // The following three lines aren't necessary now that we'are using background image.
    //    sendButton.backgroundColor = [UIColor clearColor];
    //    sendButton.layer.cornerRadius = 13;
    //    sendButton.clipsToBounds = YES;
    [self resetSendButton]; // disable initially
    [chatBar addSubview:sendButton];
    
    btnCharacterCount = [UIButton buttonWithType: UIButtonTypeCustom];
    btnCharacterCount.frame = CGRectMake(chatBar.frame.size.width - 58.0f, 4.0f, 60, 20);
    [btnCharacterCount setTitle: [NSString stringWithFormat: @"%d", kWeiboMaxWordCount] forState: UIControlStateNormal];
    btnCharacterCount.titleEdgeInsets = UIEdgeInsetsMake(2, 2, 0, 20);
    [btnCharacterCount setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
    [btnCharacterCount addTarget: self action: @selector(DeleteText) forControlEvents: UIControlEventTouchUpInside];
    [chatBar addSubview: btnCharacterCount];
    btnCharacterCount.hidden = YES;
    
    [self.view addSubview:chatBar];
    [self.view sendSubviewToBack:chatBar];
    
    faceBoard = [[EFFaceBoard alloc] initWithMultiFaceType: YES DefaultFaceType: Face_system];
    faceBoard.inputTextView = chatInput;
    
    showFaceBoard = NO;
    showSpeakingState = NO;
}

- (void)CancelSpeakState
{
    speakButton.hidden = YES;
    
    [voiceButton setBackgroundImage:[UIImage imageNamed:@"Voice"] forState:UIControlStateNormal];
}

-(void)ChangeSpeakState
{
    showSpeakingState = !showSpeakingState;
    
    if (showSpeakingState) {
        [chatInput resignFirstResponder];
        [faceButton setBackgroundImage:[UIImage imageNamed:@"face"] forState:UIControlStateNormal];
        showFaceBoard = NO;
        speakButton.hidden = NO;
        
        [voiceButton setBackgroundImage:[UIImage imageNamed:@"Text"] forState:UIControlStateNormal];
    }
    else
    {
        [self CancelSpeakState];
    }
}

-(void)cancelSpeak
{
    NSLog(@"cancelSpeak");
}

-(void)startSpeak
{
    NSLog(@"startSpeak");
}

-(void)endSpeak
{
    NSLog(@"endSpeak");
}

- (void)sendMessage
{
    NSString *deleteSpace = chatInput.text;
    int wordCount = [self wordCount: deleteSpace];
    if (wordCount>140 || wordCount<=0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"请输入1-280个以内有效字符的私信信息."
                                                            message: nil
                                                           delegate: nil
                                                  cancelButtonTitle: nil
                                                  otherButtonTitles: NSLocalizedString(@"确认",@""), nil];
        [alertView show];
        
        return;
    }
    
    JBYMessage *newMessage = [[JBYMessage alloc] init];
    newMessage.content_type = 1;
    newMessage.content = deleteSpace;
    newMessage.type = (arrayChat.count%2) ? 1 : 0;
    [arrayChat addObject: newMessage];
    
    [aTableView reloadData];
    chatInput.text = @"";
    RESET_CHAT_BAR_HEIGHT;
    [btnCharacterCount setTitle: [NSString stringWithFormat: @"%d", kWeiboMaxWordCount] forState: UIControlStateNormal];
    btnCharacterCount.hidden = YES;
}

-(void)disFaceKeyboard{
    if (!showFaceBoard) {
        [faceButton setBackgroundImage:[UIImage imageNamed:@"Text"] forState:UIControlStateNormal];
        chatInput.inputView = faceBoard;
        [chatInput reloadInputViews];
        [chatInput becomeFirstResponder];
        
        showFaceBoard = YES;
    }
    else
    {
        [faceButton setBackgroundImage:[UIImage imageNamed:@"face"] forState:UIControlStateNormal];
        
        chatInput.inputView = nil;
        [chatInput reloadInputViews];
        
        showFaceBoard = NO;
    }
}

#pragma mark Keyboard Notifications
- (void)keyboardWillShow:(NSNotification *)notification {
    [self resizeViewWithOptions:[notification userInfo]];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [self resizeViewWithOptions:[notification userInfo]];
}

- (void)resizeViewWithOptions:(NSDictionary *)options {
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    [[options objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[options objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[options objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:animationCurve];
    [UIView setAnimationDuration:animationDuration];
    CGRect viewFrame = self.view.frame;
    //    NSLog(@"viewFrame y: %@", NSStringFromCGRect(viewFrame));
    
    CGRect keyboardFrameEndRelative = [self.view convertRect:keyboardEndFrame fromView:nil];
    //    NSLog(@"self.view: %@", self.view);
    NSLog(@"keyboardFrameEndRelative: %@", NSStringFromCGRect(keyboardFrameEndRelative));
    //
    viewFrame.size.height =  keyboardFrameEndRelative.origin.y;
    self.view.frame = viewFrame;
    [UIView commitAnimations];
    
    [self scrollToBottomAnimated:YES];
    
//    chatInput.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 3.0f, 0.0f);
//    chatInput.contentOffset = CGPointMake(0.0f, 6.0f); // fix quirk
}


- (NSString *)escapedString:(NSString *)oldString
{
    NSString *escapedString_lt = [oldString stringByReplacingOccurrencesOfString:@"<" withString:@"&lt"];
    NSString *escapedString = [escapedString_lt stringByReplacingOccurrencesOfString:@">" withString:@"&gt"];
    return escapedString;
}

#pragma OHAttributedLabelDelegate
- (BOOL)attributedLabel:(OHAttributedLabel *)attributedLabel shouldFollowLink:(NSTextCheckingResult *)linkInfo
{
    NSString *requestString = [linkInfo.URL absoluteString];
    NSLog(@"%@",requestString);
    if ([[UIApplication sharedApplication]canOpenURL:linkInfo.URL]) {
        [[UIApplication sharedApplication]openURL:linkInfo.URL];
    }
    return NO;
}

-(UIColor*)colorForLink:(NSTextCheckingResult*)linkInfo underlineStyle:(int32_t*)underlineStyle //!< Combination of CTUnderlineStyle and CTUnderlineStyleModifiers
{
    return [UIColor blueColor];
}

- (void)creatAttributedLabel:(NSString *)o_text Label:(OHAttributedLabel *)label
{
    [label setNeedsDisplay];
    NSMutableArray *httpArr = [self addHttpArr:o_text];
    NSMutableArray *phoneNumArr = [self addPhoneNumArr:o_text];
    
    NSString *text = [self transformString:o_text];
    text = [NSString stringWithFormat:@"<font color='black' strokeColor='gray' face='Palatino-Roman'>%@",text];
    
    MarkupParser* p = [[MarkupParser alloc] init];
    NSMutableAttributedString* attString = [p attrStringFromMarkup: text];
    //    attString = [NSMutableAttributedString attributedStringWithAttributedString:attString];
    [attString setFont:[UIFont systemFontOfSize:16]];
    label.backgroundColor = [UIColor clearColor];
    [label setAttString:attString withImages:p.images];
    
    NSString *string = attString.string;
    
    if ([phoneNumArr count]) {
        for (NSString *phoneNum in phoneNumArr) {
            [label addCustomLink:[NSURL URLWithString:phoneNum] inRange:[string rangeOfString:phoneNum]];
        }
    }
    
    if ([httpArr count]) {
        for (NSString *httpStr in httpArr) {
            [label addCustomLink:[NSURL URLWithString:httpStr] inRange:[string rangeOfString:httpStr]];
        }
    }
    
    label.delegate = self;
    CGRect labelRect = label.frame;
    labelRect.size.width = [label sizeThatFits:CGSizeMake(250, CGFLOAT_MAX)].width;
    labelRect.size.height = [label sizeThatFits:CGSizeMake(250, CGFLOAT_MAX)].height;
    label.frame = labelRect;
    //    label.onlyCatchTouchesOnLinks = NO;
    label.underlineLinks = NO;//链接是否带下划线
    [label.layer display];
    // 调用这个方法立即触发label的|drawTextInRect:|方法，
    // |setNeedsDisplay|方法有滞后，因为这个需要画面稳定后才调用|drawTextInRect:|方法
    // 这里我们创建的时候就需要调用|drawTextInRect:|方法，所以用|display|方法，这个我找了很久才发现的
}

- (void)drawImage:(OHAttributedLabel *)label
{
    for (NSArray *info in label.imageInfoArr) {
//        NSString *filePath = [[NSBundle mainBundle] pathForResource:[info objectAtIndex:0] ofType: @"png"];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:[info objectAtIndex:0] ofType: nil];
        NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
        SCGIFImageView *imageView = [[SCGIFImageView alloc] initWithGIFData:data];
        imageView.frame = CGRectFromString([info objectAtIndex:2]);
        [label addSubview:imageView];//label内添加图片层
        [label bringSubviewToFront:imageView];
    }
}

#pragma mark - 正则匹配电话号码，网址链接，Email地址
- (NSMutableArray *)addHttpArr:(NSString *)text
{
    //匹配网址链接
    NSString *regex_http = @"(https?|ftp|file)+://[^\\s]*";
    NSArray *array_http = [text componentsMatchedByRegex:regex_http];
    NSMutableArray *httpArr = [NSMutableArray arrayWithArray:array_http];
    return httpArr;
}

- (NSMutableArray *)addPhoneNumArr:(NSString *)text
{
    //匹配电话号码
    NSString *regex_phonenum = @"\\d{3}-\\d{7}|\\d{3}-\\d{7}|\\d{4}-\\d{8}|\\d{4}-\\d{8}|1+[358]+\\d{9}|\\d{8}|\\d{7}";
    NSArray *array_phonenum = [text componentsMatchedByRegex:regex_phonenum];
    NSMutableArray *phoneNumArr = [NSMutableArray arrayWithArray:array_phonenum];
    return phoneNumArr;
}

- (NSMutableArray *)addEmailArr:(NSString *)text
{
    //匹配Email地址
    NSString *regex_email = @"\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*.\\w+([-.]\\w+)*";
    NSArray *array_email = [text componentsMatchedByRegex:regex_email];
    NSMutableArray *emailArr = [NSMutableArray arrayWithArray:array_email];
    return emailArr;
}

- (NSString *)transformString:(NSString *)originalStr
{
    //匹配表情，将表情转化为html格式
    NSString *text = originalStr;
    NSString *regex_emoji = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
    NSArray *array_emoji = [text componentsMatchedByRegex:regex_emoji];
    if ([array_emoji count]) {
        for (NSString *str in array_emoji) {
            NSRange range = [text rangeOfString:str];
            NSString *i_transCharacter = [dictEmoji objectForKey:str];
            if (i_transCharacter) {
                NSString *imageHtml = [NSString stringWithFormat:@"<img src='%@' width='16' height='16'>",i_transCharacter];
                text = [text stringByReplacingCharactersInRange:NSMakeRange(range.location, [str length]) withString:imageHtml];
            }
        }
    }
    //返回转义后的字符串
    return text;
}

- (void)longPress:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        JBYChatCell *cell = (JBYChatCell *)recognizer.view;
        [cell becomeFirstResponder];
        
        UIMenuItem *flag = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(flag:)];
        
        UIMenuItem *approve = [[UIMenuItem alloc] initWithTitle:@"转发" action:@selector(approve:)];
        
        UIMenuItem *deny = [[UIMenuItem alloc] initWithTitle:@"分享" action:@selector(deny:)];
        
        UIMenuController *menu = [UIMenuController sharedMenuController];
        
        [menu setMenuItems:[NSArray arrayWithObjects:flag, approve, deny, nil]];
        [menu setTargetRect:cell.frame inView:cell.superview];
        [menu setMenuVisible:YES animated:YES];
    }
}

//- (BOOL)canBecomeFirstResponder{
//    return YES;
//}

- (void)flag:(id)sender {
    NSLog(@"Cell was flagged");
}

- (void)approve:(id)sender {
    NSLog(@"Cell was approved");
}

- (void)deny:(id)sender {
    NSLog(@"Cell was denied");
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    return arrayChat.count;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return([[self.rowHeights objectAtIndex:indexPath.row] floatValue] + 20);
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JBYChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JBYChatCell"];
    if (!cell) {
        cell = [JBYChatCell cell: @"JBYChatCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    JBYMessage *message = [arrayChat objectAtIndex: indexPath.row];
    
    [self creatAttributedLabel: message.content Label: cell.lbContent];
    [self drawImage: cell.lbContent];
//    cell.lbContent.text = message.content;
    cell.isHideName = YES;
    cell.isSend = message.type;

    
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [cell addGestureRecognizer:recognizer];
    
    return cell;
}

- (CGFloat)neededHeightForDescription:(NSString *)description withTableWidth:(NSUInteger)tableWidth Font:(UIFont *)font LineBreakMode:(UILineBreakMode)lineBreakMode
{
	CGSize labelSize = [description sizeWithFont: font constrainedToSize:CGSizeMake(tableWidth, MAXFLOAT) lineBreakMode: lineBreakMode];
    
	return labelSize.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"height: %d", indexPath.row);
    
    CGFloat contentWidth = 250;
    // 设置字体
    
    JBYMessage *MessageInfo = [arrayChat objectAtIndex: indexPath.row];
    
    // 显示的内容
    NSString *content = MessageInfo.content;
    
    // 计算出内容的高宽
//    CGFloat height = [self neededHeightForDescription: content withTableWidth: contentWidth Font: [UIFont systemFontOfSize: 15] LineBreakMode: UILineBreakModeWordWrap];
    
    OHAttributedLabel *lbContent = [[OHAttributedLabel alloc] init];
    [self creatAttributedLabel: content Label: lbContent];
    CGFloat height = lbContent.frame.size.height;
//    if (height<28) {
//        height = 28;
//    }
//    
//    height += 16;
//    
//    
//    if (0 == indexPath.row)
//    {  // 需要显示时间
//        height += 15;
//    }

    // 返回需要的高度
    return height+30;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [chatInput resignFirstResponder];
    [faceButton setBackgroundImage:[UIImage imageNamed:@"face"] forState:UIControlStateNormal];
    showFaceBoard = NO;
}

- (void)enableSendButton {
    if (sendButton.enabled == NO) {
        sendButton.enabled = YES;
        sendButton.titleLabel.alpha = 1.0f;
    }
}

- (void)disableSendButton {
    if (sendButton.enabled == YES) {
        [self resetSendButton];
    }
}

- (void)resetSendButton {
    sendButton.enabled = NO;
    sendButton.titleLabel.alpha = 0.5f; // Sam S. says 0.4f
}

- (int)wordCount:(NSString*)s
{
    int i,n=[s length],l=0,a=0,b=0;
    unichar c;
    for(i=0;i<n;i++){
        c=[s characterAtIndex:i];
        if(isblank(c)){
            b++;
        }else if(isascii(c)){
            a++;
        }else{
            l++;
        }
    }
    if(a==0 && l==0) return 0;
    return l+(int)ceilf((float)(a+b)/2.0);
}

- (void)scrollToBottomAnimated:(BOOL)animated {
//    NSInteger lastSection = [arrayChat count] - 1;
//    if (lastSection >= 0) {
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow: [[arrayChat objectAtIndex: lastSection] count]-1 inSection: lastSection];
//        [aTableView scrollToRowAtIndexPath:indexPath
//                          atScrollPosition:UITableViewScrollPositionBottom animated:animated];
//    }
    
    if ([arrayChat count] > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow: arrayChat.count-1 inSection: 0];
        [aTableView scrollToRowAtIndexPath:indexPath
                          atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

#pragma mark UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    int length = [self wordCount: textView.text];
    if (length <= kWeiboMaxWordCount && length >= 0) {
        [btnCharacterCount setTitle: [NSString stringWithFormat: @"%d", kWeiboMaxWordCount - length] forState: UIControlStateNormal];
        [btnCharacterCount setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
    }
    else
    {
        [btnCharacterCount setTitle: [NSString stringWithFormat: @"-%d", length - kWeiboMaxWordCount] forState: UIControlStateNormal];
        [btnCharacterCount setTitleColor: [UIColor redColor] forState: UIControlStateNormal];
    }
    
    if (length > 0) {
        UIImage *oldImage = [UIImage imageNamed: @"deleteText.png"];
        UIImage *imageDelete = [oldImage stretchableImageWithLeftCapWidth:2 topCapHeight: 2];
        
        [btnCharacterCount setBackgroundImage: imageDelete forState: UIControlStateNormal];
    }
    else
    {
        [btnCharacterCount setBackgroundImage: nil forState: UIControlStateNormal];
    }
    
    CGFloat contentHeight = textView.contentSize.height - kMessageFontSize + 2.0f;
    NSString *rightTrimmedText = @"";
    
    //    NSLog(@"contentOffset: (%f, %f)", textView.contentOffset.x, textView.contentOffset.y);
    //    NSLog(@"contentInset: %f, %f, %f, %f", textView.contentInset.top, textView.contentInset.right,
    //          textView.contentInset.bottom, textView.contentInset.left);
    //    NSLog(@"contentSize.height: %f", contentHeight);
    
    if ([textView hasText]) {
        rightTrimmedText = [textView.text
                            stringByTrimmingTrailingWhitespaceAndNewlineCharacters];
        
        //        if (textView.text.length > 1024) { // truncate text to 1024 chars
        //            textView.text = [textView.text substringToIndex:1024];
        //        }
        
        // Resize textView to contentHeight
        if (contentHeight != previousContentHeight) {
            if (contentHeight <= kContentHeightMax) { // limit chatInputHeight <= 4 lines
                CGFloat chatBarHeight = contentHeight + 18.0f;
                SET_CHAT_BAR_HEIGHT(chatBarHeight);
                if (previousContentHeight > kContentHeightMax) {
                    textView.scrollEnabled = NO;
                }
                textView.contentOffset = CGPointMake(0.0f, 6.0f); // fix quirk
                [self scrollToBottomAnimated:YES];
                
                if (chatBarHeight > 42) {
                    btnCharacterCount.hidden = NO;
                }
                else
                {
                    btnCharacterCount.hidden = YES;
                }
            }
            else if (previousContentHeight <= kContentHeightMax)
            { // grow
                textView.scrollEnabled = YES;
                textView.contentOffset = CGPointMake(0.0f, contentHeight-68.0f); // shift to bottom
                if (previousContentHeight < kContentHeightMax) {
                    EXPAND_CHAT_BAR_HEIGHT;
                    [self scrollToBottomAnimated:YES];
                }
            }
        }
    } else { // textView is empty
        if (previousContentHeight > 22.0f) {
            RESET_CHAT_BAR_HEIGHT;
            if (previousContentHeight > kContentHeightMax) {
                textView.scrollEnabled = NO;
            }
        }
        textView.contentOffset = CGPointMake(0.0f, 6.0f); // fix quirk
        
        btnCharacterCount.hidden = YES;
    }
    
    // Enable sendButton if chatInput has non-blank text, disable otherwise.
    if (rightTrimmedText.length > 0) {
        [self enableSendButton];
    } else {
        [self disableSendButton];
    }
    
    previousContentHeight = contentHeight;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
