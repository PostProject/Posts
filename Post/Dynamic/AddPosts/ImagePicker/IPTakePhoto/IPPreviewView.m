//
//  IPPreviewView.m
//  IPickerDemo
//
//  Created by Wangjianlong on 16/7/3.
//  Copyright © 2016年 JL. All rights reserved.
//

#import "IPPreviewView.h"

@interface IPPreviewView ()

@end

@implementation IPPreviewView

/**
 *  替换view 默认展示的类
 */
+(Class)layerClass{
    return [AVCaptureVideoPreviewLayer class];
}

- (void)setDefaultSession:(AVCaptureSession *)defaultSession{
    //将预览层与默认的会话 进行绑定
    [(AVCaptureVideoPreviewLayer *)self.layer setSession:defaultSession];
}

- (AVCaptureSession *)defaultSession{
    return [(AVCaptureVideoPreviewLayer *)self.layer session];
}
/**
 *  将屏幕坐标系上的触控点转换为摄像头坐标系上的点
 *
 *  @param point 屏幕坐标系上的触控点
 *
 *  @return 摄像头坐标系上的点
 */
- (CGPoint)captureDevicePointForPoint:(CGPoint)point{
    AVCaptureVideoPreviewLayer *layer = (AVCaptureVideoPreviewLayer *)self.layer;
    return [layer captureDevicePointOfInterestForPoint:point];
}
/*屏幕坐标系的左上角为(0,0),,右下角为屏幕尺寸.如(320,480)....捕捉设备坐标系是基于摄像头传感器的本地设置,水平方向不可旋转.并且左上角为(0,0),右下角为(1,1)
 captureDevicePointOfInterestForPoint: 获取屏幕坐标系的CGPoint数据,返回转换得到的设备坐标系CGPoint数据
 pointForCaptureDevicePointOfInterest: 获取摄像头坐标系的CGPoint数据,返回转换得到的屏幕坐标系CGPoint数据
 */
@end
