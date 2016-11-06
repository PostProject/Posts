//
//  IPTakeVideoViewController.m
//  IPickerDemo
//
//  Created by Wangjianlong on 16/4/11.
//  Copyright © 2016年 JL. All rights reserved.
//

#import "IPTakeVideoViewController.h"
#import "IPCaptureProgressBar.h"
#import "IPTooltipView.h"
#define ScreenSize ([UIScreen mainScreen].bounds.size)
@interface IPTakeVideoViewController ()<AHVisionDelegate,AHCaptureProgressDegelate,UIAlertViewDelegate>
{
    UIView *_previewView;
    
    IPCaptureProgressBar *_progressBar;
    UILabel *_progressLabel;
    
    UIButton *_cancelBtn;
    UIButton *_flipBtn;
    UIButton *_deleteBtn;
    UIButton *_doneBtn;
    UIButton *_recordBtn;
    UIView *_shadeView;
    
    UILabel *_tipLabel;
    IPTooltipView *_tooltipView;
    
    UILongPressGestureRecognizer *_longPressGestureRecognizer;
    
    NSInteger _segmentCount;
}
@end

@implementation IPTakeVideoViewController
@synthesize maximumCaptureDuration;
@synthesize minimumCaptureDuration;
@synthesize exportVideoWidth;
@synthesize exportVideoHeight;
@synthesize exportPresetQuality;
-(void)setMaximumCaptureDuration:(Float64)value
{
    maximumCaptureDuration = value>0.0f?value:30.0f;;
}

-(void)setMinimumCaptureDuration:(Float64)value
{
    minimumCaptureDuration = value>0.0f?value:10.0f;
}

-(void)setExportPresetQuality:(NSInteger)value
{
    exportPresetQuality = (value<1 || value>3)?2:value;
}

-(void)setExportVideoWidth:(CGFloat)value
{
    exportVideoWidth = value>0.0f?value:480.0f;
}

-(void)setExportVideoHeight:(CGFloat)value
{
    exportVideoHeight = value>0.0f?value:480.0f;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.hidden = YES;
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    //输出视频高宽比
    CGFloat videoHWRate = self.exportVideoHeight/self.exportVideoWidth;
    //短屏设备头部高50 其它的100
    CGFloat top = (ScreenSize.height < 500) ? 50 : 100;
    CGFloat viewWidth = self.view.bounds.size.width;
    CGFloat viewHeight = self.view.bounds.size.height;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, top)];
    [self.view addSubview:headerView];
    [self initHeader:headerView];
    
    
    CGFloat middleHeight = viewWidth * videoHWRate + 10;
//    CGFloat margin = (viewHeight - CGRectGetHeight(headerView.frame) - CGRectGetHeight(bottomView.frame) - middleHeight )/2;
    CGFloat middleY = CGRectGetMaxY(headerView.frame);
    
    UIView *middleView = [[UIView alloc] initWithFrame:CGRectMake(0, middleY, viewWidth, middleHeight)];
    [self.view addSubview:middleView];
    [self initMiddle:middleView];
    
//    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0,CGRectGetMaxY(middleView.frame), ScreenSize.width, ScreenSize.height - CGRectGetHeight(middleView.frame))];
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0,viewHeight - 120 - 50, viewWidth, 120)];
    [self.view addSubview:bottomView];
    [self initBottom:bottomView];
    
    
    
   
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //ios7+ 才支持相机禁用设置
    if ([[UIDevice currentDevice].systemVersion doubleValue] >= 7.0f) {
        void (^requestBlock)(BOOL) = ^(BOOL granted)
        {
            if (granted) return;
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"请在“设置-隐私”选项中，允许汽车之家访问您的相机" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            alertView.tag = 100;
            [alertView show];
        };
        
        AVAuthorizationStatus videoStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if(videoStatus == AVAuthorizationStatusDenied)
        {
            requestBlock(false);
        }
        else if(videoStatus == AVAuthorizationStatusNotDetermined)
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:requestBlock];
        }
    }
    
    // iOS 6 support
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [self _resetCapture];
    [[IPVision sharedInstance] startPreview];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[IPVision sharedInstance] stopPreview];
    
    // iOS 6 support
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}
#pragma mark UI Init

- (void) initHeader:(UIView *)headerView
{
    [headerView setBackgroundColor:[UIColor blackColor]];
    CGFloat height = CGRectGetHeight(headerView.frame);
    
    _cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(5, (height-50)/2, 50, 50)];
//    [_cancelBtn setImageKey:vision_btn_icon_close];
//    [_cancelBtn setImageSelectedKey:vision_btn_icon_close_p];
    [_cancelBtn setImage:[UIImage imageNamed:@"AHVision_icon_close"] forState:UIControlStateNormal];
    [_cancelBtn setImage:[UIImage imageNamed:@"AHVision_icon_close_p"] forState:UIControlStateSelected];
    [_cancelBtn setImageEdgeInsets:UIEdgeInsetsMake(12.5, 12.5, 12.5, 12.5)];
    [_cancelBtn addTarget:self action:@selector(_handleCancelBtn:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:_cancelBtn];
    
    _progressLabel = [[UILabel alloc] initWithFrame:CGRectMake((ScreenSize.width-120)/2, (height-20)/2, 120, 20)];
//    [_progressLabel setTextColorKey:textcolor09];
//    [_progressLabel setFontKey:textfont09];
    [_progressLabel setText:[NSString stringWithFormat:@"00:00/00:%02.0f",self.maximumCaptureDuration]];
    [headerView addSubview:_progressLabel];
    
    _flipBtn = [[UIButton alloc] initWithFrame:CGRectMake(ScreenSize.width-50-5, (height-50)/2, 50, 50)];
//    [_flipBtn setImageKey:vision_btn_icon_camera_back];
//    [_flipBtn setImageSelectedKey:vision_btn_icon_camera_front];
    [_flipBtn setImage:[UIImage imageNamed:@"AHVision_icon_camera_back"] forState:UIControlStateNormal];
    [_flipBtn setImage:[UIImage imageNamed:@"AHVision_icon_camera_front"] forState:UIControlStateSelected];
    [_flipBtn setImageEdgeInsets:UIEdgeInsetsMake(12.5, 12.5, 12.5, 12.5)];
    [_flipBtn addTarget:self action:@selector(_handleFlipBtn:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:_flipBtn];
}

- (void) initMiddle:(UIView *)middleView
{
    [middleView setBackgroundColor:[UIColor blackColor]];
    // preview and AV layer
//    _previewView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenSize.width,middleView.frame.size.height-10)];
    _previewView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenSize.width,ScreenSize.width*9/16)];
    _previewView.backgroundColor = [UIColor blackColor];
    AVCaptureVideoPreviewLayer *_previewLayer = [[IPVision sharedInstance] previewLayer];
    _previewLayer.frame = _previewView.bounds;
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [_previewView.layer addSublayer:_previewLayer];
    [middleView addSubview:_previewView];
    
//    _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _previewView.frame.size.height-40,ScreenSize.width, 40)];
    _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _previewView.frame.size.height + 15,ScreenSize.width, 40)];
    [_tipLabel setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6f]];
//    [_tipLabel setBackgroundColorKey:bgcolor19];
//    [_tipLabel setAlpha:0.6];
//    [_tipLabel setTextColorKey:textcolor01];
//    [_tipLabel setFontKey:textfont04];
    [_tipLabel setTextColor:[UIColor whiteColor]];
    [_tipLabel setTextAlignment:NSTextAlignmentCenter];
    [_tipLabel setText:@"长按蓝色按钮进行拍摄"];
    [middleView addSubview:_tipLabel];
    
    _progressBar = [[IPCaptureProgressBar alloc] initWithFrame:CGRectMake(0,CGRectGetMaxY(_previewView.frame), ScreenSize.width, 10)];
    _progressBar.delegate = self;
    _progressBar.maxValue = self.maximumCaptureDuration;
    _progressBar.limitValue = self.minimumCaptureDuration;
    [middleView addSubview:_progressBar];
    
    _tooltipView = [[IPTooltipView alloc] initWithFrame:CGRectMake(ScreenSize.width*self.minimumCaptureDuration/self.maximumCaptureDuration-60, _previewView.frame.size.height-40,120, 40)];
    [_tooltipView setText:@"最少拍到这里"];
    [_tooltipView setHidden:YES];
    [middleView addSubview:_tooltipView];
}

- (void) initBottom:(UIView *)bottomView
{
    [bottomView setBackgroundColor:[UIColor blackColor]];
    
    _deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, (CGRectGetHeight(bottomView.frame)-76)/2, 76, 76)];
    [_deleteBtn setEnabled:NO];
    [_deleteBtn setSelected:NO];
//    [_deleteBtn setBackgroundImageDisabledKey:vision_btn_icon_delete_d];
//    [_deleteBtn setBackgroundImageKey:vision_btn_icon_delete];
//    [_deleteBtn setBackgroundImageSelectedKey:vision_btn_icon_delete_p];
    
    [_deleteBtn setBackgroundImage:[UIImage imageNamed:@"AHVision_icon_delete"] forState:UIControlStateNormal];
    [_deleteBtn setBackgroundImage:[UIImage imageNamed:@"AHVision_icon_delete_d"] forState:UIControlStateSelected];
    [_deleteBtn setBackgroundImage:[UIImage imageNamed:@"AHVision_icon_delete_p"] forState:UIControlStateHighlighted];
    
    [_deleteBtn addTarget:self action:@selector(_hanldeDeleteBtn:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:_deleteBtn];
    
    _doneBtn = [[UIButton alloc] initWithFrame:CGRectMake(ScreenSize.width-76-20, (CGRectGetHeight(bottomView.frame)-76)/2, 76, 76)];
//    [_doneBtn setBackgroundImageKey:vision_btn_icon_done];
//    [_doneBtn setBackgroundImageSelectedKey:vision_btn_icon_done_d];
//    [_doneBtn setBackgroundImageHighlightedKey:vision_btn_icon_done_p];
    [_doneBtn setBackgroundImage:[UIImage imageNamed:@"AHVision_icon_finish"] forState:UIControlStateNormal];
    [_doneBtn setBackgroundImage:[UIImage imageNamed:@"AHVision_icon_finish_d"] forState:UIControlStateSelected];
    [_doneBtn setBackgroundImage:[UIImage imageNamed:@"AHVision_icon_finish_p"] forState:UIControlStateHighlighted];
    [_doneBtn addTarget:self action:@selector(_handleDoneBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_doneBtn setSelected:YES];
    [bottomView addSubview:_doneBtn];
    
    _shadeView = [[UIView alloc] initWithFrame:bottomView.bounds];
    [_shadeView setBackgroundColor:[UIColor clearColor]];
    [_shadeView setHidden:NO];
    [bottomView addSubview:_shadeView];
    
    _recordBtn = [[UIButton alloc] initWithFrame:CGRectMake((ScreenSize.width-120)/2, (CGRectGetHeight(bottomView.frame)-120)/2, 120, 120)];
    [_recordBtn setEnabled:NO];
//    [_recordBtn setBackgroundImageKey:vision_icon_video];
//    [_recordBtn setBackgroundImageSelectedKey:vision_icon_video_p];
    [_recordBtn setBackgroundImage:[UIImage imageNamed:@"AHVision_icon_video"] forState:UIControlStateNormal];
    [_recordBtn setBackgroundImage:[UIImage imageNamed:@"AHVision_icon_video_p"] forState:UIControlStateNormal];
    [bottomView addSubview:_recordBtn];
    
    _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc]
                                   initWithTarget:self action:@selector(_handleLongPressGestureRecognizer:)];
    _longPressGestureRecognizer.minimumPressDuration = 0.1f;
    _longPressGestureRecognizer.allowableMovement = 10.0f;
    
    [_recordBtn addGestureRecognizer:_longPressGestureRecognizer];
}
- (void)dealloc
{
    [IPVision sharedInstance].delegate = nil;
}

#pragma mark - init & dealloc
-(instancetype)init
{
    if (self=[super init]) {
        self.maximumCaptureDuration = 30.0f;
        self.minimumCaptureDuration = 10.0f;
        self.exportPresetQuality = 2;
//        self.exportVideoWidth = 480.0f;
//        self.exportVideoHeight = 360.0f;
        self.exportVideoWidth = [UIScreen mainScreen].bounds.size.width;
         self.exportVideoHeight = self.exportVideoWidth * 9/16;
    }
    return self;
}

- (void) _handleCancelBtn:(id)sender
{
    //是否放弃这段视频？
    IPVision *vision = [IPVision sharedInstance];
    if(vision.capturedVideoSeconds>0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否放弃这段视频？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = 101;
        [alertView show];
    }
    else
    {
        [[IPVision sharedInstance] cancelVideoCapture];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
- (void) _handleDoneBtn:(UIButton *)sender
{
    if (!sender.selected) {
        if ([[IPVision sharedInstance] endVideoCapture]) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    else{
        if(!_tooltipView.hidden) return;
        
        //“最少拍摄到这”提示框上下跳动效果
        _tooltipView.transform = CGAffineTransformIdentity;
        _tooltipView.hidden = NO;
        
        [UIView beginAnimations:@"earthquake" context:(__bridge void * _Nullable)(_tooltipView)];
        [UIView setAnimationRepeatAutoreverses:YES];// important
        [UIView setAnimationRepeatCount:3];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(earthquakeEnded:finished:context:)];
        
        _tooltipView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, -4);// end here & auto-reverse
        [UIView commitAnimations];
    }
}

-(void)earthquakeEnded:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context
{
    _tooltipView.transform = CGAffineTransformIdentity;
    _tooltipView.hidden = YES;
}

-(void) _hanldeDeleteBtn:(UIButton *)sender
{
    BOOL isDel = sender.selected;
    //    PLog(@"isDel = %i",isDel);
    [_progressBar delete: isDel ];
    if (isDel) {
        [[IPVision sharedInstance] backspaceVideoCapture];
    }
    sender.selected = !isDel;
    [_tipLabel setHidden:YES];
}
-(void) _handleFlipBtn:(UIButton *) sender
{
    IPVision *vision = [IPVision sharedInstance];
    vision.cameraDevice = vision.cameraDevice == AHCameraDeviceBack ? AHCameraDeviceFront : AHCameraDeviceBack;
    
    sender.selected = ! sender.selected;
    //按钮翻转效果处理
    [UIView transitionWithView: sender
                      duration: 1.0f
                       options: UIViewAnimationOptionTransitionFlipFromLeft+UIViewAnimationOptionCurveEaseInOut
                    animations: nil
                    completion: nil];
}


-(void) _handleLongPressGestureRecognizer:(UILongPressGestureRecognizer *)sender
{
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
        {
            [self _startCapture];
            _recordBtn.selected = YES;
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            [self _pauseCapture];
            _recordBtn.selected = NO;
            break;
        }
        default:
            break;
    }
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag ==100) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if (alertView.tag==101){
        if (buttonIndex==1) {
            [[IPVision sharedInstance] cancelVideoCapture];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}
#pragma mark - private start/stop helper methods

- (void)_startCapture
{
    IPVision * vision = [IPVision sharedInstance];
    
    if(!vision.isRecording)
    {
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        [vision startVideoCapture];
    }
    else{
        [vision resumeVideoCapture];
    }
}

- (void)_pauseCapture
{
    [[IPVision sharedInstance] pauseVideoCapture];
}

- (void)_resumeCapture
{
    
}

- (void)_endCapture
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [[IPVision sharedInstance] endVideoCapture];
}

- (void)_resetCapture
{
    _longPressGestureRecognizer.enabled = YES;
    
    IPVision *vision = [IPVision sharedInstance];
    vision.delegate = self;
    
    if ([vision isCameraDeviceAvailable:AHCameraDeviceBack]) {
        vision.cameraDevice = AHCameraDeviceBack;
        _flipBtn.hidden = NO;
    } else {
        vision.cameraDevice = AHCameraDeviceFront;
        _flipBtn.hidden = YES;
    }
    
    vision.maximumCaptureDuration = CMTimeMake(self.maximumCaptureDuration, 1);
    vision.exportPresetQuality = self.exportPresetQuality;
    vision.exportVideoWidth = self.exportVideoWidth;
    vision.exportVideoHeight = self.exportVideoHeight;
    vision.cameraOrientation = AHCameraOrientationPortrait;
    vision.focusMode = AHFocusModeContinuousAutoFocus;
    
    [vision resetVideoCapture];
}

#pragma mark AHVisionDelegate
- (void)visionSessionDidStartPreview:(IPVision *)vision
{
    [_recordBtn setEnabled:YES];
}

//-(void)visionSessionDidStart:(AHVision *)vision
//{
//    [_recordBtn setEnabled:YES];
//}

- (void)visionDidStartVideoCapture:(IPVision *)vision
{
    [_shadeView setHidden:NO];
    [_tipLabel setHidden:YES]; //隐藏“长按蓝色按钮进行拍摄“提示
}

- (void)visionDidPauseVideoCapture:(IPVision *)vision
{
    [_shadeView setHidden:YES];
    [_progressBar interrupt];
    _segmentCount++;
    
    if (_segmentCount==1) {
        [_tipLabel setText:@"点击左下角删除按钮可分段删除"];
        [_tipLabel setHidden:NO];
    }
}

- (void)visionDidResumeVideoCapture:(IPVision *)vision
{
    [_tipLabel setHidden:YES];
}

-(void) visionDidEndVideoCapture:(IPVision *)vision
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(VisionDidCaptureFinish:withThumbnail:withVideoDuration:)]){
        [self.delegate VisionDidCaptureFinish:vision withThumbnail:vision.thumbnail withVideoDuration:_progressBar.currentValue];
    }
}

- (void)vision:(IPVision *)vision didCaptureDuration:(CMTime)duration
{
    [_progressBar setProgressValue:CMTimeGetSeconds(duration)];
}

#pragma mark - AHCaptureProgressDelegate

-(void) captureProgress:(IPCaptureProgressBar *)sender
{
    [_progressLabel setText:[NSString stringWithFormat:@"00:%02.0f/00:%02.0f",
                             floor(_progressBar.currentValue),_progressBar.maxValue]];
    
    [_doneBtn setSelected:_progressBar.currentValue<_progressBar.limitValue];
    [_deleteBtn setSelected:NO];
    [_deleteBtn setEnabled:_progressBar.segmentCount>0];
}

@end
