//
//  AHCaptureProgressBar.h
//  Samples.AHVision
//
//  Created by yuchimin on 14-11-11.
//  Copyright (c) 2014年 com.autohome. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AHCaptureProgressDegelate;

@interface IPCaptureProgressBar : UIView

@property(nonatomic) Float64 maxValue;

@property(nonatomic) Float64 limitValue;

@property(nonatomic,readonly) Float64 currentValue;

@property(nonatomic,readonly) NSInteger segmentCount;

@property(nonatomic,assign) id<AHCaptureProgressDegelate> delegate;

-(void)setProgressValue:(Float64)value;

-(void) interrupt;

-(void) delete:(BOOL)determine;

@end

@protocol AHCaptureProgressDegelate <NSObject>

@optional

-(void) captureProgress:(IPCaptureProgressBar *)sender;

@end
