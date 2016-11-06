//
//  Tost.h
//  进度环
//
//  Created by apple on 15/8/3.
//  Copyright (c) 2015年 蓝桥杯. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface Toast : NSObject
{
    NSString *_strContent;
    int _time;
//    UIView *_toastView;
    UIView *toastView;
    UILabel *lbContent;
    BOOL showControl;
    NSTimer *timer;
    
}
+(Toast*)shareToast;
-(void)showContent:(NSString*)Content adTime:(int)time;

@end
