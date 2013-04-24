//
//  EFFaceBoard.h
//  emoji
//
//  Created by Sky on 13-4-23.
//  Copyright (c) 2013年 Sky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GrayPageControl.h"

typedef enum {
	Face_system = 1,
	Face_image,
	Face_gif
}
FaceType;

@interface EFFaceBoard : UIView<UIScrollViewDelegate>{
    UIScrollView *faceScrollView;
    GrayPageControl *facePageControl;
    FaceType faceType;
    
    UIButton *btnSystem;
    UIButton *btnImage;
    UIButton *btnGif;
    
    BOOL isMultiFaceType;
    
    NSArray *arrayFaceSystem;
    NSDictionary *dictFaceImage;
    NSMutableArray *arrayFaceGif;
}

@property (nonatomic, strong) UITextField *inputTextField;
@property (nonatomic, strong) UITextView *inputTextView;

- (id)initWithMultiFaceType:(BOOL)isMultiFaceType DefaultFaceType:(FaceType)defaultFaceType;

@end