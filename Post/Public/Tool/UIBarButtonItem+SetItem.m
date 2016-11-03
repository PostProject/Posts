//
//  UIBarButtonItem+SetItem.m
//  Post
//
//  Created by admin on 2016/11/3.
//  Copyright © 2016年 Post. All rights reserved.
//

#import "UIBarButtonItem+SetItem.h"

@implementation UIBarButtonItem (SetItem)
+(UIBarButtonItem *)setbarButtonItem:(NSString *)imageName{
    UIButton *item = [UIButton buttonWithType:UIButtonTypeCustom];
    [item setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    item.frame = CGRectMake(0, 0, 20, 20);
    return [[UIBarButtonItem alloc] initWithCustomView:item];
    
    
}

@end
