//
//  WPDefine.h
//  Post
//
//  Created by 王海鹏 on 16/11/8.
//  Copyright © 2016年 Post. All rights reserved.
//

#ifndef WPDefine_h
#define WPDefine_h

#import "BaseViewController.h"
#import "UIView+WP.h"
#import "UIColor+WP.h"
#import "NSString+WP.h"

//  屏幕宽高
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
#define SINGLE_LINE (1 / [UIScreen mainScreen].scale)

// 获取导航状态栏的高度
#define NavStatusBarHeight 64
// 获取底部tabbar的高度
#define TabBarHeight 49


// 文本字号设置
#define FontSize(font) [UIFont systemFontOfSize:font]


#endif /* WPDefine_h */
