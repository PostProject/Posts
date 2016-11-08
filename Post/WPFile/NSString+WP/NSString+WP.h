//
//  NSString+WP.h
//  HuanYinBusiness
//
//  Created by chinalong on 16/2/26.
//  Copyright © 2016年 com.chinalong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface NSString (WP)
/**
 *  计算文本高度
 *
 *  @param font    需要计算的文本
 *  @param maxSize 文本显示的字体
 *
 *  @return 文本显示的范围
 */
- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize;
// 元-->分
+ (NSString *)yuanTransitionFen:(NSString *)yuan;
// 分-->元
+ (NSString *)fenTransitionYuan:(NSString *)fen;
//  格式化8位时间 
+ (NSString *)formateDate:(NSString *)inputDate formateType:(NSString *)type;

// 格式化开业时间 4位
+ (NSString *)formateTime:(NSString *)inputDate formateType:(NSString *)type;

+ (BOOL)judgeDateSpaceStart:(NSString *)start end:(NSString *)end;

@end
