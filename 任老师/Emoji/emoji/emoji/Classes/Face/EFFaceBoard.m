//
//  EFFaceBoard.m
//  emoji
//
//  Created by Sky on 13-4-23.
//  Copyright (c) 2013年 Sky. All rights reserved.
//

#import "EFFaceBoard.h"
#import "Emoji.h"

@implementation EFFaceBoard
@synthesize inputTextField;
@synthesize inputTextView;

const float BUTTON_WIDTH = 106;
const float BUTTON_HEIGHT = 30;

- (id)initWithMultiFaceType:(BOOL)hasMultiFaceType DefaultFaceType:(FaceType)defaultFaceType
{
    self = [super initWithFrame:CGRectMake(0, 0, 320, 216)];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:243.0/255.0 green:243.0/255.0 blue:243.0/255.0 alpha:1];
        
        // init system face
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
        if ([[languages objectAtIndex:0] hasPrefix:@"zh"]) {
            dictFaceImage = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"faceMap_ch" ofType:@"plist"]];
        } else {
            dictFaceImage = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"faceMap_en" ofType:@"plist"]];
        }
        
        // init image face
        arrayFaceSystem = [Emoji allEmoji];
        
        faceType = defaultFaceType;
        isMultiFaceType = hasMultiFaceType;
        
        //创建表情键盘
        faceScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
        [faceScrollView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"facesBack"]]];
        [faceScrollView setShowsVerticalScrollIndicator:NO];
        [faceScrollView setShowsHorizontalScrollIndicator:NO];
        faceScrollView.pagingEnabled=YES;
        faceScrollView.delegate=self;
        [self addSubview:faceScrollView];
        
        //添加PageControl
        facePageControl = [[GrayPageControl alloc]initWithFrame: CGRectZero];
        [facePageControl addTarget:self
                            action:@selector(pageChange:)
                  forControlEvents:UIControlEventValueChanged];
        facePageControl.currentPage = 0;

        [self addSubview:facePageControl];
        
        if (isMultiFaceType) {
            btnSystem = [UIButton buttonWithType: UIButtonTypeCustom];
            btnSystem.frame = CGRectMake(0, 216-BUTTON_HEIGHT, BUTTON_WIDTH, BUTTON_HEIGHT);
            btnSystem.tag = Face_system;
            [btnSystem setTitle: @"系统表情" forState: UIControlStateNormal];
            [btnSystem addTarget: self action: @selector(ChangeFace:) forControlEvents: UIControlEventTouchUpInside];
            [self addSubview: btnSystem];
            
            btnImage = [UIButton buttonWithType: UIButtonTypeCustom];
            btnImage.frame = CGRectMake(BUTTON_WIDTH+1, 216-BUTTON_HEIGHT, BUTTON_WIDTH, BUTTON_HEIGHT);
            btnImage.tag = Face_image;
            [btnImage setTitle: @"图像表情" forState: UIControlStateNormal];
            [btnImage addTarget: self action: @selector(ChangeFace:) forControlEvents: UIControlEventTouchUpInside];
            [self addSubview: btnImage];
            
            btnGif = [UIButton buttonWithType: UIButtonTypeCustom];
            btnGif.frame = CGRectMake(BUTTON_WIDTH*2+2, 216-BUTTON_HEIGHT, BUTTON_WIDTH, BUTTON_HEIGHT);
            btnGif.tag = Face_gif;
            [btnGif setTitle: @"结伴表情" forState: UIControlStateNormal];
            [btnGif addTarget: self action: @selector(ChangeFace:) forControlEvents: UIControlEventTouchUpInside];
            [self addSubview: btnGif];
            
            [self LoadButton];
        }
        else
        {
            [self LoadFace];
        }
//        UILabel *lbtext = [[UILabel alloc] initWithFrame: CGRectMake(20, 20, 200, 30)];
//        lbtext.text = @"Hello world";
//        [self addSubview: lbtext];
        

    }
    
    return self;
}

- (void)LoadButton
{
    switch (faceType) {
        case Face_system:
        {
            [btnSystem setBackgroundColor: [UIColor grayColor]];
            
            [btnImage setBackgroundColor: [UIColor clearColor]];
            [btnGif setBackgroundColor: [UIColor clearColor]];
        }
            break;
        
        case Face_image:
        {
            [btnImage setBackgroundColor: [UIColor grayColor]];
            
            [btnSystem setBackgroundColor: [UIColor clearColor]];
            [btnGif setBackgroundColor: [UIColor clearColor]];
        }
            break;
            
        case Face_gif:
        {
            [btnGif setBackgroundColor: [UIColor grayColor]];
            
            [btnSystem setBackgroundColor: [UIColor clearColor]];
            [btnImage setBackgroundColor: [UIColor clearColor]];
        }
            break;
        
        default:
            break;
    }
    
    facePageControl.hidden = YES;
    [self LoadFace];
}

- (void)ChangeFace:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    
    if (btn.tag == faceType) {
        return;
    }
    
    faceType = btn.tag;
    [self LoadButton];
}


- (void)LoadFace
{
    int xCount = 0;
    int yCount = 0;
    int pageCount = 0;
    int FaceWidth = 0;
    int FaceHeight = 0;
    CGFloat pageHeight = 216;
    
    for(UIView *view in faceScrollView.subviews)
    {
        if ([view isKindOfClass: [UIButton class]]) {
            [view removeFromSuperview];
        }
    }
    
    switch (faceType) {
        case Face_system:
        {
            FaceWidth = 33;
            FaceHeight = 33;
            
            if (isMultiFaceType) {
                xCount = 9;
                yCount = 4;
                pageHeight -= 30;
                
                facePageControl.frame = CGRectMake(0, 216-30-35, 320, 30);
            }
            else
            {
                xCount = 9;
                yCount = 5;
                
                facePageControl.frame = CGRectMake(0, 216-35, 320, 30);
            }
            
            pageCount = xCount*yCount;
            
            int allFaceCount = [arrayFaceSystem count];
            
            int allDeleteButtonCount = allFaceCount/pageCount;
            if (allFaceCount%pageCount) {
                allDeleteButtonCount++;
            }
            
            int allPage = (allFaceCount+allDeleteButtonCount)/pageCount;
            if ((allFaceCount+allDeleteButtonCount) % pageCount) {
                allPage++;
            }
            
            facePageControl.numberOfPages = allPage;//指定页面个数
            if (allPage > 1) {
                facePageControl.hidden = NO;
                facePageControl.currentPage = 0;
            }
            else
            {
                facePageControl.hidden = YES;
            }
            
            [faceScrollView setContentSize: CGSizeMake(320*allPage, pageHeight)];
            
            int cursor = 0;
            int tag = 0;
            for (; tag<=allFaceCount; ) {
                cursor++;
                
                if (cursor > 22) {
                    ;
                }
                
                CGFloat x = (((cursor-1) % pageCount) % xCount)*FaceWidth+((cursor-1)/pageCount*320);
                CGFloat y = (((cursor-1) % pageCount) / xCount)*FaceHeight;
                
                UIButton *faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
                faceButton.tag = tag;
                //计算每一个表情按钮的坐标和在哪一屏
                faceButton.frame = CGRectMake(x+12, y+4, FaceWidth, FaceHeight);
                [faceScrollView addSubview:faceButton];
                
                if (0 == cursor%pageCount || tag == allFaceCount) {
                    [faceButton setImage:[UIImage imageNamed:@"backFace"] forState:UIControlStateNormal];
                    [faceButton setImage:[UIImage imageNamed:@"backFaceSelect"] forState:UIControlStateSelected];
                    
                    [faceButton addTarget:self
                                   action:@selector(backFace)
                         forControlEvents:UIControlEventTouchUpInside];
                    
                    if (tag == allFaceCount) {
                        tag++;
                    }
                    
                    continue;
                }
                
                [faceButton addTarget:self
                               action:@selector(faceButton:)
                     forControlEvents:UIControlEventTouchUpInside];
                
                [faceButton.titleLabel setFont:[UIFont fontWithName:@"AppleColorEmoji" size:29.0]];
                [faceButton setTitle: [arrayFaceSystem objectAtIndex: tag] forState:UIControlStateNormal];
                
                tag++;
            }
        }
            break;
            
        case Face_image:
        {
            FaceWidth = 44;
            FaceHeight = 44;
            
            if (isMultiFaceType) {
                xCount = 7;
                yCount = 3;
                pageHeight -= 30;
                
                facePageControl.frame = CGRectMake(0, 216-30-35, 320, 30);
            }
            else
            {
                xCount = 7;
                yCount = 4;
                
                facePageControl.frame = CGRectMake(0, 216-35, 320, 30);
            }
            
            pageCount = xCount*yCount;
            
            int allFaceCount = [[dictFaceImage allKeys] count];
            
            int allDeleteButtonCount = allFaceCount/pageCount;
            if (allFaceCount%pageCount) {
                allDeleteButtonCount++;
            }
            
            int allPage = (allFaceCount+allDeleteButtonCount)/pageCount;
            if ((allFaceCount+allDeleteButtonCount) % pageCount) {
                allPage++;
            }
            
            facePageControl.numberOfPages = allPage;//指定页面个数
            if (allPage > 1) {
                facePageControl.hidden = NO;
                facePageControl.currentPage = 0;
            }
            else
            {
                facePageControl.hidden = YES;
            }
            
            [faceScrollView setContentSize: CGSizeMake(320*allPage, pageHeight)];
            
            int cursor = 0;
            int tag = 1;
            for (; tag<=allFaceCount+1; ) {
                cursor++;
                
                if (cursor > 22) {
                    ;
                }
                
                CGFloat x = (((cursor-1) % pageCount) % xCount)*FaceWidth+((cursor-1)/pageCount*320);
                CGFloat y = (((cursor-1) % pageCount) / xCount)*FaceHeight;
                
                UIButton *faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
                faceButton.tag = tag;
                //计算每一个表情按钮的坐标和在哪一屏
                faceButton.frame = CGRectMake(x+6, y+8, FaceWidth, FaceHeight);
                [faceScrollView addSubview:faceButton];
                
                if (0 == cursor%pageCount || tag == allFaceCount+1) {
                    [faceButton setImage:[UIImage imageNamed:@"backFace"] forState:UIControlStateNormal];
                    [faceButton setImage:[UIImage imageNamed:@"backFaceSelect"] forState:UIControlStateSelected];
                    
                    [faceButton addTarget:self
                                   action:@selector(backFace)
                         forControlEvents:UIControlEventTouchUpInside];
                    
                    if (tag == allFaceCount+1) {
                        tag++;
                    }
                    
                    continue;
                }
                
                [faceButton addTarget:self
                               action:@selector(faceButton:)
                     forControlEvents:UIControlEventTouchUpInside];

                [faceButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%03d",tag]] forState:UIControlStateNormal];
                
                tag++;
            }
        }
            break;
            
        case Face_gif:
        {
            ;
        }
            break;
            
        default:
            break;
    }
}

//停止滚动的时候
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [facePageControl setCurrentPage: scrollView.contentOffset.x/320];
    [facePageControl updateCurrentPageDisplay];
}

- (void)pageChange:(id)sender {
    [faceScrollView setContentOffset:CGPointMake(facePageControl.currentPage*320, 0) animated:YES];
    [facePageControl setCurrentPage:facePageControl.currentPage];
}

- (void)faceButton:(id)sender {
    int tag = ((UIButton*)sender).tag;
    NSMutableString *faceString = nil;
    
    if (self.inputTextField) {
        faceString = [[NSMutableString alloc]initWithString:self.inputTextField.text];
    }
    else if (self.inputTextView) {
        faceString = [[NSMutableString alloc]initWithString:self.inputTextView.text];
    }
    
    switch (faceType) {
        case Face_system:
        {
            [faceString appendString: [arrayFaceSystem objectAtIndex: tag]];
        }
            break;
            
        case Face_image:
        {
            [faceString appendString:[dictFaceImage objectForKey:[NSString stringWithFormat:@"%03d", tag]]];
        }
            break;
            
        case Face_gif:
        {
            ;
        }
            break;
            
        default:
            break;
    }
    
    if (self.inputTextField) {
        self.inputTextField.text = faceString;
    }
    else if (self.inputTextView) {
        self.inputTextView.text = faceString;
    }
}

- (void)backFace{
    NSString *inputString;
    inputString = self.inputTextField.text;
    if (self.inputTextView) {
        inputString = self.inputTextView.text;
    }
    
    NSString *string = nil;
    NSInteger stringLength = inputString.length;
    if (stringLength > 0) {
        if ([@"]" isEqualToString:[inputString substringFromIndex:stringLength-1]]) {
            if ([inputString rangeOfString:@"["].location == NSNotFound){
                string = [inputString substringToIndex:stringLength - 1];
            } else {
                string = [inputString substringToIndex:[inputString rangeOfString:@"[" options:NSBackwardsSearch].location];
            }
        } else {
            string = [inputString substringToIndex:stringLength - 1];
        }
    }
    self.inputTextField.text = string;
    self.inputTextView.text = string;
}

@end
