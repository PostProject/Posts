//
//  IPPreviewView.h
//  IPickerDemo
//
//  Created by Wangjianlong on 16/7/3.
//  Copyright © 2016年 JL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol IPPreviewViewDelegate <NSObject>
/**
 *  点击聚焦
 *
 *  @param point point description
 */
- (void)tappedToFocusAtPoint:(CGPoint)point;
/**
 *  点击曝光
 *
 *  @param point point description
 */
- (void)tappedToFocusExposeAtPoint:(CGPoint)point;
/**
 *  重置 曝光和聚焦
 */
- (void)tappedToResetFocusAndExpose;

@end


@interface IPPreviewView : UIView

/**session*/
@property (nonatomic, weak)AVCaptureSession *defaultSession;

/**代理*/
@property (nonatomic, weak)id<IPPreviewViewDelegate> delegate;

/**支持点击聚焦*/
@property (nonatomic, assign)BOOL tapToFocusEnabled;

/**支持点击曝光*/
@property (nonatomic, assign)BOOL tapToExposeEnabled;

@end
