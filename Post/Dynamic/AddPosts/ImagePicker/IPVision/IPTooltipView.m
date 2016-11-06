//
//  AHTooltipView.m
//  Samples.AHVision
//
//  Created by yuchimin on 14-11-24.
//  Copyright (c) 2014年 com.autohome. All rights reserved.
//

#import "IPTooltipView.h"

@implementation IPTooltipView

@synthesize font,text,textColor;


- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _init];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self _init];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _init];
    }
    return self;
}


- (void) _init
{
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    self.font = [UIFont boldSystemFontOfSize:15.0];
    self.text = @"";
    self.textColor = [UIColor whiteColor];
}

- (void) dealloc
{
    self.font = nil;
    self.text = nil;
    self.textColor = nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.*/

- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect); //clear backgroundColor
    
    // Background
    [self.backgroundColor set];
    //CGContextSetAlpha(context, self.alpha);
    CGContextFillRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height-8));
    
    CGPoint sPoints[3] = {
        CGPointMake(rect.size.width/2-5, rect.size.height-8),
        CGPointMake(rect.size.width/2+5, rect.size.height-8),
        CGPointMake(rect.size.width/2, rect.size.height)
    };
    CGContextAddLines(context, sPoints, 3);//添加线
    CGContextClosePath(context);//封起来
    CGContextFillPath(context); //填充
    
    CGSize textsize = [self.text sizeWithFont:self.font
                            constrainedToSize:CGSizeMake(MAXFLOAT, 0.0)
                                lineBreakMode:NSLineBreakByWordWrapping];
    // text
    [self.textColor set];
    [self.text drawInRect:CGRectMake((rect.size.width-textsize.width)/2, (rect.size.height-8-textsize.height)/2, rect.size.width-10, rect.size.height-10) withFont:self.font];
    
}
@end
