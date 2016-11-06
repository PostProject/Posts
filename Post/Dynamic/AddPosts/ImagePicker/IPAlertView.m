//
//  IPAlertView.m
//  IPickerDemo
//
//  Created by Wangjianlong on 16/3/2.
//  Copyright © 2016年 JL. All rights reserved.
//

#import "IPAlertView.h"

@interface IPAlertView ()
/**定时器*/
@property (nonatomic, strong)NSTimer  *graceTimer;

/**最多可选择的照片数量*/
@property (nonatomic, assign)NSUInteger count;

/**提示文字*/
@property (nonatomic, weak)UILabel *alertLabel;

@end


@implementation IPAlertView

+ (instancetype)showAlertViewAt:(UIView *)view MaxCount:(NSUInteger)count{
    IPAlertView *alert = [[IPAlertView alloc]initWithView:view];
    alert.count = count;
    alert.backgroundColor = [UIColor clearColor];
    [view addSubview:alert];
    [alert showAnimated:YES];
    return alert;
}
- (void)showAnimated:(BOOL)animated {
    
    // If the grace time is set postpone the HUD display
    if (animated) {
        NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(handleGraceTimer:) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        self.graceTimer = timer;
    }
    
}
+ (instancetype)showAlertViewAt:(UIView *)view Text:(NSString *)text{
    IPAlertView *alert = [[IPAlertView alloc]initWithView:view];
    [alert.alertLabel setText:text];
    alert.backgroundColor = [UIColor clearColor];
    [view addSubview:alert];
    [alert showAnimated:NO];
    return alert;
}
- (void)dismissFromHostView{
    [self removeFromSuperview];
}
- (void)handleGraceTimer:(NSTimer *)timer{
    [self removeFromSuperview];
    [self.graceTimer invalidate];
}
- (id)initWithView:(UIView *)view {
    NSAssert(view, @"View must not be nil.");
    return [self initWithFrame:view.bounds];
}
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setUp];
    }
    return self;
}
- (void)setCount:(NSUInteger)count{
    if (_count != count) {
        _count = count;
        [self.alertLabel setText:[NSString stringWithFormat:@"最多可选择%tu张照片",_count]];
    }
}
- (void)setUp{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 80)];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.center = self.center;
    label.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    
    [self addSubview:label];
    self.alertLabel = label;
}
@end
