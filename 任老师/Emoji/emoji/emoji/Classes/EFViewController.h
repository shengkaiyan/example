//
//  EFViewController.h
//  emoji
//
//  Created by Sky on 13-4-23.
//  Copyright (c) 2013年 Sky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EFFaceBoard.h"
#import "OHAttributedLabel.h"
#import <AVFoundation/AVFoundation.h>

@interface EFViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, OHAttributedLabelDelegate, AVAudioPlayerDelegate>
{
    NSDictionary *dictEmoji;
    NSMutableArray *arrayChat;
    UITableView *aTableView;
    
    UIImageView *chatBar;
    UITextView *chatInput;
    CGFloat previousContentHeight;
    UIButton *sendButton;
    UIButton *btnCharacterCount;
    UIButton *faceButton;
    UIButton *voiceButton;
    UIButton *speakButton;
    
    BOOL showFaceBoard;
    BOOL showSpeakingState;
    
    EFFaceBoard *faceBoard;
    
    // record
    NSURL *recordedFile;
    AVAudioPlayer *player;
    AVAudioRecorder *recorder;
    BOOL isRecording;
}

@end
