//
//  AHVision.h
//  Vision
//
//  Created by yuchimin

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

// vision block

typedef void (^compressProgress)(float);

// vision types
typedef NS_ENUM(NSInteger, AHCameraDevice) {
    AHCameraDeviceBack = UIImagePickerControllerCameraDeviceRear,
    AHCameraDeviceFront = UIImagePickerControllerCameraDeviceFront
};

typedef NS_ENUM(NSInteger, AHCameraOrientation) {
    AHCameraOrientationPortrait = AVCaptureVideoOrientationPortrait,
    AHCameraOrientationPortraitUpsideDown = AVCaptureVideoOrientationPortraitUpsideDown,
    AHCameraOrientationLandscapeRight = AVCaptureVideoOrientationLandscapeRight,
    AHCameraOrientationLandscapeLeft = AVCaptureVideoOrientationLandscapeLeft,
};

typedef NS_ENUM(NSInteger, AHFocusMode) {
    AHFocusModeLocked = AVCaptureFocusModeLocked,
    AHFocusModeAutoFocus = AVCaptureFocusModeAutoFocus,
    AHFocusModeContinuousAutoFocus = AVCaptureFocusModeContinuousAutoFocus
};

typedef NS_ENUM(NSInteger, AHExposureMode) {
    AHExposureModeLocked = AVCaptureExposureModeLocked,
    AHExposureModeAutoExpose = AVCaptureExposureModeAutoExpose,
    AHExposureModeContinuousAutoExposure = AVCaptureExposureModeContinuousAutoExposure
};

typedef NS_ENUM(NSInteger, AHFlashMode) {
    AHFlashModeOff  = AVCaptureFlashModeOff,
    AHFlashModeOn   = AVCaptureFlashModeOn,
    AHFlashModeAuto = AVCaptureFlashModeAuto
};

typedef NS_ENUM(NSInteger, AHMirroringMode) {
    AHMirroringAuto,
    AHMirroringOn,
    AHMirroringOff
};

typedef NS_ENUM(NSInteger, AHAuthorizationStatus) {
    AHAuthorizationStatusNotDetermined = 0,
    AHAuthorizationStatusAuthorized,
    AHAuthorizationStatusAudioDenied
};

typedef NS_ENUM(NSInteger, AHOutputFormat) {
    AHOutputFormatPreset = 0,
    AHOutputFormatSquare,
    AHOutputFormatWidescreen,
    AHOutputFormatStandard /* 4:3 */
};

// AHError

extern NSString * const AHVisionErrorDomain;

typedef NS_ENUM(NSInteger, AHVisionErrorType)
{
    AHVisionErrorUnknown = -1,
    AHVisionErrorCancelled = 100,
    AHVisionErrorSessionFailed = 101,
    AHVisionErrorBadOutputFile = 102
};

// video dictionary keys

extern NSString * const AHVisionVideoPathKey;
extern NSString * const AHVisionVideoThumbnailKey;
extern NSString * const AHVisionVideoThumbnailArrayKey;
extern NSString * const AHVisionVideoCapturedDurationKey; // Captured duration in seconds

// suggested videoBitRate constants

static CGFloat const AHVideoBitRate480x360 = 87500 * 8;
static CGFloat const AHVideoBitRate640x480 = 437500 * 8;
static CGFloat const AHVideoBitRate1280x720 = 1312500 * 8;
static CGFloat const AHVideoBitRate1920x1080 = 2975000 * 8;
static CGFloat const AHVideoBitRate960x540 = 3750000 * 8;
static CGFloat const AHVideoBitRate1280x750 = 5000000 * 8;

@class EAGLContext;
@protocol AHVisionDelegate;
@interface IPVision : NSObject

+ (IPVision *)sharedInstance;

@property (nonatomic,weak) id<AHVisionDelegate> delegate;

// session

@property (nonatomic, readonly, getter=isCaptureSessionActive) BOOL captureSessionActive;

// setup

@property (nonatomic) AHCameraOrientation cameraOrientation;
@property (nonatomic) AHCameraDevice cameraDevice;
// Indicates whether the capture session will make use of the app’s shared audio session. Allows you to
// use a previously configured audios session with a category such as AVAudioSessionCategoryAmbient.
@property (nonatomic) BOOL usesApplicationAudioSession;
- (BOOL)isCameraDeviceAvailable:(AHCameraDevice)cameraDevice;

@property (nonatomic) AHFlashMode flashMode; // flash and torch
@property (nonatomic, readonly, getter=isFlashAvailable) BOOL flashAvailable;

@property (nonatomic) AHMirroringMode mirroringMode;

// video output settings

@property (nonatomic, copy) NSString *captureSessionPreset;
@property (nonatomic, copy) NSString *captureDirectory;
@property (nonatomic) AHOutputFormat outputFormat;

// video compression settings

@property (nonatomic) CGFloat videoBitRate;
@property (nonatomic) NSInteger audioBitRate;

// video frame rate (adjustment may change the capture format (AVCaptureDeviceFormat : FoV, zoom factor, etc)

@property (nonatomic) NSInteger videoFrameRate; // desired fps for active cameraDevice
- (BOOL)supportsVideoFrameRate:(NSInteger)videoFrameRate;

// preview

@property (nonatomic, readonly) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic) BOOL autoUpdatePreviewOrientation;
@property (nonatomic) AHCameraOrientation previewOrientation;
@property (nonatomic) BOOL autoFreezePreviewDuringCapture;

@property (nonatomic, readonly) CGRect cleanAperture;

- (void)startPreview;
- (void)stopPreview;

// focus, exposure, white balance

// note: focus and exposure modes change when adjusting on point
- (BOOL)isFocusPointOfInterestSupported;
- (void)focusExposeAndAdjustWhiteBalanceAtAdjustedPoint:(CGPoint)adjustedPoint;

@property (nonatomic) AHFocusMode focusMode;
@property (nonatomic, readonly, getter=isFocusLockSupported) BOOL focusLockSupported;
- (void)focusAtAdjustedPointOfInterest:(CGPoint)adjustedPoint;

@property (nonatomic) AHExposureMode exposureMode;
@property (nonatomic, readonly, getter=isExposureLockSupported) BOOL exposureLockSupported;
- (void)exposeAtAdjustedPointOfInterest:(CGPoint)adjustedPoint;


// video
// use pause/resume if a session is in progress, end finalizes that recording session

@property (nonatomic, readonly) BOOL supportsVideoCapture;
@property (nonatomic, readonly) BOOL canCaptureVideo;
@property (nonatomic, readonly, getter=isRecording) BOOL recording;
@property (nonatomic, readonly, getter=isPaused) BOOL paused;

@property (nonatomic) CGRect presentationFrame;

@property (nonatomic) CMTime maximumCaptureDuration; // automatically triggers vision:capturedVideo:error: after exceeding threshold, (kCMTimeInvalid records without threshold)
@property (nonatomic, readonly) Float64 capturedVideoSeconds;

- (void)resetVideoCapture;
- (void)startVideoCapture;
- (void)pauseVideoCapture;
- (void)resumeVideoCapture;
- (BOOL)endVideoCapture;
- (void)cancelVideoCapture;
- (void)backspaceVideoCapture;

- (void) exportVideo:(void (^)(BOOL,NSURL *))completion withProgress:(compressProgress) progress;

// thumbnail           s

@property (nonatomic) BOOL thumbnailEnabled; // thumbnail generation, disabling reduces processing time for a photo or video
@property (nonatomic) BOOL defaultVideoThumbnails; // capture first and last frames of video

- (void)captureCurrentVideoThumbnail;
- (void)captureVideoThumbnailAtFrame:(int64_t)frame;
- (void)captureVideoThumbnailAtTime:(Float64)seconds;

@property (nonatomic,strong) NSURL *thumbnail;
/*
 AVAssetExportPresetLowQuality=3
 AVAssetExportPresetMediumQuality=2
 AVAssetExportPresetHighestQuality=1
 */
@property (nonatomic,assign) NSInteger exportPresetQuality;
@property (nonatomic,assign) CGFloat exportVideoWidth;
@property (nonatomic,assign) CGFloat exportVideoHeight;
@end

@protocol AHVisionDelegate <NSObject>
@optional

// session

- (void)visionSessionWillStart:(IPVision *)vision;
- (void)visionSessionDidStart:(IPVision *)vision;
- (void)visionSessionDidStop:(IPVision *)vision;

- (void)visionSessionWasInterrupted:(IPVision *)vision;
- (void)visionSessionInterruptionEnded:(IPVision *)vision;

// device / mode / format

- (void)visionCameraDeviceWillChange:(IPVision *)vision;
- (void)visionCameraDeviceDidChange:(IPVision *)vision;

- (void)visionOutputFormatWillChange:(IPVision *)vision;
- (void)visionOutputFormatDidChange:(IPVision *)vision;

- (void)vision:(IPVision *)vision didChangeCleanAperture:(CGRect)cleanAperture;

- (void)visionDidChangeVideoFormatAndFrameRate:(IPVision *)vision;

// focus / exposure

- (void)visionWillStartFocus:(IPVision *)vision;
- (void)visionDidStopFocus:(IPVision *)vision;

- (void)visionWillChangeExposure:(IPVision *)vision;
- (void)visionDidChangeExposure:(IPVision *)vision;

- (void)visionDidChangeFlashMode:(IPVision *)vision; // flash or torch was changed

// authorization / availability

- (void)visionDidChangeAuthorizationStatus:(AHAuthorizationStatus)status;
- (void)visionDidChangeFlashAvailablility:(IPVision *)vision; // flash or torch is available

// preview

- (void)visionSessionDidStartPreview:(IPVision *)vision;
- (void)visionSessionDidStopPreview:(IPVision *)vision;

// video

- (NSString *)vision:(IPVision *)vision willStartVideoCaptureToFile:(NSString *)fileName;
- (void)visionDidStartVideoCapture:(IPVision *)vision;
- (void)visionDidPauseVideoCapture:(IPVision *)vision; // stopped but not ended
- (void)visionDidResumeVideoCapture:(IPVision *)vision;
- (void)visionDidEndVideoCapture:(IPVision *)vision;
- (void)vision:(IPVision *)vision capturedVideo:(NSDictionary *)videoDict error:(NSError *)error;

// video capture progress
- (void)vision:(IPVision *)vision didCaptureDuration:(CMTime)duration;

@end
