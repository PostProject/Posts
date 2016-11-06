//
//  IPTakeMediaManager.h
//  IPickerDemo
//
//  Created by Wangjianlong on 16/7/3.
//  Copyright © 2016年 JL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

extern NSString *const IPThumbnailCreatedNotification;

@protocol IPTakeMediaManagerDelegate <NSObject>

- (void)deviceConfigurationFailedWithError:(NSError *)error;
- (void)mediaCaptureFailedWithError:(NSError *)error;
- (void)assetLibraryWriteFaileWithError:(NSError *)error;

@end

@interface IPTakeMediaManager : NSObject

/**delegate*/
@property (nonatomic, weak)id<IPTakeMediaManagerDelegate> delegate;

/**会话*/
@property (nonatomic, strong,readonly)AVCaptureSession *captureSession;

- (BOOL)setupSession:(NSError **)error;
- (void)startSession;
- (void)stopSession;

- (BOOL)canSwitchCameras;
- (BOOL)swichCameras;

/**摄像头数量*/
@property (nonatomic, assign,readonly)NSUInteger cameraCount;

/**摄像头含有手电筒*/
@property (nonatomic, assign,readonly)BOOL cameraHasTorch;

/**摄像头含有闪光灯*/
@property (nonatomic, assign,readonly)BOOL cameraHasFlash;

@property (nonatomic, assign,readonly)BOOL cameraSupportTapToFocus;

@property (nonatomic, assign,readonly)BOOL cameraSupportTapToExpose;

@property (nonatomic, assign)AVCaptureTorchMode torchMode;

@property (nonatomic, assign)AVCaptureFlashMode flashMode;

- (void)focusAtPoint:(CGPoint)point;
- (void)exposeAtPoint:(CGPoint)point;
- (void)resetFocusAndExpose;


- (void)captureStillImage;

- (void)startRecording;

@end
