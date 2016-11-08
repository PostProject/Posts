//
//  UIColor+WP.h
//  NewWelcome
//
//  Created by chinalong on 16/7/18.
//  Copyright © 2016年 com.chinalong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (WP)

+ (UIColor *) colorWithHexString: (NSString *) stringToConvert;

+(UIColor*)colorWithR:(CGFloat)r G:(CGFloat)g B:(CGFloat)b A:(CGFloat)a;


@end
