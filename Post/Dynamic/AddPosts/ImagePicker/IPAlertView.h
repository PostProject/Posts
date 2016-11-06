//
//  IPAlertView.h
//  IPickerDemo
//
//  Created by Wangjianlong on 16/3/2.
//  Copyright © 2016年 JL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IPAlertView : UIView
+ (instancetype)showAlertViewAt:(UIView *)view MaxCount:(NSUInteger)count;
+ (instancetype)showAlertViewAt:(UIView *)view Text:(NSString *)text;
- (void)dismissFromHostView;
@end
