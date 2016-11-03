//
//  DynamicViewController.m
//  Post
//
//  Created by admin on 2016/11/3.
//  Copyright © 2016年 Post. All rights reserved.
//

#import "DynamicViewController.h"



@interface DynamicViewController ()
{
    UIButton *_btnDyanmic;
    UIButton *_btnCircle;
    UIView *_titleLine;
}

@end

@implementation DynamicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.title = @"动态";
    
    
}
-(void)loadView{
    [super loadView];
    UIButton *btnsearch = [UIButton buttonWithType:UIButtonTypeCustom];
    btnsearch.frame = CGRectMake(0, 0, 35, 35);
    btnsearch.tag = 1;
    [btnsearch addTarget:self action:@selector(topAction:) forControlEvents:UIControlEventTouchUpInside];
//    btnsearch.backgroundColor = [UIColor redColor];
    UIImageView *search = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
    search.image = [UIImage imageNamed:@"search.png"];
    search.frame = CGRectMake(0, 0, 20, 20);
    search.center = btnsearch.center;
    [btnsearch addSubview:search];
    
    UIBarButtonItem *searchItem = [[UIBarButtonItem  alloc]initWithCustomView:btnsearch];
    
    UIButton *btnAdd = [UIButton buttonWithType:UIButtonTypeCustom];
    btnAdd.frame = CGRectMake(0, 0, 35, 35);
    btnAdd.tag = 2;
    [btnAdd addTarget:self action:@selector(topAction:) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *add = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
    add.image = [UIImage imageNamed:@"add.png"];
    add.frame = CGRectMake(0, 0, 20, 20);
    add.center = btnsearch.center;
    [btnAdd addSubview:add];
    
    UIBarButtonItem *addItem = [[UIBarButtonItem  alloc]initWithCustomView:btnAdd];
    
    self.navigationItem.rightBarButtonItems = @[searchItem,addItem];
    
    UIView *title = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    _btnDyanmic = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnDyanmic.frame = CGRectMake(0, 0, 40, 40);
    _btnDyanmic.center = CGPointMake(20, 20);
    _btnDyanmic.tag = 1;
    [_btnDyanmic addTarget:self action:@selector(titleAction:) forControlEvents:UIControlEventTouchUpInside];
    [_btnDyanmic setTitle:@"动态" forState:UIControlStateNormal];
    [_btnDyanmic setTitleColor:APPCOLOR forState:UIControlStateNormal];
    [title addSubview:_btnDyanmic];
    
    _btnCircle = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnCircle.tag = 2;
    _btnCircle.frame = CGRectMake(0, 0, 40, 40);
    _btnCircle.center = CGPointMake(80, 20);
    [_btnCircle addTarget:self action:@selector(titleAction:) forControlEvents:UIControlEventTouchUpInside];
    [_btnCircle setTitle:@"圈子" forState:UIControlStateNormal];
    [_btnCircle setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [title addSubview:_btnCircle];
    
    _titleLine = [[UIView alloc] initWithFrame:CGRectMake(0, 38, 42, 1)];
    _titleLine.center = CGPointMake(20, 38);
    _titleLine.backgroundColor = APPCOLOR;
    [title addSubview:_titleLine];
    
    self.navigationItem.titleView = title;
    
    
}
-(void)titleAction:(UIButton *)btn{
    [btn setTitleColor:APPCOLOR forState:UIControlStateNormal];
    NSInteger tag = btn.tag;
    if (tag == 1) {
        [UIView animateWithDuration:0.3 animations:^{
            _titleLine.center = CGPointMake(20, 38);
        }];
       [_btnCircle setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

    }else{
        [UIView animateWithDuration:0.3 animations:^{
            _titleLine.center = CGPointMake(74, 38);
        }];
        [_btnDyanmic setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
}
-(void)topAction:(UIButton *)btn{
    NSInteger tag = btn.tag;
    if (tag == 1) {
        MyLog(@"搜索");
        return;
    }
    MyLog(@"添加");
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
