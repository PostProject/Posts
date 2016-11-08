//
//  NSString+WP.m
//  HuanYinBusiness
//
//  Created by chinalong on 16/2/26.
//  Copyright © 2016年 com.chinalong. All rights reserved.
//

#import "NSString+WP.h"
#import "WPHelpUtil.h"
@implementation NSString (WP)


- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize {
    
    NSDictionary *dict = @{NSFontAttributeName : font};
    // 如果将来计算的文字的范围超出了指定的范围,返回的就是指定的范围
    // 如果将来计算的文字的范围小于指定的范围, 返回的就是真实的范围
    // if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_0)
    
    if (self) {
        CGRect rect = [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil];
        if (rect.size.width == 0 && rect.size.height == 0) {
            return maxSize;
        }
        return rect.size;
    }else {
        return CGSizeZero;
    }
}

// 元 -- 分
+ (NSString *)yuanTransitionFen:(NSString *)yuan {
    if ([WPHelpUtil isBlankString:yuan]) {
        return @"";
    }
    float fen = [yuan floatValue]*100;
    return [NSString stringWithFormat:@"%.0f",fen];
    
}
// 分 -- 元
+ (NSString *)fenTransitionYuan:(NSString *)fen {
    if ([WPHelpUtil isBlankString:fen]) {
        return @"";
    }
    float yuan = [fen floatValue]/100;
    return [NSString stringWithFormat:@"%.2f",yuan];
}

// 将8为年月日拼接成任意类型
+ (NSString *)formateDate:(NSString *)inputDate formateType:(NSString *)type {
    
    if (inputDate.length != 8) {
        return inputDate;
    }
    NSString *year = [inputDate substringToIndex:4];
    NSString *temp = [inputDate substringFromIndex:4];
    NSString *month = [temp substringToIndex:2];
    NSString *day = [temp substringFromIndex:2];
    
    return [NSString stringWithFormat:@"%@%@%@%@%@",year,type,month,type,day];
}

//+ (NSString *)repalce



+ (NSString *)formateTime:(NSString *)inputDate formateType:(NSString *)type {
    
    
    if (inputDate.length != 4) {
        return inputDate;
    }
    NSString *hour = [inputDate substringToIndex:2];
    NSString *minite = [inputDate substringFromIndex:2];
    return [NSString stringWithFormat:@"%@%@%@",hour,type,minite];
}

// 判断时间间隔 超过一个月 返回NO
+ (BOOL)judgeDateSpaceStart:(NSString *)start end:(NSString *)end {

    NSInteger year11 = [[start substringToIndex:4] integerValue];
    NSInteger month11 = [[[start substringFromIndex:4] substringToIndex:2] integerValue];
    NSInteger day11 = [[[start substringFromIndex:4] substringFromIndex:2] integerValue];
    
    NSInteger year22 = [[end substringToIndex:4] integerValue];
    NSInteger month22 = [[[end substringFromIndex:4] substringToIndex:2] integerValue];
    NSInteger day22 = [[[end substringFromIndex:4] substringFromIndex:2] integerValue];
    
    //  年相差 > 1
    if (year22 - year11 > 1) {
        return NO;
    }
    // 年相差1  月份相差 > 1
    else if (year22 - year11 == 1 && month22+12-month11 > 1) {
        return NO;
    }
    // 年相差1 月份相差 1
    else if (year22 - year11 == 1 && month22+12-month11 == 1 && day11 < day22) {
        return NO;
    }
    // 年相等 月份相差 > 1
    else if (year22 == year11 && month22  - month11 > 1) {
        return NO;
    }
    // 年相等 月份相差 1
    else if (year22 == year11 && month22  - month11 == 1 && day11 < day22) {
        return NO;
    }

    return YES;
}


@end
