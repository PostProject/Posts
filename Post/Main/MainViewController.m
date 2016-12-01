//
//  MainViewController.m
//  Post
//
//  Created by admin on 2016/11/3.
//  Copyright © 2016年 Post. All rights reserved.
//

#import "MainViewController.h"
#import "LoginViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addStoryBoard:@"DynamicStoryboard"];
    [self addStoryBoard:@"FriendsStoryboard"];
    [self addStoryBoard:@"MessageStoryboard"];
    [self addStoryBoard:@"MyStoryboard"];
    
    
}
-(void)addStoryBoard:(NSString *)stroyName{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:stroyName bundle:nil];
    [self addChildViewController:storyBoard.instantiateInitialViewController];
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
