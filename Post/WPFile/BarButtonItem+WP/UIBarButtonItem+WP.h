//
//  UIBarButtonItem+WP.h
//  NewWelcomeBusiness
//
//  Created by chinalong on 16/8/16.
//  Copyright © 2016年 com.chinalong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (WP)

/**
 *  文字类型的item
 *
 *  @param target <#target description#>
 *  @param action <#action description#>
 *  @param title  <#title description#>
 *
 *  @return <#return value description#>
 */
+ (UIBarButtonItem *)newItemWithTarget:(id)target action:(SEL)action title:(NSString *)title;

/**
 *  设置图片的item
 *
 *  @param target <#target description#>
 *  @param action <#action description#>
 *  @param image  <#image description#>
 *
 *  @return <#return value description#>
 */
+ (UIBarButtonItem *)newItemWithTarget:(id)target action:(SEL)action normalImg:(NSString *)normalImg higLightImg:(NSString *)higLightImg;


/**
 *  扫一扫按钮
 *
 *  @param target <#target description#>
 *  @param action <#action description#>
 *
 *  @return <#return value description#>
 */
+ (UIBarButtonItem *)sysItemWithTarget:(id)target action:(SEL)action;

@end
