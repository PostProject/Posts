//
//  UIButton+WP.m
//  NewWelcomeBusiness
//
//  Created by chinalong on 16/8/17.
//  Copyright © 2016年 com.chinalong. All rights reserved.
//

#import "UIButton+WP.h"

@implementation UIButton (WP)

// view底部btn
+ (UIButton *)newBtnWithTarget:(id)target action:(SEL)action title:(NSString *)title {

    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(0, ScreenHeight-TabBarHeight-NavStatusBarHeight, ScreenWidth, TabBarHeight);
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = FontSize(18);
    button.backgroundColor = [UIColor colorWithHexString:@"fc4349"];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}


// 白底红字红边框
+ (UIButton *)whiteWithFrame:(CGRect)frame target:(id)target action:(SEL)action title:(NSString *)title {
    
    UIButton *myButton = [UIButton buttonWithType:UIButtonTypeSystem];
    myButton.frame = frame;
    myButton.backgroundColor = [UIColor whiteColor];
    [myButton setTitleColor:[UIColor colorWithHexString:@"fc4349"] forState:UIControlStateNormal];
    [myButton setTitle:title forState:UIControlStateNormal];
    myButton.titleLabel.font = FontSize(18);
    myButton.layer.cornerRadius = 5;
    myButton.layer.masksToBounds = YES;
    myButton.layer.borderColor = [UIColor colorWithHexString:@"fc4349"].CGColor;
    myButton.layer.borderWidth = SINGLE_LINE;
    [myButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    return myButton;
}



// 白底黑字黑边框
+ (UIButton *)txtBlackWithFrame:(CGRect)frame target:(id)target action:(SEL)action title:(NSString *)title {
    
    UIButton *myButton = [UIButton buttonWithType:UIButtonTypeSystem];
    myButton.frame = frame;
    myButton.backgroundColor = [UIColor whiteColor];
    [myButton setTitleColor:[UIColor colorWithHexString:@"fc4349"] forState:UIControlStateNormal];
    [myButton setTitle:title forState:UIControlStateNormal];
    myButton.titleLabel.font = FontSize(18);
    myButton.layer.cornerRadius = 5;
    myButton.layer.masksToBounds = YES;
    myButton.layer.borderColor = [UIColor colorWithHexString:@"fc4349"].CGColor;
    myButton.layer.borderWidth = SINGLE_LINE;
    [myButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    return myButton;
}










#pragma mark --  蓝底白字
+ (UIButton *)btnWithFrame:(CGRect)frame target:(id)target action:(SEL)action title:(NSString *)title {
    
    UIButton *myButton = [UIButton buttonWithType:UIButtonTypeSystem];
    myButton.frame = frame;
    myButton.backgroundColor = [UIColor colorWithR:60 G:120 B:90 A:1];
    [myButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [myButton setTitle:title forState:UIControlStateNormal];
    myButton.titleLabel.font = FontSize(18);
    myButton.layer.cornerRadius = 5;
    myButton.layer.masksToBounds = YES;
    myButton.layer.shouldRasterize = YES;
    myButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
    [myButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return myButton;
}


#pragma mark --  语音
+ (UIButton *)btnPostYYFrame:(CGRect)frame title:(NSString *)yyTime target:(id)target action:(SEL)action {

    UIButton *btnYY = [UIButton buttonWithType:UIButtonTypeCustom];
    btnYY.frame = frame;
    btnYY.layer.cornerRadius = 15;
    btnYY.layer.masksToBounds = YES;
    btnYY.layer.shouldRasterize = YES;
    btnYY.layer.rasterizationScale = [UIScreen mainScreen].scale;
    btnYY.backgroundColor = [UIColor colorWithHexString:@"ebebeb"];
    [btnYY setImage:[UIImage imageNamed:@"yuyinLength"] forState:UIControlStateNormal];
    [btnYY setTitle:yyTime forState:UIControlStateNormal];
    [btnYY setTitleColor:[UIColor colorWithHexString:@"888888"] forState:UIControlStateNormal];
    return btnYY;
}







@end
