//
//  MyFriendViewController.m
//  BigRound
//
//  Created by 王海鹏 on 16/10/12.
//  Copyright © 2016年 王海鹏. All rights reserved.
//

#import "MyFriendViewController.h"
#import "UIBarButtonItem+WP.h"

@interface MyFriendViewController ()

@end

@implementation MyFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem newItemWithTarget:self action:@selector(backAction) normalImg:@"back" higLightImg:@"back"];
    
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
