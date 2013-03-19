//
//  DelegateViewController.h
//  Block
//
//  Created by Sky on 12-12-22.
//  Copyright (c) 2012年 Sky. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PassValueDelegate;  // 协议 前向声明
/*
 协议声明类需要实现的的方法，为不同的类提供公用方法，一个类可以有多个协议(ViewController就实现了多个协议)，它类似java中的接口
 
 在C++中经常前向声明一个类,例如需要声明类A和类B，而这两个类需要互相引用，这时候在定义A的时候，B还没有定义，那怎么引用它呢，这时候就需要前向声明(forward declaration)了
 协议的前向声明的作用和类的前向声明是一样的.
*/

@interface DelegateViewController : UITableViewController
{
    __unsafe_unretained id <PassValueDelegate>	_delegate;
    
    NSMutableArray *_arrayEmailSuffix;
    NSString *_emailPrefix;
    
    NSMutableArray *_arrayEmailAddress;
}

@property (assign) id <PassValueDelegate> delegate;

@property (nonatomic, strong) NSMutableArray *arrayEmailSuffix;
@property (nonatomic, strong) NSString *emailPrefix;

- (void)UpdateData;

@end

@protocol PassValueDelegate<NSObject>

@required //  @required是默认的指令,必须要实现的方法
-(void)passSelectMailAddress:(NSString *)selectMail;

@optional //  @optional表示可选择实现的方法
-(void)passDeleteMailAddress:(NSString *)deleteMail;

/*
 命名规则,变量的命名规则很有名的有“匈牙利法则”,不同的开发团队可能有不同的命名规则,但是
 不变的是,命名的宗旨见名思义.
 从@required和@optional的字面意义上就应该可以明白这两个关键字的用法
 */

@end
