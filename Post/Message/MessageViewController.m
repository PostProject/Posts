//
//  MessageViewController.m
//  Post
//
//  Created by admin on 2016/11/3.
//  Copyright © 2016年 Post. All rights reserved.
//

#import "MessageViewController.h"
#import "WPNoticeTableViewCell.h"


@interface MessageViewController () <UITableViewDataSource,UITableViewDelegate,CleanDelegate>


@property (nonatomic,strong) UITableView *noticeTableView; // 好友



@end

@implementation MessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"信息";
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.noticeTableView];
    
}


- (UITableView *)noticeTableView {
    
    if (!_noticeTableView) {
        
        _noticeTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-TabBarHeight) style:UITableViewStylePlain];
        _noticeTableView.dataSource = self;
        _noticeTableView.delegate = self;
        _noticeTableView.rowHeight = 60;
        _noticeTableView.backgroundColor = self.view.backgroundColor;
        
    }
    return _noticeTableView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 30;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0.000001;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    VoiceHeadView *headView = [[VoiceHeadView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 30)];
    headView.lbTxt.text = @"今天";
    headView.cleanDelegate = self;
    headView.section = section;
    return headView;
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 10;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WPNoticeTableViewCell *cell = [WPNoticeTableViewCell cellWithTableView:tableView];
    return cell;
    
}


- (void)cleanNotice:(NSInteger)index {
    
    
    NSLog(@"%li",index);
    
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
