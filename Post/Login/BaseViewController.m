//
//  BaseViewController.m
//  NewWelcome
//
//  Created by chinalong on 16/7/18.
//  Copyright © 2016年 com.chinalong. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 解决当  viewController.hidesBottomBarWhenPushed = YES;时导航栏出现的灰色阴影
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor colorWithHexString:@"ebebeb"];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
