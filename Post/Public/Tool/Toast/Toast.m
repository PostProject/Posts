//
//  Toast.m
//  进度环
//
//  Created by apple on 15/8/3.
//  Copyright (c) 2015年 蓝桥杯. All rights reserved.
//

#import "Toast.h"
#import "AppDelegate.h"

Toast *singleToast=nil;

@implementation Toast
+(Toast *)shareToast{
    @synchronized(self){
        if (singleToast==nil) {
            singleToast=[[Toast alloc] init];
        }
    }
    return singleToast;
}

-(void)showContent:(NSString *)Content adTime:(int)time{
    if (!showControl) {
        showControl=YES;
        UIFont *font=[UIFont systemFontOfSize:14];
        CGRect rect=[Content boundingRectWithSize:CGSizeMake(200, 500) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
        
        toastView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width+30, rect.size.height + 30)];
        toastView.backgroundColor=[UIColor blackColor];
        toastView.alpha=0.9;
        toastView.center=CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2 - 80);
        toastView.layer.cornerRadius=5;
        toastView.layer.masksToBounds=YES;
        lbContent=[[UILabel alloc] initWithFrame:CGRectMake(0,0,rect.size.width, rect.size.height)];
        lbContent.text=Content;
        lbContent.center=CGPointMake(toastView.frame.size.width/2, toastView.frame.size.height/2);
        lbContent.textColor=[UIColor whiteColor];
        lbContent.numberOfLines=0;
        lbContent.textAlignment=NSTextAlignmentCenter;
        lbContent.font=font;
//        lbContent.backgroundColor=[UIColor redColor];
        
        [toastView addSubview:lbContent];
        AppDelegate *delegate=(AppDelegate*)[UIApplication sharedApplication].delegate;
        [delegate.window addSubview:toastView];
//    NSLog(@"%@",toastView);
        timer=[NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(closeToast) userInfo:nil repeats:NO];
    
    }else{
        [timer invalidate];
        UIFont *font=[UIFont systemFontOfSize:14];
        CGRect rect=[Content boundingRectWithSize:CGSizeMake(200, 100) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
        toastView.frame=CGRectMake(0, 0, rect.size.width+30, rect.size.height+30);
        toastView.center=CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2 - 80);
        lbContent.frame=CGRectMake(0,0,rect.size.width, rect.size.height );
        lbContent.text=Content;
        lbContent.center=CGPointMake(toastView.frame.size.width/2, toastView.frame.size.height/2);
        timer=[NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(closeToast) userInfo:nil repeats:NO];
        
    }

    
}
-(void)closeToast{
//    int count=1;
//    count++;
//    NSLog(@"%i",count);
    showControl=NO;
    [toastView removeFromSuperview];
    
}

@end
