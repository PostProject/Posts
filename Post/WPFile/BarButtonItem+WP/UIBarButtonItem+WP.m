//
//  UIBarButtonItem+WP.m
//  NewWelcomeBusiness
//
//  Created by chinalong on 16/8/16.
//  Copyright © 2016年 com.chinalong. All rights reserved.
//

#import "UIBarButtonItem+WP.h"

@implementation UIBarButtonItem (WP)

+ (UIBarButtonItem *)newItemWithTarget:(id)target action:(SEL)action title:(NSString *)title {
    
    CGSize size = [title sizeWithFont:FontSize(15) maxSize:CGSizeMake(100, 30)];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame  =CGRectMake(0, 0, size.width+14, 30);
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithHexString:@"3b3b3b"] forState:UIControlStateNormal];
    btn.titleLabel.font = FontSize(15);
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:btn];
}


+ (UIBarButtonItem *)newItemWithTarget:(id)target action:(SEL)action normalImg:(NSString *)normalImg higLightImg:(NSString *)higLightImg {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 30, 30);
    [btn setImage:[UIImage imageNamed:normalImg] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:higLightImg] forState:UIControlStateHighlighted];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:btn];
}


+ (UIBarButtonItem *)sysItemWithTarget:(id)target action:(SEL)action {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    UIImageView *ivSao = [[UIImageView alloc] initWithFrame:CGRectMake(5, 0, 20, 20)];
    ivSao.image = [UIImage imageNamed:@"SYS"];
    [view addSubview:ivSao];
    
    UILabel *lbSao = [[UILabel alloc] initWithFrame:CGRectMake(0, 22, 30, 10)];
    lbSao.text = @"扫一扫";
    lbSao.textColor = [UIColor colorWithHexString:@"3b3b3b"];
    lbSao.font = FontSize(8);
    lbSao.textAlignment = NSTextAlignmentCenter;
    [view addSubview:lbSao];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 30, 30);
    [view addSubview:btn];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:view];

}


@end
