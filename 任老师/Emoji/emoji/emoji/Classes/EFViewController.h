//
//  EFViewController.h
//  emoji
//
//  Created by Sky on 13-4-23.
//  Copyright (c) 2013年 Sky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EFFaceBoard.h"

@interface EFViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>
{
    NSMutableArray *arrayChat;
    UITableView *aTableView;
    
    UIImageView *chatBar;
    UITextView *chatInput;
    CGFloat previousContentHeight;
    UIButton *sendButton;
    UIButton *btnCharacterCount;
    UIButton *faceButton;
    
    BOOL showFaceBoard;
    BOOL showKeyboard;
    
    EFFaceBoard *faceBoard;
}

@end
