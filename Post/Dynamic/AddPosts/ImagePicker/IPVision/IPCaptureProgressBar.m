//
//  AHCaptureProgressBar.m
//  Samples.PBJVisionDemo
//
//  Created by yuchimin on 14-11-11.
//  Copyright (c) 2014年 com.autohome. All rights reserved.
//

#import "IPCaptureProgressBar.h"

@implementation IPCaptureProgressBar
@synthesize maxValue,limitValue,currentValue,segmentCount;

UIView *_cursor;
UIView *_progressView;
UIView *_selectView;
UIView *_limitView;

NSMutableArray *_separators;

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 */
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingNone;
        self.backgroundColor = [UIColor colorWithRed:51/255.0f green:51/255.0f blue:51/255.0f alpha:1.0f];
        
        //分隔线
        _separators = [[NSMutableArray alloc] init];
        
        _limitView = [[UIView alloc] init];
        [_limitView setBackgroundColor:[UIColor whiteColor]];
        _limitView.alpha = 0.7;
        [self addSubview:_limitView];

        //进度条
        _progressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0,CGRectGetHeight(self.bounds))];
        [_progressView setBackgroundColor:[UIColor colorWithRed:70/255.0f green:128/255.0f blue:209/255.0f alpha:1.0f]];
        [self addSubview:_progressView];
        
        [self initCursor:frame];
        
        //选择层
        _selectView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGRectGetHeight(self.bounds))];
        [_selectView setBackgroundColor:[UIColor colorWithRed:0/255.0f green:78/255.0f blue:186/255.0f alpha:1.0f]];
        _selectView.hidden = YES;
        [self addSubview:_selectView];

    }
    return self;
}




-(NSInteger) segmentCount
{
    return _separators.count;
}

//光标闪烁效果
-(void) cursorBlink
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];//必须写opacity才行。
    animation.fromValue = [NSNumber numberWithFloat:1.0f];
    animation.toValue = [NSNumber numberWithFloat:0.0f];//这是透明度。
    animation.autoreverses = YES;
    animation.duration = 0.5f;
    animation.repeatCount = MAXFLOAT;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];///没有的话是均匀的动画。
    [_cursor.layer addAnimation:animation forKey:nil];
}

//初始化光标
-(void) initCursor:(CGRect)rect
{
    _cursor = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 4, rect.size.height)];
    [_cursor setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:_cursor];
    [self cursorBlink];
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    if(self.maxValue ==0) self.maxValue = 100.0f;
    
    //最先限制标记线
    CGFloat width = CGRectGetWidth(rect);
    CGFloat heigh = CGRectGetHeight(rect);
    
    _limitView.frame =CGRectMake(limitValue/maxValue*width-1, 0, 2, heigh);
}

-(void)setProgressValue:(Float64)value
{
    if (isnan(value)) return;
    value = MIN(value, maxValue);
    if (value == currentValue) return;
    
    _selectView.hidden = YES;

    CGFloat width = value/self.maxValue * CGRectGetWidth(self.bounds);
    CGRect frame = _progressView.frame;
    frame.size.width = width;
    _progressView.frame = frame;
    
    //移动光标
    _cursor.center = CGPointMake(width+2,CGRectGetHeight(self.bounds)/2);
    
    currentValue = value;
    
    if (self.delegate) {
        [self.delegate captureProgress:self];
    }
}


-(void) interrupt
{
    CGFloat left = currentValue/self.maxValue * CGRectGetWidth(self.bounds);
    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(left, 0, 0.5f, CGRectGetHeight(self.bounds))];
    [separatorView setBackgroundColor:[UIColor blackColor]];
    separatorView.tag = currentValue; //记录当前分隔线位置的currentValue值
    [self insertSubview:separatorView belowSubview:_cursor];
    [_separators addObject:separatorView];
    
    
    if (self.delegate) {
        [self.delegate captureProgress:self];
    }
}

-(void) delete:(BOOL)determine
{
    if (determine) {
        //删除
        UIView *last = [_separators lastObject];
        [_separators removeLastObject];
        [last removeFromSuperview];
        
        UIView *separator = [_separators lastObject];
        Float64 value = separator?separator.frame.origin.x*maxValue/CGRectGetWidth(self.bounds) :0;
        [self setProgressValue:value];
        _selectView.hidden = YES;
    }
    else{
        //设置删除确认效果，还未正式删除
        UIView *separator = _separators.count>1?[_separators objectAtIndex:_separators.count-2]:nil;
        CGFloat left = separator ? separator.frame.origin.x:0;
        CGFloat width = _progressView.frame.size.width - left;
        CGRect frame = CGRectMake(left, 0, width, CGRectGetHeight(self.bounds));
        _selectView.frame = frame;
        _selectView.hidden = NO;
    }
}
@end
