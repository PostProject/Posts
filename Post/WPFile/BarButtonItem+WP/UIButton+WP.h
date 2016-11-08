//
//  UIButton+WP.h
//  NewWelcomeBusiness
//
//  Created by chinalong on 16/8/17.
//  Copyright © 2016年 com.chinalong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (WP)


// 蓝底白字
+ (UIButton *)btnWithFrame:(CGRect)frame target:(id)target action:(SEL)action title:(NSString *)title;

// 语音btn
+ (UIButton *)btnPostYYFrame:(CGRect)frame title:(NSString *)yyTime target:(id)target action:(SEL)action;

@end
