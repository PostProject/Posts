//
//  AHVision.m
//  Vision
//
//  Created by yuchimin

#import "IPVision.h"
#import "IPVisionUtilities.h"

#import <ImageIO/ImageIO.h>
#import <OpenGLES/EAGL.h>

#define LOG_VISION 0
#ifndef DLog
#if !defined(NDEBUG) && LOG_VISION
#   define DLog(fmt, ...) NSLog((@"VISION: " fmt), ##__VA_ARGS__);
#else
#   define DLog(...)
#endif
#endif

//安全释放    重复，与AHContants 重复
//#define AH_RELEASE_SAFELY(__POINTER) if((__POINTER) != nil) { [__POINTER release]; __POINTER = nil; }

#if LOG_SWITCH
#define PLog(format, ...) NSLog(format, ## __VA_ARGS__)
#else
#define PLog(format, ...)
#endif

@interface vSegment : NSObject

@property(nonatomic,strong) NSURL *url;

@property(nonatomic) CMTime duration;

@end

@implementation vSegment

@synthesize url,duration;

-(id) init:(NSURL *)_url withDuration:(CMTime) _duration
{
    if(self = [super init])
    {
        self.url = _url;
        self.duration = _duration;
    }
    return self;
}


@end

NSString * const AHVisionErrorDomain = @"AHVisionErrorDomain";

static uint64_t const AHVisionRequiredMinimumDiskSpaceInBytes = 49999872; // ~ 47 MB

// KVO contexts

static NSString * const AHVisionFocusObserverContext = @"AHVisionFocusObserverContext";
static NSString * const AHVisionExposureObserverContext = @"AHVisionExposureObserverContext";
static NSString * const AHVisionWhiteBalanceObserverContext = @"AHVisionWhiteBalanceObserverContext";
static NSString * const AHVisionFlashModeObserverContext = @"AHVisionFlashModeObserverContext";
static NSString * const AHVisionTorchModeObserverContext = @"AHVisionTorchModeObserverContext";
static NSString * const AHVisionFlashAvailabilityObserverContext = @"AHVisionFlashAvailabilityObserverContext";
static NSString * const AHVisionTorchAvailabilityObserverContext = @"AHVisionTorchAvailabilityObserverContext";

// video dictionary key definitions

NSString * const AHVisionVideoPathKey = @"AHVisionVideoPathKey";
NSString * const AHVisionVideoThumbnailKey = @"AHVisionVideoThumbnailKey";
NSString * const AHVisionVideoThumbnailArrayKey = @"AHVisionVideoThumbnailArrayKey";
NSString * const AHVisionVideoCapturedDurationKey = @"AHVisionVideoCapturedDurationKey";


@interface IPVision () <AVCaptureFileOutputRecordingDelegate>
{
    // AV
    AVCaptureSession *_captureSession;
    
    AVCaptureDevice *_captureDeviceFront;
    AVCaptureDevice *_captureDeviceBack;
    AVCaptureDevice *_captureDeviceAudio;
    
    AVCaptureDeviceInput *_captureDeviceInputFront;
    AVCaptureDeviceInput *_captureDeviceInputBack;
    AVCaptureDeviceInput *_captureDeviceInputAudio;
    
    AVCaptureMovieFileOutput *_captureMovieFileOutput;
    
    AVCaptureDevice * _currentDevice;
    AVCaptureDeviceInput *_currentInput;
    AVCaptureOutput *_currentOutput;
    
    AVCaptureVideoPreviewLayer *_previewLayer;
    // vision core
    dispatch_queue_t _captureSessionDispatchQueue;
    dispatch_queue_t _captureVideoDispatchQueue;
    
    AHCameraDevice _cameraDevice;
    AHCameraOrientation _cameraOrientation;
    
    AHCameraOrientation _previewOrientation;
    BOOL _autoUpdatePreviewOrientation;
    BOOL _autoFreezePreviewDuringCapture;
    BOOL _usesApplicationAudioSession;
    
    AHFocusMode _focusMode;
    AHExposureMode _exposureMode;
    AHFlashMode _flashMode;
    AHMirroringMode _mirroringMode;
    
    NSString *_captureSessionPreset;
    NSString *_captureDirectory;
    AHOutputFormat _outputFormat;
    NSMutableSet* _captureThumbnailTimes;
    NSMutableSet* _captureThumbnailFrames;
    
    CGFloat _videoBitRate;
    NSInteger _audioBitRate;
    NSInteger _videoFrameRate;
    
    NSMutableArray *_videoSegments;
    
    CGRect _cleanAperture;
    
    CMTime _startTimestamp;
    CMTime _lastTimestamp;
    CMTime _maximumCaptureDuration;
    
    // sample buffer rendering
    
    AHCameraDevice _bufferDevice;
    AHCameraOrientation _bufferOrientation;
    
    size_t _bufferWidth;
    size_t _bufferHeight;
    CGRect _presentationFrame;
    
    NSTimer *_reCoadingtimer;
    NSTimer *_exporttimer;
    
    // flags
    
    struct {
        unsigned int previewRunning:1;
        unsigned int changingModes:1;
        unsigned int recording:1;
        unsigned int paused:1;
        unsigned int interrupted:1;
        unsigned int thumbnailEnabled:1;
        unsigned int defaultVideoThumbnails:1;
    } __block _flags;
}

@property (nonatomic) AVCaptureDevice *currentDevice;

@end

@implementation IPVision

@synthesize delegate = _delegate;
@synthesize currentDevice = _currentDevice;
@synthesize previewLayer = _previewLayer;
@synthesize cleanAperture = _cleanAperture;
@synthesize cameraOrientation = _cameraOrientation;
@synthesize previewOrientation = _previewOrientation;
@synthesize autoUpdatePreviewOrientation = _autoUpdatePreviewOrientation;
@synthesize autoFreezePreviewDuringCapture = _autoFreezePreviewDuringCapture;
@synthesize usesApplicationAudioSession = _usesApplicationAudioSession;
@synthesize cameraDevice = _cameraDevice;
@synthesize focusMode = _focusMode;
@synthesize exposureMode = _exposureMode;
@synthesize flashMode = _flashMode;
@synthesize mirroringMode = _mirroringMode;
@synthesize outputFormat = _outputFormat;
@synthesize presentationFrame = _presentationFrame;
@synthesize captureSessionPreset = _captureSessionPreset;
@synthesize captureDirectory = _captureDirectory;
@synthesize audioBitRate = _audioBitRate;
@synthesize videoBitRate = _videoBitRate;
@synthesize maximumCaptureDuration = _maximumCaptureDuration;
@synthesize thumbnail;
@synthesize exportPresetQuality;
@synthesize exportVideoWidth;
@synthesize exportVideoHeight;

#pragma mark - singleton

+ (IPVision *)sharedInstance
{
    static IPVision *singleton = nil;
    static dispatch_once_t once = 0;
    dispatch_once(&once, ^{
        singleton = [[IPVision alloc] init];
    });
    return singleton;
}

#pragma mark - getters/setters

- (BOOL)isCaptureSessionActive
{
    return ([_captureSession isRunning]);
}

- (BOOL)isRecording
{
    return _flags.recording;
}

- (BOOL)isPaused
{
    return _flags.paused;
}

- (void)setThumbnailEnabled:(BOOL)thumbnailEnabled
{
    _flags.thumbnailEnabled = (unsigned int)thumbnailEnabled;
}

- (BOOL)thumbnailEnabled
{
    return _flags.thumbnailEnabled;
}

- (void)setDefaultVideoThumbnails:(BOOL)defaultVideoThumbnails
{
    _flags.defaultVideoThumbnails = (unsigned int)defaultVideoThumbnails;
}

- (BOOL)defaultVideoThumbnails
{
    return _flags.defaultVideoThumbnails;
}


- (Float64)capturedVideoSeconds
{
    return CMTimeGetSeconds(_lastTimestamp);
}

- (void)setCameraOrientation:(AHCameraOrientation)cameraOrientation
{
    if (cameraOrientation == _cameraOrientation)
        return;
    _cameraOrientation = cameraOrientation;
    
    if (self.autoUpdatePreviewOrientation) {
        [self setPreviewOrientation:cameraOrientation];
    }
}

- (void)setPreviewOrientation:(AHCameraOrientation)previewOrientation {
    if (previewOrientation == _previewOrientation)
        return;
    
    if ([_previewLayer.connection isVideoOrientationSupported]) {
        _previewOrientation = previewOrientation;
        [self _setOrientationForConnection:_previewLayer.connection];
    }
}

- (void)_setOrientationForConnection:(AVCaptureConnection *)connection
{
    if (!connection || ![connection isVideoOrientationSupported])
        return;
    
    AVCaptureVideoOrientation orientation = AVCaptureVideoOrientationPortrait;
    switch (_cameraOrientation) {
        case AHCameraOrientationPortraitUpsideDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        case AHCameraOrientationLandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case AHCameraOrientationLandscapeLeft:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        default:
        case AHCameraOrientationPortrait:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
    }
    
    [connection setVideoOrientation:orientation];
}

- (void)_setCameraDevice:(AHCameraDevice)cameraDevice outputFormat:(AHOutputFormat)outputFormat
{
    BOOL changeDevice = (_cameraDevice != cameraDevice);
    BOOL changeOutputFormat = (_outputFormat != outputFormat);
    
    
    if (!changeDevice && !changeOutputFormat)
        return;
    
    SEL targetDelegateMethodBeforeChange;
    SEL targetDelegateMethodAfterChange;
    
    if (changeDevice) {
        targetDelegateMethodBeforeChange = @selector(visionCameraDeviceWillChange:);
        targetDelegateMethodAfterChange = @selector(visionCameraDeviceDidChange:);
    }
    else {
        targetDelegateMethodBeforeChange = @selector(visionOutputFormatWillChange:);
        targetDelegateMethodAfterChange = @selector(visionOutputFormatDidChange:);
    }
    
    if ([_delegate respondsToSelector:targetDelegateMethodBeforeChange]) {
        // At this point, `targetDelegateMethodBeforeChange` will always refer to a valid selector, as
        // from the sequence of conditionals above. Also the enclosing `if` statement ensures
        // that the delegate responds to it, thus safely ignore this compiler warning.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [_delegate performSelector:targetDelegateMethodBeforeChange withObject:self];
#pragma clang diagnostic pop
    }
    
    _flags.changingModes = YES;
    
    _cameraDevice = cameraDevice;
    
    _outputFormat = outputFormat;
    
    // since there is no session in progress, set and bail
    if (!_captureSession) {
        _flags.changingModes = NO;
        
        if ([_delegate respondsToSelector:targetDelegateMethodAfterChange]) {
            // At this point, `targetDelegateMethodAfterChange` will always refer to a valid selector, as
            // from the sequence of conditionals above. Also the enclosing `if` statement ensures
            // that the delegate responds to it, thus safely ignore this compiler warning.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [_delegate performSelector:targetDelegateMethodAfterChange withObject:self];
#pragma clang diagnostic pop
        }
        
        return;
    }
    
    [self _enqueueBlockOnCaptureSessionQueue:^{
        // camera is already setup, no need to call _setupCamera
        [self _setupSession];
        
        [self setMirroringMode:_mirroringMode];
        
        [self _enqueueBlockOnMainQueue:^{
            _flags.changingModes = NO;
            
            if ([_delegate respondsToSelector:targetDelegateMethodAfterChange]) {
                // At this point, `targetDelegateMethodAfterChange` will always refer to a valid selector, as
                // from the sequence of conditionals above. Also the enclosing `if` statement ensures
                // that the delegate responds to it, thus safely ignore this compiler warning.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [_delegate performSelector:targetDelegateMethodAfterChange withObject:self];
#pragma clang diagnostic pop
            }
        }];
    }];
}

- (void)setCameraDevice:(AHCameraDevice)cameraDevice
{
    [self _setCameraDevice:cameraDevice outputFormat:_outputFormat];
}

- (void)setCaptureSessionPreset:(NSString *)captureSessionPreset
{
    _captureSessionPreset = captureSessionPreset;
    if ([_captureSession canSetSessionPreset:captureSessionPreset]){
        [self _commitBlock:^{
            [_captureSession setSessionPreset:captureSessionPreset];
        }];
    }
}

- (void)setOutputFormat:(AHOutputFormat)outputFormat
{
    [self _setCameraDevice:_cameraDevice outputFormat:outputFormat];
}

- (BOOL)isCameraDeviceAvailable:(AHCameraDevice)cameraDevice
{
    return [UIImagePickerController isCameraDeviceAvailable:(UIImagePickerControllerCameraDevice)cameraDevice];
}

- (BOOL)isFocusPointOfInterestSupported
{
    return [_currentDevice isFocusPointOfInterestSupported];
}

- (BOOL)isFocusLockSupported
{
    return [_currentDevice isFocusModeSupported:AVCaptureFocusModeLocked];
}

- (void)setFocusMode:(AHFocusMode)focusMode
{
    BOOL shouldChangeFocusMode = (_focusMode != focusMode);
    if (![_currentDevice isFocusModeSupported:(AVCaptureFocusMode)focusMode] || !shouldChangeFocusMode)
        return;
    
    _focusMode = focusMode;
    
    NSError *error = nil;
    if (_currentDevice && [_currentDevice lockForConfiguration:&error]) {
        [_currentDevice setFocusMode:(AVCaptureFocusMode)focusMode];
        [_currentDevice unlockForConfiguration];
    } else if (error) {
        DLog(@"error locking device for focus mode change (%@)", error);
    }
}

- (BOOL)isExposureLockSupported
{
    return [_currentDevice isExposureModeSupported:AVCaptureExposureModeLocked];
}

- (void)setExposureMode:(AHExposureMode)exposureMode
{
    BOOL shouldChangeExposureMode = (_exposureMode != exposureMode);
    if (![_currentDevice isExposureModeSupported:(AVCaptureExposureMode)exposureMode] || !shouldChangeExposureMode)
        return;
    
    _exposureMode = exposureMode;
    
    NSError *error = nil;
    if (_currentDevice && [_currentDevice lockForConfiguration:&error]) {
        [_currentDevice setExposureMode:(AVCaptureExposureMode)exposureMode];
        [_currentDevice unlockForConfiguration];
    } else if (error) {
        DLog(@"error locking device for exposure mode change (%@)", error);
    }
    
}

- (BOOL)isFlashAvailable
{
    return (_currentDevice && [_currentDevice hasFlash]);
}

- (void)setFlashMode:(AHFlashMode)flashMode
{
    BOOL shouldChangeFlashMode = (_flashMode != flashMode);
    if (![_currentDevice hasFlash] || !shouldChangeFlashMode)
        return;
    
    _flashMode = flashMode;
    
    NSError *error = nil;
    if (_currentDevice && [_currentDevice lockForConfiguration:&error]) {
        
        if ([_currentDevice isFlashModeSupported:(AVCaptureFlashMode)_flashMode]) {
            [_currentDevice setFlashMode:AVCaptureFlashModeOff];
        }
        
        if ([_currentDevice isTorchModeSupported:(AVCaptureTorchMode)_flashMode]) {
            [_currentDevice setTorchMode:(AVCaptureTorchMode)_flashMode];
        }
        
        [_currentDevice unlockForConfiguration];
        
    } else if (error) {
        DLog(@"error locking device for flash mode change (%@)", error);
    }
}

// framerate

- (void)setVideoFrameRate:(NSInteger)videoFrameRate
{
    if (![self supportsVideoFrameRate:videoFrameRate]) {
        DLog(@"frame rate range not supported for current device format");
        return;
    }
    
    BOOL isRecording = _flags.recording;
    if (isRecording) {
        [self pauseVideoCapture];
    }
    
    CMTime fps = CMTimeMake(1, (int32_t)videoFrameRate);
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        
        AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        AVCaptureDeviceFormat *supportingFormat = nil;
        int32_t maxWidth = 0;
        
        NSArray *formats = [videoDevice formats];
        for (AVCaptureDeviceFormat *format in formats) {
            NSArray *videoSupportedFrameRateRanges = format.videoSupportedFrameRateRanges;
            for (AVFrameRateRange *range in videoSupportedFrameRateRanges) {
                
                CMFormatDescriptionRef desc = format.formatDescription;
                CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(desc);
                int32_t width = dimensions.width;
                if (range.minFrameRate <= videoFrameRate && videoFrameRate <= range.maxFrameRate && width >= maxWidth) {
                    supportingFormat = format;
                    maxWidth = width;
                }
                
            }
        }
        
        if (supportingFormat) {
            NSError *error = nil;
            if ([_currentDevice lockForConfiguration:&error]) {
                _currentDevice.activeVideoMinFrameDuration = fps;
                _currentDevice.activeVideoMaxFrameDuration = fps;
                _videoFrameRate = videoFrameRate;
                [_currentDevice unlockForConfiguration];
            } else if (error) {
                DLog(@"error locking device for frame rate change (%@)", error);
            }
        }
        
        [self _enqueueBlockOnMainQueue:^{
            if ([_delegate respondsToSelector:@selector(visionDidChangeVideoFormatAndFrameRate:)])
                [_delegate visionDidChangeVideoFormatAndFrameRate:self];
        }];
        
    } else {
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        AVCaptureConnection *connection = [_currentOutput connectionWithMediaType:AVMediaTypeVideo];
        if (connection.isVideoMaxFrameDurationSupported) {
            connection.videoMaxFrameDuration = fps;
        } else {
            DLog(@"failed to set frame rate");
        }
        
        if (connection.isVideoMinFrameDurationSupported) {
            connection.videoMinFrameDuration = fps;
            _videoFrameRate = videoFrameRate;
        } else {
            DLog(@"failed to set frame rate");
        }
        
        [self _enqueueBlockOnMainQueue:^{
            if ([_delegate respondsToSelector:@selector(visionDidChangeVideoFormatAndFrameRate:)])
                [_delegate visionDidChangeVideoFormatAndFrameRate:self];
        }];
#pragma clang diagnostic pop
        
    }
    
    if (isRecording) {
        [self resumeVideoCapture];
    }
}

- (NSInteger)videoFrameRate
{
    if (!_currentDevice)
        return 0;
    
    NSInteger frameRate = 0;
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        
        frameRate = _currentDevice.activeVideoMaxFrameDuration.timescale;
        
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        AVCaptureConnection *connection = [_currentOutput connectionWithMediaType:AVMediaTypeVideo];
        frameRate = connection.videoMaxFrameDuration.timescale;
#pragma clang diagnostic pop
    }
    
    return frameRate;
}

- (BOOL)supportsVideoFrameRate:(NSInteger)videoFrameRate
{
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        NSArray *formats = [videoDevice formats];
        for (AVCaptureDeviceFormat *format in formats) {
            NSArray *videoSupportedFrameRateRanges = [format videoSupportedFrameRateRanges];
            for (AVFrameRateRange *frameRateRange in videoSupportedFrameRateRanges) {
                if ( (frameRateRange.minFrameRate <= videoFrameRate) && (videoFrameRate <= frameRateRange.maxFrameRate) ) {
                    return YES;
                }
            }
        }
        
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        AVCaptureConnection *connection = [_currentOutput connectionWithMediaType:AVMediaTypeVideo];
        return (connection.isVideoMaxFrameDurationSupported && connection.isVideoMinFrameDurationSupported);
#pragma clang diagnostic pop
    }
    
    return NO;
}

#pragma mark - init

- (id)init
{
    self = [super init];
    if (self) {
        _captureSessionPreset = AVCaptureSessionPreset640x480;
        self.captureDirectory = nil;
        _videoSegments = [[NSMutableArray alloc] init];
        
        _autoUpdatePreviewOrientation = YES;
        _autoFreezePreviewDuringCapture = YES;
        _usesApplicationAudioSession = NO;
        
        // Average bytes per second based on video dimensions
        // lower the bitRate, higher the compression
        _videoBitRate = AHVideoBitRate640x480;
        
        // default audio/video configuration
        _audioBitRate = 64000;
        
        // default flags
        _flags.thumbnailEnabled = YES;
        _flags.defaultVideoThumbnails = YES;
        
        // setup queues
        _captureSessionDispatchQueue = dispatch_queue_create("AHVisionSession", DISPATCH_QUEUE_SERIAL); // protects session
        _captureVideoDispatchQueue = dispatch_queue_create("AHVisionVideo", DISPATCH_QUEUE_SERIAL); // protects capture
        
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:nil];
        
        _maximumCaptureDuration = kCMTimeInvalid;
        
        [self setMirroringMode:AHMirroringAuto];
        
        _captureThumbnailTimes = [[NSMutableSet alloc] init];
        _captureThumbnailFrames = [[NSMutableSet alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_applicationWillEnterForeground:) name:@"UIApplicationWillEnterForegroundNotification" object:[UIApplication sharedApplication]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_applicationDidEnterBackground:) name:@"UIApplicationDidEnterBackgroundNotification" object:[UIApplication sharedApplication]];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.delegate = nil;
    self.captureSessionPreset = nil;
    
    [self _destroyCamera];
    
}

#pragma mark - queue helper methods

typedef void (^AHVisionBlock)();

- (void)_enqueueBlockOnCaptureSessionQueue:(AHVisionBlock)block
{
    dispatch_async(_captureSessionDispatchQueue, ^{
        block();
    });
}

- (void)_enqueueBlockOnCaptureVideoQueue:(AHVisionBlock)block
{
    dispatch_async(_captureVideoDispatchQueue, ^{
        block();
    });
}

- (void)_enqueueBlockOnMainQueue:(AHVisionBlock)block
{
    dispatch_async(dispatch_get_main_queue(), ^{
        block();
    });
}

- (void)_executeBlockOnMainQueue:(AHVisionBlock)block
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        block();
    });
}

- (void)_commitBlock:(AHVisionBlock)block
{
    [_captureSession beginConfiguration];
    block();
    [_captureSession commitConfiguration];
}

#pragma mark - camera

// only call from the session queue
- (void)_setupCamera
{
    if (_captureSession)
        return;
    
    // create session
    _captureSession = [[AVCaptureSession alloc] init];
    
    if (_usesApplicationAudioSession) {
        _captureSession.usesApplicationAudioSession = YES;
    }
    
    // capture devices
    _captureDeviceFront = [IPVisionUtilities captureDeviceForPosition:AVCaptureDevicePositionFront];
    _captureDeviceBack = [IPVisionUtilities captureDeviceForPosition:AVCaptureDevicePositionBack];
    
    // capture device inputs
    NSError *error = nil;
    _captureDeviceInputFront = [AVCaptureDeviceInput deviceInputWithDevice:_captureDeviceFront error:&error];
    if (error) {
        DLog(@"error setting up front camera input (%@)", error);
        error = nil;
    }
    
    _captureDeviceInputBack = [AVCaptureDeviceInput deviceInputWithDevice:_captureDeviceBack error:&error];
    if (error) {
        DLog(@"error setting up back camera input (%@)", error);
        error = nil;
    }
    
    _captureDeviceAudio = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    _captureDeviceInputAudio = [AVCaptureDeviceInput deviceInputWithDevice:_captureDeviceAudio error:&error];
    
    if (error) {
        DLog(@"error setting up audio input (%@)", error);
    }
    
    // capture device ouputs
    _captureMovieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    _currentOutput = _captureMovieFileOutput;
    
    //    if ([_captureSession canAddInput:_captureDeviceInputBack]) {
    //        [_captureSession addInput:_captureDeviceInputBack];
    //    }
    
    if ([_captureSession canAddInput:_captureDeviceInputAudio]) {
        [_captureSession addInput:_captureDeviceInputAudio];
    }
    
    if ([_captureSession canAddOutput:_currentOutput]) {
        [_captureSession addOutput:_currentOutput];
    }
    
    // capture device initial settings
    _videoFrameRate = 30;
    
    // add notification observers
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    // session notifications
    [notificationCenter addObserver:self selector:@selector(_sessionRuntimeErrored:) name:AVCaptureSessionRuntimeErrorNotification object:_captureSession];
    [notificationCenter addObserver:self selector:@selector(_sessionStarted:) name:AVCaptureSessionDidStartRunningNotification object:_captureSession];
    [notificationCenter addObserver:self selector:@selector(_sessionStopped:) name:AVCaptureSessionDidStopRunningNotification object:_captureSession];
    [notificationCenter addObserver:self selector:@selector(_sessionWasInterrupted:) name:AVCaptureSessionWasInterruptedNotification object:_captureSession];
    [notificationCenter addObserver:self selector:@selector(_sessionInterruptionEnded:) name:AVCaptureSessionInterruptionEndedNotification object:_captureSession];
    
    // capture input notifications
    [notificationCenter addObserver:self selector:@selector(_inputPortFormatDescriptionDidChange:) name:AVCaptureInputPortFormatDescriptionDidChangeNotification object:nil];
    
    // capture device notifications
    [notificationCenter addObserver:self selector:@selector(_deviceSubjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:nil];
    
    // current device KVO notifications
    [self addObserver:self forKeyPath:@"currentDevice.adjustingFocus" options:NSKeyValueObservingOptionNew context:(__bridge void *)AHVisionFocusObserverContext];
    [self addObserver:self forKeyPath:@"currentDevice.adjustingExposure" options:NSKeyValueObservingOptionNew context:(__bridge void *)AHVisionExposureObserverContext];
    [self addObserver:self forKeyPath:@"currentDevice.adjustingWhiteBalance" options:NSKeyValueObservingOptionNew context:(__bridge void *)AHVisionWhiteBalanceObserverContext];
    [self addObserver:self forKeyPath:@"currentDevice.flashMode" options:NSKeyValueObservingOptionNew context:(__bridge void *)AHVisionFlashModeObserverContext];
    [self addObserver:self forKeyPath:@"currentDevice.torchMode" options:NSKeyValueObservingOptionNew context:(__bridge void *)AHVisionTorchModeObserverContext];
    [self addObserver:self forKeyPath:@"currentDevice.flashAvailable" options:NSKeyValueObservingOptionNew context:(__bridge void *)AHVisionFlashAvailabilityObserverContext];
    [self addObserver:self forKeyPath:@"currentDevice.torchAvailable" options:NSKeyValueObservingOptionNew context:(__bridge void *)AHVisionTorchAvailabilityObserverContext];

    DLog(@"camera setup");
}

// only call from the session queue
- (void)_destroyCamera
{
    if (!_captureSession)
        return;
    
    // current device KVO notifications
    [self removeObserver:self forKeyPath:@"currentDevice.adjustingFocus"];
    [self removeObserver:self forKeyPath:@"currentDevice.adjustingExposure"];
    [self removeObserver:self forKeyPath:@"currentDevice.adjustingWhiteBalance"];
    [self removeObserver:self forKeyPath:@"currentDevice.flashMode"];
    [self removeObserver:self forKeyPath:@"currentDevice.torchMode"];
    [self removeObserver:self forKeyPath:@"currentDevice.flashAvailable"];
    [self removeObserver:self forKeyPath:@"currentDevice.torchAvailable"];
    
    [_captureMovieFileOutput removeObserver:self forKeyPath:@"recordedDuration"];
    
    // remove notification observers (we don't want to just 'remove all' because we're also observing background notifications
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    // session notifications
    [notificationCenter removeObserver:self name:AVCaptureSessionRuntimeErrorNotification object:_captureSession];
    [notificationCenter removeObserver:self name:AVCaptureSessionDidStartRunningNotification object:_captureSession];
    [notificationCenter removeObserver:self name:AVCaptureSessionDidStopRunningNotification object:_captureSession];
    [notificationCenter removeObserver:self name:AVCaptureSessionWasInterruptedNotification object:_captureSession];
    [notificationCenter removeObserver:self name:AVCaptureSessionInterruptionEndedNotification object:_captureSession];
    
    // capture input notifications
    [notificationCenter removeObserver:self name:AVCaptureInputPortFormatDescriptionDidChangeNotification object:nil];
    
    // capture device notifications
    [notificationCenter removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:nil];
    
//    AH_RELEASE_SAFELY(_captureMovieFileOutput);
    
    _captureDeviceAudio = nil;
    
    _captureDeviceInputAudio = nil;

    _captureDeviceInputFront = nil;
    
    _captureDeviceInputBack = nil;
    
    _captureDeviceFront = nil;
    
    _captureDeviceBack = nil;
    
    _captureSession = nil;
    
    _currentDevice = nil;

    _currentInput = nil;

    _currentOutput = nil;
    
    DLog(@"camera destroyed");
}

#pragma mark - AVCaptureSession

- (BOOL)_canSessionCaptureWithOutput:(AVCaptureOutput *)captureOutput
{
    BOOL sessionContainsOutput = [[_captureSession outputs] containsObject:captureOutput];
    BOOL outputHasConnection = ([captureOutput connectionWithMediaType:AVMediaTypeVideo] != nil);
    return (sessionContainsOutput && outputHasConnection);
}

// _setupSession is always called from the captureSession queue
- (void)_setupSession
{
    if (!_captureSession) {
        DLog(@"error, no session running to setup");
        return;
    }
    
    BOOL shouldSwitchDevice = (_currentDevice == nil) ||
    ((_currentDevice == _captureDeviceFront) && (_cameraDevice != AHCameraDeviceFront)) ||
    ((_currentDevice == _captureDeviceBack) && (_cameraDevice != AHCameraDeviceBack));
    
    DLog(@"switchDevice %d", shouldSwitchDevice);
    
    if (!shouldSwitchDevice)
        return;
    
    AVCaptureDeviceInput *newDeviceInput = nil;
    AVCaptureDevice *newCaptureDevice = nil;
    
    [_captureSession beginConfiguration];
    
    // setup session device
    if (shouldSwitchDevice) {
        switch (_cameraDevice) {
            case AHCameraDeviceFront:
            {
                if (_captureDeviceInputBack)
                    [_captureSession removeInput:_captureDeviceInputBack];
                
                if (_captureDeviceInputFront && [_captureSession canAddInput:_captureDeviceInputFront]) {
                    [_captureSession addInput:_captureDeviceInputFront];
                    newDeviceInput = _captureDeviceInputFront;
                    newCaptureDevice = _captureDeviceFront;
                }
                break;
            }
            case AHCameraDeviceBack:
            {
                if (_captureDeviceInputFront)
                    [_captureSession removeInput:_captureDeviceInputFront];
                
                if (_captureDeviceInputBack && [_captureSession canAddInput:_captureDeviceInputBack]) {
                    [_captureSession addInput:_captureDeviceInputBack];
                    newDeviceInput = _captureDeviceInputBack;
                    newCaptureDevice = _captureDeviceBack;
                }
                break;
            }
            default:
                break;
        }
        
    } // shouldSwitchDevice
    
    if (!newCaptureDevice)
        newCaptureDevice = _currentDevice;
    
    // setup video connection
    AVCaptureConnection *videoConnection = [_currentOutput connectionWithMediaType:AVMediaTypeVideo];
    
    // setup input/output
    
    NSString *sessionPreset = _captureSessionPreset;
    
    if (videoConnection) {
        // setup video orientation
        [self _setOrientationForConnection:videoConnection];
        
        // setup video stabilization, if available
        if ([videoConnection isVideoStabilizationSupported]) {
            if ([videoConnection respondsToSelector:@selector(setPreferredVideoStabilizationMode:)]) {
                [videoConnection setPreferredVideoStabilizationMode:AVCaptureVideoStabilizationModeAuto];
            } else {
                [videoConnection setEnablesVideoStabilizationWhenAvailable:YES];
            }
        }
        // setup video device configuration
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            
            NSError *error = nil;
            if ([newCaptureDevice lockForConfiguration:&error]) {
                
                // smooth autofocus for videos
                if ([newCaptureDevice isSmoothAutoFocusSupported])
                    [newCaptureDevice setSmoothAutoFocusEnabled:YES];
                
                [newCaptureDevice unlockForConfiguration];
                
            } else if (error) {
                DLog(@"error locking device for video device configuration (%@)", error);
            }
            
        }
        
    }
    
    // apply presets
    if ([_captureSession canSetSessionPreset:sessionPreset])
        [_captureSession setSessionPreset:sessionPreset];
    
    if (newDeviceInput)
        _currentInput = newDeviceInput;
    
    // ensure there is a capture device setup
    if (_currentInput) {
        AVCaptureDevice *device = [_currentInput device];
        if (device) {
            [self willChangeValueForKey:@"currentDevice"];
            _currentDevice = device;
            [self didChangeValueForKey:@"currentDevice"];
        }
    }
    
    [_captureSession commitConfiguration];
    
    DLog(@"capture session setup");
}

#pragma mark - preview

- (void)startPreview
{
    [self _enqueueBlockOnCaptureSessionQueue:^{
        if (!_captureSession) {
            [self _setupCamera];
            [self _setupSession];
        }
        
        [self setMirroringMode:_mirroringMode];
        
        if (_previewLayer && _previewLayer.session != _captureSession) {
            _previewLayer.session = _captureSession;
            [self _setOrientationForConnection:_previewLayer.connection];
        }
        
        if (![_captureSession isRunning]) {
            [_captureSession startRunning];
            
            [self _enqueueBlockOnMainQueue:^{
                if ([_delegate respondsToSelector:@selector(visionSessionDidStartPreview:)]) {
                    [_delegate visionSessionDidStartPreview:self];
                }
            }];
            DLog(@"capture session running");
        }
        _flags.previewRunning = YES;
    }];
}

- (void)stopPreview
{
    [self _enqueueBlockOnCaptureSessionQueue:^{
        if (!_flags.previewRunning)
            return;
        
        if ([_captureSession isRunning])
            [_captureSession stopRunning];
        
        [self _executeBlockOnMainQueue:^{
            if ([_delegate respondsToSelector:@selector(visionSessionDidStopPreview:)]) {
                [_delegate visionSessionDidStopPreview:self];
            }
        }];
        DLog(@"capture session stopped");
        _flags.previewRunning = NO;
    }];
}

#pragma mark - focus, exposure, white balance

- (void)_focusStarted
{
    //    DLog(@"focus started");
    if ([_delegate respondsToSelector:@selector(visionWillStartFocus:)])
        [_delegate visionWillStartFocus:self];
}

- (void)_focusEnded
{
    AVCaptureFocusMode focusMode = [_currentDevice focusMode];
    BOOL isFocusing = [_currentDevice isAdjustingFocus];
    BOOL isAutoFocusEnabled = (focusMode == AVCaptureFocusModeAutoFocus ||
                               focusMode == AVCaptureFocusModeContinuousAutoFocus);
    if (!isFocusing && isAutoFocusEnabled) {
        NSError *error = nil;
        if ([_currentDevice lockForConfiguration:&error]) {
            
            [_currentDevice setSubjectAreaChangeMonitoringEnabled:YES];
            [_currentDevice unlockForConfiguration];
            
        } else if (error) {
            DLog(@"error locking device post exposure for subject area change monitoring (%@)", error);
        }
    }
    
    if ([_delegate respondsToSelector:@selector(visionDidStopFocus:)])
        [_delegate visionDidStopFocus:self];
    //    DLog(@"focus ended");
}

- (void)_exposureChangeStarted
{
    //    DLog(@"exposure change started");
    if ([_delegate respondsToSelector:@selector(visionWillChangeExposure:)])
        [_delegate visionWillChangeExposure:self];
}

- (void)_exposureChangeEnded
{
    BOOL isContinuousAutoExposureEnabled = [_currentDevice exposureMode] == AVCaptureExposureModeContinuousAutoExposure;
    BOOL isExposing = [_currentDevice isAdjustingExposure];
    BOOL isFocusSupported = [_currentDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus];
    
    if (isContinuousAutoExposureEnabled && !isExposing && !isFocusSupported) {
        
        NSError *error = nil;
        if ([_currentDevice lockForConfiguration:&error]) {
            
            [_currentDevice setSubjectAreaChangeMonitoringEnabled:YES];
            [_currentDevice unlockForConfiguration];
            
        } else if (error) {
            DLog(@"error locking device post exposure for subject area change monitoring (%@)", error);
        }
        
    }
    
    if ([_delegate respondsToSelector:@selector(visionDidChangeExposure:)])
        [_delegate visionDidChangeExposure:self];
    //    DLog(@"exposure change ended");
}

- (void)_whiteBalanceChangeStarted
{
}

- (void)_whiteBalanceChangeEnded
{
}

- (void)focusAtAdjustedPointOfInterest:(CGPoint)adjustedPoint
{
    if ([_currentDevice isAdjustingFocus] || [_currentDevice isAdjustingExposure])
        return;
    
    NSError *error = nil;
    if ([_currentDevice lockForConfiguration:&error]) {
        
        BOOL isFocusAtPointSupported = [_currentDevice isFocusPointOfInterestSupported];
        
        if (isFocusAtPointSupported && [_currentDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            AVCaptureFocusMode fm = [_currentDevice focusMode];
            [_currentDevice setFocusPointOfInterest:adjustedPoint];
            [_currentDevice setFocusMode:fm];
        }
        [_currentDevice unlockForConfiguration];
        
    } else if (error) {
        DLog(@"error locking device for focus adjustment (%@)", error);
    }
}

- (void)exposeAtAdjustedPointOfInterest:(CGPoint)adjustedPoint
{
    if ([_currentDevice isAdjustingExposure])
        return;
    
    NSError *error = nil;
    if ([_currentDevice lockForConfiguration:&error]) {
        
        BOOL isExposureAtPointSupported = [_currentDevice isExposurePointOfInterestSupported];
        if (isExposureAtPointSupported && [_currentDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            AVCaptureExposureMode em = [_currentDevice exposureMode];
            [_currentDevice setExposurePointOfInterest:adjustedPoint];
            [_currentDevice setExposureMode:em];
        }
        [_currentDevice unlockForConfiguration];
        
    } else if (error) {
        DLog(@"error locking device for exposure adjustment (%@)", error);
    }
}

- (void)_adjustFocusExposureAndWhiteBalance
{
    if ([_currentDevice isAdjustingFocus] || [_currentDevice isAdjustingExposure])
        return;
    
    // only notify clients when focus is triggered from an event
    if ([_delegate respondsToSelector:@selector(visionWillStartFocus:)])
        [_delegate visionWillStartFocus:self];
    
    CGPoint focusPoint = CGPointMake(0.5f, 0.5f);
    [self focusAtAdjustedPointOfInterest:focusPoint];
}

// focusExposeAndAdjustWhiteBalanceAtAdjustedPoint: will put focus and exposure into auto
- (void)focusExposeAndAdjustWhiteBalanceAtAdjustedPoint:(CGPoint)adjustedPoint
{
    if ([_currentDevice isAdjustingFocus] || [_currentDevice isAdjustingExposure])
        return;
    
    NSError *error = nil;
    if ([_currentDevice lockForConfiguration:&error]) {
        
        BOOL isFocusAtPointSupported = [_currentDevice isFocusPointOfInterestSupported];
        BOOL isExposureAtPointSupported = [_currentDevice isExposurePointOfInterestSupported];
        BOOL isWhiteBalanceModeSupported = [_currentDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
        
        if (isFocusAtPointSupported && [_currentDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [_currentDevice setFocusPointOfInterest:adjustedPoint];
            [_currentDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        
        if (isExposureAtPointSupported && [_currentDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            [_currentDevice setExposurePointOfInterest:adjustedPoint];
            [_currentDevice setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
        
        if (isWhiteBalanceModeSupported) {
            [_currentDevice setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
        }
        
        [_currentDevice setSubjectAreaChangeMonitoringEnabled:NO];
        
        [_currentDevice unlockForConfiguration];
        
    } else if (error) {
        DLog(@"error locking device for focus / exposure / white-balance adjustment (%@)", error);
    }
}

#pragma mark - mirroring

- (void)setMirroringMode:(AHMirroringMode)mirroringMode
{
    _mirroringMode = mirroringMode;
    
    AVCaptureConnection *videoConnection = [_currentOutput connectionWithMediaType:AVMediaTypeVideo];
    AVCaptureConnection *previewConnection =[_previewLayer connection];
    
    switch (_mirroringMode) {
        case AHMirroringOff:
        {
            if ([videoConnection isVideoMirroringSupported]) {
                [videoConnection setVideoMirrored:NO];
            }
            if ([previewConnection isVideoMirroringSupported]) {
                [previewConnection setAutomaticallyAdjustsVideoMirroring:NO];
                [previewConnection setVideoMirrored:NO];
            }
            break;
        }
        case AHMirroringOn:
        {
            if ([videoConnection isVideoMirroringSupported]) {
                [videoConnection setVideoMirrored:YES];
            }
            if ([previewConnection isVideoMirroringSupported]) {
                [previewConnection setAutomaticallyAdjustsVideoMirroring:NO];
                [previewConnection setVideoMirrored:YES];
            }
            break;
        }
        case AHMirroringAuto:
        default:
        {
            BOOL mirror = (_cameraDevice == AHCameraDeviceFront);
            
            if ([videoConnection isVideoMirroringSupported]) {
                [videoConnection setVideoMirrored:mirror];
            }
            if ([previewConnection isVideoMirroringSupported]) {
                [previewConnection setAutomaticallyAdjustsVideoMirroring:YES];
            }
            
            break;
        }
    }
}

#pragma mark - video
- (NSString *) getTemporayPath:(NSString *)extension
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    if(!self.captureDirectory)
    {
        formatter.dateFormat = @"yyyyMMddHHmm";
        NSString *dir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        dir = [[dir stringByAppendingPathComponent:@"videos"]
               stringByAppendingPathComponent:[formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]]];
        
        if (![IPVisionUtilities createFolderIfNotExist:dir]) {
            [self _failVideoCaptureWithErrorCode:AHVisionErrorBadOutputFile];
        }
        self.captureDirectory = dir;
    }
    formatter.dateFormat = @"yyyyMMddHHmmsss";
    NSString *outputPath = [self.captureDirectory stringByAppendingPathComponent:[formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]]];
    
    return [outputPath stringByAppendingString:extension];
}

- (BOOL)supportsVideoCapture
{
    return ([[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count] > 0);
}

- (BOOL)canCaptureVideo
{
    BOOL isDiskSpaceAvailable = [IPVisionUtilities availableDiskSpaceInBytes] > AHVisionRequiredMinimumDiskSpaceInBytes;
    return [self supportsVideoCapture] && [self isCaptureSessionActive] && !_flags.changingModes && isDiskSpaceAvailable;
}

- (void)resetVideoCapture
{
    self.captureDirectory = nil;
    
    _flags.recording = NO;
    _flags.paused = NO;
    _flags.interrupted = YES;
    
    _startTimestamp =kCMTimeZero;
    _lastTimestamp = kCMTimeZero;
    
    self.thumbnail = nil;
    [_videoSegments removeAllObjects];
    
    [_captureThumbnailTimes removeAllObjects];
    [_captureThumbnailFrames removeAllObjects];
}

- (void)startVideoCapture
{
    if (![self _canSessionCaptureWithOutput:_currentOutput]) {
        [self _failVideoCaptureWithErrorCode:AHVisionErrorSessionFailed];
        DLog(@"session is not setup properly for capture");
        return;
    }
    
    DLog(@"starting video capture");
    
    [self _enqueueBlockOnCaptureVideoQueue:^{
        
        if (_flags.recording || _flags.paused)
            return;
        _flags.recording = YES;
        _flags.paused = NO;
        
        AVCaptureConnection *videoConnection = [_currentOutput connectionWithMediaType:AVMediaTypeVideo];
        [self _setOrientationForConnection:videoConnection];
        
        if (!videoConnection.active || !videoConnection.enabled) {
            //解决拍照后  _captureSession 的Preset值被修改导致的崩溃异常
            [self _commitBlock:^{
                if ([_captureSession canSetSessionPreset:_captureSessionPreset])
                    [_captureSession setSessionPreset:_captureSessionPreset];
            }];
        }
        
        if (_flags.thumbnailEnabled && _flags.defaultVideoThumbnails) {
            [self captureVideoThumbnailAtFrame:0];
        }
        
        // start capture
        NSURL *url = [NSURL fileURLWithPath: [self getTemporayPath:@".mov"]];
        
         
        [_captureMovieFileOutput startRecordingToOutputFileURL:url recordingDelegate:self];
    }];
}

- (void)pauseVideoCapture
{
    [self _enqueueBlockOnCaptureVideoQueue:^{
        _flags.paused = YES; //标记为暂停状态
        
        //这里不直接调用stopRecording；防止还没有真正开始录就执行该操作，导致的一系列怪异问题，包括一直录不停止问题
        
//        if(_captureMovieFileOutput.isRecording)
//        {
//            [_captureMovieFileOutput stopRecording];
//        }
        
        DLog(@"pausing video capture");
    }];
}

- (void)resumeVideoCapture
{
    [self _enqueueBlockOnCaptureVideoQueue:^{
        if (!_flags.recording || !_flags.interrupted)
            return;
        
        
        if (CMTimeCompare(_maximumCaptureDuration, _lastTimestamp)!=1) {
            return;
        }
        _flags.paused = NO;
        
        // start capture
        NSURL *url = [NSURL fileURLWithPath: [self getTemporayPath:@".mov"]];
         
        [_captureMovieFileOutput startRecordingToOutputFileURL:url recordingDelegate:self];
        
        [self _enqueueBlockOnMainQueue:^{
            if ([_delegate respondsToSelector:@selector(visionDidResumeVideoCapture:)])
                [_delegate visionDidResumeVideoCapture:self];
        }];
    }];
}

- (BOOL)endVideoCapture
{
    DLog(@"ending video capture");
    
    //    [self _enqueueBlockOnCaptureVideoQueue:^{
    if (!_flags.recording) return NO;
    if (!_flags.interrupted) {
        return NO;
    }
    
    _flags.recording = NO;
    _flags.paused = NO;
    //[_captureMovieFileOutput stopRecording];
    //    }];
    
    self.thumbnail = [self _generateThumbnailURL];
    
    [self _enqueueBlockOnMainQueue:^{
        if ([_delegate respondsToSelector:@selector(visionDidEndVideoCapture:)])
            [_delegate visionDidEndVideoCapture:self];
    }];
    return YES;
}

- (void)cancelVideoCapture
{
    DLog(@"cancel video capture");
    
    [self _enqueueBlockOnCaptureVideoQueue:^{
        if(_captureMovieFileOutput.isRecording){
            [_captureMovieFileOutput stopRecording];
        }
        //删除临时文件
        [self deleteFiles:self.captureDirectory withExtention:@"mov"];
        
        self.captureDirectory = nil;
        _flags.recording = NO;
        _flags.paused = NO;
        _startTimestamp =kCMTimeZero;
        _lastTimestamp = kCMTimeZero;
        
        self.thumbnail = nil;
        [_videoSegments removeAllObjects];
        
        [_captureThumbnailTimes removeAllObjects];
        [_captureThumbnailFrames removeAllObjects];
    }];
}

- (void)backspaceVideoCapture
{
    vSegment *seg = [_videoSegments lastObject];
    [[NSFileManager defaultManager] removeItemAtPath:[seg.url path] error:nil];
    _lastTimestamp = CMTimeSubtract(_lastTimestamp, seg.duration);
    if (!CMTIME_IS_VALID(_lastTimestamp)) {
        _lastTimestamp = kCMTimeZero;
    }
    [_videoSegments removeLastObject];
}

- (NSURL *)_generateThumbnailURL
{
    if(_videoSegments.count==0) return nil;
    
    CGFloat aspecRatio= _previewLayer.bounds.size.height/_previewLayer.bounds.size.width;
    
    vSegment *first = [_videoSegments firstObject];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:first.url options:nil];
    AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    generate.appliesPreferredTrackTransform = YES;
    CGImageRef imgRef = [generate copyCGImageAtTime:kCMTimeZero actualTime:NULL error:NULL];
    
    size_t width = CGImageGetWidth(imgRef);
    size_t height =CGImageGetHeight(imgRef);
    CGRect rect = CGRectMake(0, (height- width * aspecRatio)/2, width, width * aspecRatio);
    
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imgRef, rect);
    CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
    CGImageRelease(imgRef);
    UIGraphicsBeginImageContext(smallBounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallBounds, subImageRef);
    UIImage* image = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    CGImageRelease(subImageRef);
    
    
    NSString *jpgPath = [self getTemporayPath:@".jpg"];
    
    [UIImageJPEGRepresentation(image, 1.0) writeToFile:jpgPath atomically:YES];
    
    return [NSURL fileURLWithPath: jpgPath];
}

- (void) exportVideo:(void (^)(BOOL,NSURL *))completion withProgress:(compressProgress) progress
{
    /*涉及自动释放的对象比较多，单独使用自动释放池来回收资源*/
    @autoreleasepool {
        AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
        
        AVMutableCompositionTrack *audioTrackInput = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        AVMutableCompositionTrack *videoTrackInput = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        
        //fix orientationissue
        NSMutableArray *layerInstructionArray = [[NSMutableArray alloc] init];
        
        //视频高宽比
        CGFloat videoHWRatio= self.exportVideoHeight / self.exportVideoWidth;
        CMTime totalDuration = kCMTimeZero;
        int i=0;
        for (vSegment *seg in _videoSegments) {
            if (seg.duration.value<=0) continue;
            @autoreleasepool {
                AVAsset *asset = [AVAsset assetWithURL:seg.url];
                
                AVAssetTrack *audioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
                AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
                
                [audioTrackInput insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:audioTrack atTime:kCMTimeInvalid error:nil];
                
                [videoTrackInput insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:videoTrack atTime:kCMTimeInvalid error:nil];
                
                totalDuration = CMTimeAdd(totalDuration, asset.duration);
                 
                /*
                 因为只允许竖拍，即使用户横拍，也不需要对视频做转向处理，可以只使用一个AVMutableVideoCompositionLayerInstruction
                 来处理。尽量减少内存消耗，否则ios5系统的低端设备视频导出会失败。
                 */
                if (i++==0) {
                    CGFloat rate = self.exportVideoWidth / videoTrack.naturalSize.height;//因为是纵向拍摄，视频现在的height即为实际的宽
                     
                    
                    CGAffineTransform layerTransform = CGAffineTransformMake(videoTrack.preferredTransform.a, videoTrack.preferredTransform.b, videoTrack.preferredTransform.c, videoTrack.preferredTransform.d, videoTrack.preferredTransform.tx * rate, videoTrack.preferredTransform.ty * rate);
                    layerTransform = CGAffineTransformConcat(layerTransform, CGAffineTransformMake(1, 0, 0, 1, 0, (videoTrack.naturalSize.height * videoHWRatio - videoTrack.naturalSize.width)/ 2.0)); //向上移动取中部影响
                    layerTransform = CGAffineTransformScale(layerTransform, rate, rate); //放缩，解决实际影像和最终导出尺寸不一致问题
                    
                    AVMutableVideoCompositionLayerInstruction *layerInstruciton = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrackInput];
                    [layerInstruciton setTransform:layerTransform atTime:kCMTimeZero];
                    [layerInstructionArray addObject:layerInstruciton];
                }
            }
        }
        NSString *videoDir = [self.captureDirectory copy]; //保存当前视频目录
        NSURL *output = [NSURL fileURLWithPath:[self getTemporayPath:@"_compress.mp4"]];
        
        
        AVMutableVideoCompositionInstruction *mainInstruciton = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        mainInstruciton.timeRange = CMTimeRangeMake(kCMTimeZero, totalDuration);
        mainInstruciton.layerInstructions = layerInstructionArray;
        
        AVMutableVideoComposition *mainCompositionInst = [[AVMutableVideoComposition alloc] init];
        mainCompositionInst.instructions = @[mainInstruciton];
        mainCompositionInst.frameDuration = CMTimeMake(1, 24);
        mainCompositionInst.renderSize = CGSizeMake(self.exportVideoWidth, self.exportVideoHeight);
        
        NSString *presetName = self.exportPresetQuality==3?AVAssetExportPresetLowQuality
        :self.exportPresetQuality==1?AVAssetExportPresetHighestQuality
        :AVAssetExportPresetMediumQuality;
        
        AVAssetExportSession *avAssetExportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:presetName];
        
        [avAssetExportSession setVideoComposition:mainCompositionInst];
        [avAssetExportSession setOutputURL:output];
        [avAssetExportSession setShouldOptimizeForNetworkUse:YES];
        if ([avAssetExportSession.supportedFileTypes containsObject:AVFileTypeMPEG4]) {
            [avAssetExportSession setOutputFileType:AVFileTypeMPEG4];
        }
        else{
            [avAssetExportSession setOutputFileType:[avAssetExportSession.supportedFileTypes firstObject]];
        }
        
        [avAssetExportSession exportAsynchronouslyWithCompletionHandler:^(void){
            if (_exporttimer) {
                [_exporttimer invalidate];
                _exporttimer = nil;
            }
             
            if(avAssetExportSession.status == AVAssetExportSessionStatusCompleted)
            {
                [self _executeBlockOnMainQueue:^{
                    completion(YES,output);
                }];
            }
            else
            {
                [self _executeBlockOnMainQueue:^{
                     
                    completion(NO,nil);
                }];
            }
            //删除临时文件
            [self deleteFiles:videoDir withExtention:@"mov"];
        }];
        
        compressProgress progressBlock = [progress copy];
        _exporttimer = [NSTimer scheduledTimerWithTimeInterval:0.1f
                                                  target:self
                                                selector:@selector(compressProgress:)
                                                userInfo:@[avAssetExportSession,progressBlock]
                                                 repeats:YES];
    }
    
}

-(void) compressProgress:(NSTimer *)timer
{
    NSArray *array = timer.userInfo;
    AVAssetExportSession *exportSession = [array objectAtIndex:0];
    compressProgress block = [array objectAtIndex:1];
    float progressValue = exportSession.progress;
     
    if (progressValue == 1) {
        if (_exporttimer) {
            [_exporttimer invalidate];
            _exporttimer = nil;
        }
    }
    [self _enqueueBlockOnMainQueue:^{
        block(progressValue);
    }];
}

//删除临时文件
- (void)deleteFiles:(NSString *)dir withExtention:(NSString *)ext
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *dirEnum = [fileManager enumeratorAtPath:dir];
    NSString *fileName;
    while (fileName= [dirEnum nextObject]) {
        if ([[fileName pathExtension] isEqualToString:ext]) {
        }
    }
}

- (void)captureCurrentVideoThumbnail
{
    if (_flags.recording) {
        [self captureVideoThumbnailAtTime:self.capturedVideoSeconds];
    }
}

- (void)captureVideoThumbnailAtTime:(Float64)seconds
{
    [_captureThumbnailTimes addObject:@(seconds)];
}

- (void)captureVideoThumbnailAtFrame:(int64_t)frame
{
    [_captureThumbnailFrames addObject:@(frame)];
}

- (void)_generateThumbnailsForVideoWithURL:(NSURL*)url inDictionary:(NSMutableDictionary*)videoDict
{
    if (_captureThumbnailFrames.count == 0 && _captureThumbnailTimes.count == 0)
        return;
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    generate.appliesPreferredTrackTransform = YES;
    
    int32_t timescale = [@([self videoFrameRate]) intValue];
    
    for (NSNumber *frameNumber in [_captureThumbnailFrames allObjects]) {
        CMTime time = CMTimeMake([frameNumber longLongValue], timescale);
        Float64 timeInSeconds = CMTimeGetSeconds(time);
        [self captureVideoThumbnailAtTime:timeInSeconds];
    }
    
    NSMutableArray *captureTimes = [NSMutableArray array];
    NSArray *thumbnailTimes = [_captureThumbnailTimes allObjects];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wselector"
    NSArray *sortedThumbnailTimes = [thumbnailTimes sortedArrayUsingSelector:@selector(compare:)];
#pragma clang diagnostic pop
    
    for (NSNumber *seconds in sortedThumbnailTimes) {
        CMTime time = CMTimeMakeWithSeconds([seconds doubleValue], timescale);
        [captureTimes addObject:[NSValue valueWithCMTime:time]];
    }
    
    NSMutableArray *thumbnails = [NSMutableArray array];
    
    for (NSValue *time in captureTimes) {
        CGImageRef imgRef = [generate copyCGImageAtTime:[time CMTimeValue] actualTime:NULL error:NULL];
        if (imgRef) {
            UIImage *image = [[UIImage alloc] initWithCGImage:imgRef];
            if (image) {
                [thumbnails addObject:image];
            }
            CGImageRelease(imgRef);
        }
    }
    
    UIImage *defaultThumbnail = [thumbnails firstObject];
    if (defaultThumbnail) {
        [videoDict setObject:defaultThumbnail forKey:AHVisionVideoThumbnailKey];
    }
    
    if (thumbnails.count) {
        [videoDict setObject:thumbnails forKey:AHVisionVideoThumbnailArrayKey];
    }
}

- (void)_failVideoCaptureWithErrorCode:(NSInteger)errorCode
{
    if (errorCode && [_delegate respondsToSelector:@selector(vision:capturedVideo:error:)]) {
        NSError *error = [NSError errorWithDomain:AHVisionErrorDomain code:errorCode userInfo:nil];
        [_delegate vision:self capturedVideo:nil error:error];
    }
}

#pragma mark - App NSNotifications

- (void)_applicationWillEnterForeground:(NSNotification *)notification
{
    DLog(@"applicationWillEnterForeground");
    [self _enqueueBlockOnCaptureSessionQueue:^{
        if (!_flags.previewRunning)
            return;
        
        [self _enqueueBlockOnMainQueue:^{
            [self startPreview];
        }];
    }];
}

- (void)_applicationDidEnterBackground:(NSNotification *)notification
{
    DLog(@"applicationDidEnterBackground");
    if (_flags.recording)
        [self pauseVideoCapture];
    
    if (_flags.previewRunning) {
        [self stopPreview];
        [self _enqueueBlockOnCaptureSessionQueue:^{
            _flags.previewRunning = YES;
        }];
    }
}

#pragma mark - AV NSNotifications

// capture session handlers

- (void)_sessionRuntimeErrored:(NSNotification *)notification
{
    [self _enqueueBlockOnCaptureSessionQueue:^{
        if ([notification object] == _captureSession) {
            NSError *error = [[notification userInfo] objectForKey:AVCaptureSessionErrorKey];
            if (error) {
                switch ([error code]) {
                    case AVErrorMediaServicesWereReset:
                    {
                        DLog(@"error media services were reset");
                        [self _destroyCamera];
                        if (_flags.previewRunning)
                            [self startPreview];
                        break;
                    }
                    case AVErrorDeviceIsNotAvailableInBackground:
                    {
                        DLog(@"error media services not available in background");
                        break;
                    }
                    default:
                    {
                        DLog(@"error media services failed, error (%@)", error);
                        [self _destroyCamera];
                        if (_flags.previewRunning)
                            [self startPreview];
                        break;
                    }
                }
            }
        }
    }];
}

- (void)_sessionStarted:(NSNotification *)notification
{
    [self _enqueueBlockOnMainQueue:^{
        if ([notification object] != _captureSession)
            return;
        
        DLog(@"session was started");
        
        // ensure there is a capture device setup
        if (_currentInput) {
            AVCaptureDevice *device = [_currentInput device];
            if (device) {
                [self willChangeValueForKey:@"currentDevice"];
                _currentDevice = device;
                [self didChangeValueForKey:@"currentDevice"];
            }
        }
        
        if ([_delegate respondsToSelector:@selector(visionSessionDidStart:)]) {
            [_delegate visionSessionDidStart:self];
        }
    }];
}

- (void)_sessionStopped:(NSNotification *)notification
{
    [self _enqueueBlockOnCaptureSessionQueue:^{
        if ([notification object] != _captureSession)
            return;
        
        DLog(@"session was stopped");
        
        [self _enqueueBlockOnMainQueue:^{
            if ([_delegate respondsToSelector:@selector(visionSessionDidStop:)]) {
                [_delegate visionSessionDidStop:self];
            }
        }];
    }];
}

- (void)_sessionWasInterrupted:(NSNotification *)notification
{
    [self _enqueueBlockOnMainQueue:^{
        if ([notification object] != _captureSession)
            return;
        
        DLog(@"session was interrupted");
        
        if (_flags.recording) {
            [self _enqueueBlockOnMainQueue:^{
                if ([_delegate respondsToSelector:@selector(visionSessionDidStop:)]) {
                    [_delegate visionSessionDidStop:self];
                }
            }];
        }
        
        [self _enqueueBlockOnMainQueue:^{
            if ([_delegate respondsToSelector:@selector(visionSessionWasInterrupted:)]) {
                [_delegate visionSessionWasInterrupted:self];
            }
        }];
    }];
}

- (void)_sessionInterruptionEnded:(NSNotification *)notification
{
    [self _enqueueBlockOnMainQueue:^{
        
        if ([notification object] != _captureSession)
            return;
        
        DLog(@"session interruption ended");
        
        [self _enqueueBlockOnMainQueue:^{
            if ([_delegate respondsToSelector:@selector(visionSessionInterruptionEnded:)]) {
                [_delegate visionSessionInterruptionEnded:self];
            }
        }];
    }];
}

// capture input handler

- (void)_inputPortFormatDescriptionDidChange:(NSNotification *)notification
{
    // when the input format changes, store the clean aperture
    // (clean aperture is the rect that represents the valid image data for this display)
    AVCaptureInputPort *inputPort = (AVCaptureInputPort *)[notification object];
    if (inputPort) {
        CMFormatDescriptionRef formatDescription = [inputPort formatDescription];
        if (formatDescription) {
            _cleanAperture = CMVideoFormatDescriptionGetCleanAperture(formatDescription, YES);
            if ([_delegate respondsToSelector:@selector(vision:didChangeCleanAperture:)]) {
                [_delegate vision:self didChangeCleanAperture:_cleanAperture];
            }
        }
    }
}

// capture device handler

- (void)_deviceSubjectAreaDidChange:(NSNotification *)notification
{
    [self _adjustFocusExposureAndWhiteBalance];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ( context == (__bridge void *)AHVisionFocusObserverContext ) {
        
        BOOL isFocusing = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
        if (isFocusing) {
            [self _focusStarted];
        } else {
            [self _focusEnded];
        }
        
    }
    else if ( context == (__bridge void *)AHVisionExposureObserverContext ) {
        
        BOOL isChangingExposure = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
        if (isChangingExposure) {
            [self _exposureChangeStarted];
        } else {
            [self _exposureChangeEnded];
        }
        
    }
    else if ( context == (__bridge void *)AHVisionWhiteBalanceObserverContext ) {
        
        BOOL isWhiteBalanceChanging = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
        if (isWhiteBalanceChanging) {
            [self _whiteBalanceChangeStarted];
        } else {
            [self _whiteBalanceChangeEnded];
        }
        
    }
    else if ( context == (__bridge void *)AHVisionFlashAvailabilityObserverContext ||
             context == (__bridge void *)AHVisionTorchAvailabilityObserverContext ) {
        
        //        DLog(@"flash/torch availability did change");
        [self _enqueueBlockOnMainQueue:^{
            if ([_delegate respondsToSelector:@selector(visionDidChangeFlashAvailablility:)])
                [_delegate visionDidChangeFlashAvailablility:self];
        }];
        
    }
    else if ( context == (__bridge void *)AHVisionFlashModeObserverContext ||
             context == (__bridge void *)AHVisionTorchModeObserverContext ) {
        
        //        DLog(@"flash/torch mode did change");
        [self _enqueueBlockOnMainQueue:^{
            if ([_delegate respondsToSelector:@selector(visionDidChangeFlashMode:)])
                [_delegate visionDidChangeFlashMode:self];
        }];
        
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - AVCaptureFileOutputRecordignDelegate
- (void) timeOutputInterval
{
    CMTime duration = CMTimeAdd(_lastTimestamp, _captureMovieFileOutput.recordedDuration);
     
    
    if (_flags.paused || CMTimeCompare(_maximumCaptureDuration, duration)!=1) {
        [self _enqueueBlockOnCaptureVideoQueue:^{
            [_captureMovieFileOutput stopRecording];
        }];
    }
    
    [self _enqueueBlockOnMainQueue:^{
        if ([_delegate respondsToSelector:@selector(vision:didCaptureDuration:)])
            [_delegate vision:self didCaptureDuration:duration];
    }];
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
    vSegment *seg = [[vSegment alloc] init: fileURL withDuration:kCMTimeZero];
    [_videoSegments addObject:seg];
    
     
    
    _flags.interrupted = NO;
    
    _reCoadingtimer = [NSTimer scheduledTimerWithTimeInterval:0.05f target:self selector:@selector(timeOutputInterval) userInfo:nil repeats:YES];
    
    [self _enqueueBlockOnMainQueue:^{
        if ([_delegate respondsToSelector:@selector(visionDidStartVideoCapture:)])
            [_delegate visionDidStartVideoCapture:self];
    }];
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    _flags.interrupted = YES;
    
     
    if (_reCoadingtimer==nil){ return; };
    [_reCoadingtimer invalidate];
    _reCoadingtimer = nil;
    
    if (error) {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"写入失败,请重新拍摄" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alertView show];
//        [alertView release];
//        
//        [self _enqueueBlockOnMainQueue:^{
//            if ([_delegate respondsToSelector:@selector(vision:didCaptureDuration:)])
//                [_delegate vision:self didCaptureDuration:_lastTimestamp];
//        }];
        
        return;
    };
    
    AVCaptureMovieFileOutput *output =(AVCaptureMovieFileOutput *)captureOutput;
    
    _lastTimestamp = CMTimeAdd(_lastTimestamp, output.recordedDuration);
    
    vSegment *seg = [_videoSegments lastObject];
    seg.duration = output.recordedDuration;
    
    [self _enqueueBlockOnMainQueue:^{
        if ([_delegate respondsToSelector:@selector(visionDidPauseVideoCapture:)])
            [_delegate visionDidPauseVideoCapture:self];
    }];
}

@end
