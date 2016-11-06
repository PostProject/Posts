//
//  IPTakeMediaManager.m
//  IPickerDemo
//
//  Created by Wangjianlong on 16/7/3.
//  Copyright © 2016年 JL. All rights reserved.
//

#import "IPTakeMediaManager.h"
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface IPTakeMediaManager ()<AVCaptureFileOutputRecordingDelegate>

/**
 *  AVCaptureSession 是AVFoundation捕捉栈的核心类.一个捕捉会话相当于一个虚拟的插线板,用于连接输入和输出的资源.捕捉会话管理从物理设备得到的数据流,比如摄像头和麦克风设备,输出到一个或多个目的地,可以动态配置输入和输出的线路,让开发者能够在会话进行中按需重新配置捕捉环境
 */
@property (nonatomic, strong,readwrite)AVCaptureSession *captureSession;

/**
 *  AVCaptureDevice 为诸如摄像头或麦克风等物理设备定义了一个接口.多数情况下,这些设备都内置于mac,iPhone,iPad中,但也可能是外部数码相机或便携式摄像机.
 
 *  定义了大量类方法用于访问系统的捕捉设备,最常用的一个方法是: deviceInputWithDevice:
 *
 *
 *  注意:   在使用捕捉设备进行处理前,首先需要将它添加为捕捉会话的输入.不过一个捕捉设备不能直接添加到AVCaptureSession中,可以将之封装到一个AVCaptureDeviceInput实例中.这个对象在设备输出数据和捕捉会话间扮演接线板的作用
 */
@property (nonatomic, strong)AVCaptureDevice *videoDevice;

/**
 *  AVFondation 定义了AVCaptureOutput许多扩展类...AVCaptureOutput是抽象基类,用于为从捕捉会话得到的数据寻找输出目的地...扩展类AVCaptureStillImageOutput和AVCaptureMovieFileOutput,使用它们可以很容易地实现捕捉静态照片和视频的功能.还可以在这里找到底层扩展:AVCaptureVideoDataOutput,,,AVCaptureAudioDataOutput..使用这些底层输出类需要对捕捉设备的数据渲染有更好的理解,不过这些类可以提供更强大的功能,比如可以对音视频流,进行实时处理.
 */
@property (nonatomic, strong)AVCaptureStillImageOutput *imgOutput;

@property (nonatomic, strong)AVCaptureMovieFileOutput *movieOutput;

/**active*/
@property (nonatomic, strong)AVCaptureDeviceInput *activeInput;
/**
 *  捕捉连接::捕捉会话首先需要确定由给定捕捉设备输入渲染的媒体类型,并自动建立其到能够接收该媒体类型的捕捉输出端的连接.比如AVCaptureMovieFileOutput可以接受音频和视频数据,所以会话会确定哪些输入产生视频,哪些产生音频,并正确地建立该连接.对这些连接的访问可以让开发者对信号流进行底层的控制
 */


/**
 *  捕捉预览层; 预览层是一个core animation 的CALayer子类,对捕捉视频数据进行实时预览.这个类类似于AVPlayerLayer.
 */

/**videoqueue*/
@property (nonatomic, strong)dispatch_queue_t videoQueue;

/**<#说明#>*/
@property (nonatomic, copy)NSURL *outputURL;
@end
@implementation IPTakeMediaManager


- (BOOL)setupSession:(NSError **)error{
    
    _captureSession = [[AVCaptureSession alloc]init];
    _videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];

    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:_videoDevice error:error];
    if (videoInput) {
        if ([_captureSession canAddInput:videoInput]) {
            [_captureSession addInput:videoInput];
            self.activeInput = videoInput;
        }
    }else {
        return NO;
    }
    
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:error];
    if (audioInput) {
        if ([_captureSession canAddInput:audioInput]) {
            [_captureSession addInput:audioInput];
        }
    }else {
        return NO;
    }
    
    
    _imgOutput = [[AVCaptureStillImageOutput alloc]init];
    _imgOutput.outputSettings = @{AVVideoCodecKey : AVVideoCodecJPEG};
    
    if ([_captureSession canAddOutput:_imgOutput]) {
        [_captureSession addOutput:_imgOutput];
    }
    
    _movieOutput = [[AVCaptureMovieFileOutput alloc]init];
    
    if ([_captureSession canAddOutput:_movieOutput]) {
        [_captureSession addOutput:_movieOutput];
    }
    
    _videoQueue = dispatch_queue_create("ipimagePicker.takevideo", NULL);
    
    return YES;
}
- (void)startSession{
    if (![self.captureSession isRunning]) {
        dispatch_async(_videoQueue, ^{
            //这是同步调用,并会消耗一定时间,要在异步线程执行
            [self.captureSession startRunning];
        });
    }
}
- (void)stopSession{
    if ([self.captureSession isRunning]) {
        dispatch_async(_videoQueue, ^{
            [self.captureSession stopRunning];
        });
    }
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}
- (AVCaptureDevice *)activeCamera{
    return self.activeInput.device;
}
- (NSUInteger)cameraCount{
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}
/**
 *  获得尚未激活的摄像头
 */
- (AVCaptureDevice *)inactiveCamera{
    AVCaptureDevice *device = nil;
    if (self.cameraCount > 1) {
        if ([self activeCamera].position == AVCaptureDevicePositionBack) {
            device = [self cameraWithPosition:AVCaptureDevicePositionFront];
        } else {
            device = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }
    }
    return device;
}



- (BOOL)canSwitchCameras{
    return self.cameraCount > 1;
}
- (BOOL)swichCameras{
    if (![self canSwitchCameras]) {
        return NO;
    }
    NSError *error;
    AVCaptureDevice *inactiveDevcie = [self inactiveCamera];
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:inactiveDevcie error:&error];
    if (input) {
        //我们对会话进行任何改变,都要通过 beginConfiguration 和 commitConfiguration 进行单独的,原子性的变化
        [self.captureSession beginConfiguration];
        
        [self.captureSession removeInput:self.activeInput];
        
        if ([self.captureSession canAddInput:input]) {
            [self.captureSession addInput:input];
            self.activeInput = input;
        }else {
            [self.captureSession addInput:self.activeInput];
        }
        
        [self.captureSession commitConfiguration];
    }else {
        [self.delegate deviceConfigurationFailedWithError:error];
        return NO;
    }
    return YES;
}
#pragma mark - focus
- (BOOL)cameraSupportTapToFocus{
    return [[self activeCamera] isFocusPointOfInterestSupported];
}
/**
 *  对焦到指定点
 *
 */
- (void)focusAtPoint:(CGPoint)point{
    AVCaptureDevice *activeDevcie = [self activeCamera];
    if ([activeDevcie isFocusPointOfInterestSupported] && [activeDevcie isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([activeDevcie lockForConfiguration:&error]) {
            //锁定设备准备配置.如果获得了锁,将focusPointOfInterest 属性设置为传进来的CGPoint值,设置对焦模式为AVCaptureFocusModeAutoFocus.最后调用unlockForConfiguration 释放该锁定
            activeDevcie.focusPointOfInterest = point;
            activeDevcie.focusMode = AVCaptureFocusModeAutoFocus;
            [activeDevcie unlockForConfiguration];
        }else {
            [self.delegate deviceConfigurationFailedWithError:error];
        }
    }
}

#pragma mark - exposur
- (BOOL)cameraSupportTapToExpose{
    return [[self activeCamera] isExposurePointOfInterestSupported];
}
static const NSString *IPCameraAdjustingExposureContext;

- (void)exposeAtPoint:(CGPoint)point{
    AVCaptureDevice *activeDevcie = [self activeCamera];
    if ([activeDevcie isExposurePointOfInterestSupported] && [activeDevcie isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
        NSError *error;
        if ([activeDevcie lockForConfiguration:&error]) {
            //锁定设备准备配置.如果获得了锁,将focusPointOfInterest 属性设置为传进来的CGPoint值,设置对焦模式为AVCaptureFocusModeAutoFocus.最后调用unlockForConfiguration 释放该锁定
            activeDevcie.exposurePointOfInterest = point;
            activeDevcie.exposureMode = AVCaptureExposureModeAutoExpose;
            if ([activeDevcie isExposureModeSupported:AVCaptureExposureModeLocked]) {
                [activeDevcie addObserver:self forKeyPath:@"adjustingExpose" options:NSKeyValueObservingOptionNew context:&IPCameraAdjustingExposureContext];
            }
            [activeDevcie unlockForConfiguration];
        }else {
            [self.delegate deviceConfigurationFailedWithError:error];
        }
    }
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if (context == &IPCameraAdjustingExposureContext) {
        AVCaptureDevice *device = (AVCaptureDevice *)object;
        if (!device.isAdjustingExposure && [device isExposureModeSupported:AVCaptureExposureModeLocked]) {
            [object removeObserver:self name:@"adjustingExpose" object:IPCameraAdjustingExposureContext];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error;
                if ([device lockForConfiguration:&error]) {
                    device.exposureMode = AVCaptureExposureModeLocked;
                    [device unlockForConfiguration];
                }else {
                    [self.delegate deviceConfigurationFailedWithError:error];
                }
            });
        }
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)resetFocusAndExpose{
    AVCaptureDevice *activeDevcie = [self activeCamera];
    BOOL canResetFocus = [activeDevcie isFocusPointOfInterestSupported] && [activeDevcie isFocusModeSupported:AVCaptureFocusModeAutoFocus];
    
    BOOL canResetExposure = [activeDevcie isExposurePointOfInterestSupported] && [activeDevcie isExposureModeSupported:AVCaptureExposureModeAutoExpose];
    
    CGPoint centerPoint = CGPointMake(0.5, 0.5);
    
    NSError *error;
    //锁定设备准备配置
    if ([activeDevcie lockForConfiguration:&error]) {
        if (canResetFocus) {
            activeDevcie.focusMode = AVCaptureFocusModeAutoFocus;
            activeDevcie.focusPointOfInterest = centerPoint;
        }
        
        if (canResetExposure) {
            activeDevcie.exposureMode = AVCaptureExposureModeAutoExpose;
            activeDevcie.exposurePointOfInterest = centerPoint;
        }
        [activeDevcie unlockForConfiguration];
    }else {
        [self.delegate deviceConfigurationFailedWithError:error];
    }
    
}

/*
 AVCaptureDevice 可以让开发者修改摄像头的闪光灯和手电筒模式.设备后面的LED灯当拍摄静态图片时作为闪光灯,拍摄视频时,用作连续灯光(手电筒).捕捉设备的flashMode和torchMode属性可以被设置为以下三个值:
 > AVCaptureModeOn
 > AVCaptureModeOff
 > AVCaptureModeAuto
 */
- (BOOL)cameraHasFlash{
    return [[self activeCamera] hasFlash];
}

- (AVCaptureFlashMode)flashMode{
    return [[self activeCamera] flashMode];
}
- (void)setFlashMode:(AVCaptureFlashMode)flashMode{
    AVCaptureDevice *activeDevcie = [self activeCamera];
    if ([activeDevcie isFlashModeSupported:flashMode]) {
        NSError *error;
        if ([activeDevcie lockForConfiguration:&error]) {
            activeDevcie.flashMode = flashMode;
            [activeDevcie unlockForConfiguration];
        } else {
            [self.delegate deviceConfigurationFailedWithError:error];
        }
        
    }
}

- (BOOL)cameraHasTorch{
    return [[self activeCamera]hasTorch];
}
- (AVCaptureTorchMode)torchMode{
    return [[self activeCamera] torchMode];
}
- (void)setTorchMode:(AVCaptureTorchMode)torchMode{
    AVCaptureDevice *activeDevcie = [self activeCamera];
    if ([activeDevcie isTorchModeSupported:torchMode]) {
        NSError *error;
        if ([activeDevcie lockForConfiguration:&error]) {
            activeDevcie.torchMode = torchMode;
            [activeDevcie unlockForConfiguration];
        } else {
            [self.delegate deviceConfigurationFailedWithError:error];
        }
        
    }
}
- (AVCaptureVideoOrientation)currentVideoOrientation{
    AVCaptureVideoOrientation orientation;
    switch ([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationPortrait:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationLandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        default:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
    }
    return orientation;
}
- (void)captureStillImage{
    AVCaptureConnection *connection = [self.imgOutput connectionWithMediaType:AVMediaTypeVideo];
    if (connection.isVideoOrientationSupported) {
        connection.videoOrientation = [self currentVideoOrientation];
    }
    
    id handler = ^(CMSampleBufferRef sampleBuffer,NSError *error){
        if (sampleBuffer != NULL) {
            NSData *imgData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:sampleBuffer];
            UIImage *image = [[UIImage alloc]initWithData:imgData];
            [self writImageToSavePhotosAlbum:image];
        }else {
            NSLog(@"NULL sampleBuffer:%@",[error localizedDescription]);
        }
    };
    [self.imgOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:handler];
}
- (void)postThumbnailNotification:(UIImage *)image{
    
}
- (void)writImageToSavePhotosAlbum:(UIImage *)image{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc]init];
    
    [library writeImageToSavedPhotosAlbum:image.CGImage orientation:(NSInteger)image.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
        if (!error) {
            [self postThumbnailNotification:image];
        }
    }];
}

- (BOOL)isRecording{
    return self.movieOutput.isRecording;
}
- (void)startRecording{
    if (![self isRecording]) {
        AVCaptureConnection *connection = [self.movieOutput connectionWithMediaType:AVMediaTypeVideo];
        if ([connection isVideoOrientationSupported]) {
            connection.videoOrientation = [self currentVideoOrientation];
        }
        if ([connection isVideoStabilizationSupported]) {
            //支持视频稳定可以显著提升捕捉到的视频质量...视频稳定只在录制视频文件时才会涉及.
            connection.enablesVideoStabilizationWhenAvailable = YES;
        }
    }
    AVCaptureDevice *activeDevcie = [self activeCamera];
    if (activeDevcie.isSmoothAutoFocusSupported) {
        NSError *error;
        if ([activeDevcie lockForConfiguration:&error]) {
            activeDevcie.smoothAutoFocusEnabled = YES;
            [activeDevcie unlockForConfiguration];
        }else {
            [self.delegate deviceConfigurationFailedWithError:error];
        }
    }
    
    self.outputURL  = nil;
    [self.movieOutput startRecordingToOutputFileURL:self.outputURL recordingDelegate:self];
}
- (NSURL *)uniqueURL{
    NSFileManager *filemanager = [NSFileManager defaultManager];
    NSString *dirPath = @"";
    if (dirPath) {
        NSString *filePath = [dirPath stringByAppendingPathComponent:@"ipmovie.mov"];
        return [NSURL URLWithString:filePath];
    }
    return nil;
}
- (void)stopRecording{
    if ([self isRecording]) {
        [self.movieOutput stopRecording];
    }
}
@end
