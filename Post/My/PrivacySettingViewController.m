//
//  PrivacySettingViewController.m
//  BigRound
//
//  Created by 王海鹏 on 16/10/12.
//  Copyright © 2016年 王海鹏. All rights reserved.
//

#import "PrivacySettingViewController.h"
#import "WPPrivicyTableViewCell11.h"
#import "UIBarButtonItem+WP.h"


@interface PrivacySettingViewController () <UITableViewDataSource,UITableViewDelegate,PrivicyDelegate>


@property (nonatomic,strong) UITableView *privacyTableView;

@end

@implementation PrivacySettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem newItemWithTarget:self action:@selector(backAction) normalImg:@"back" higLightImg:@"back"];
    
    [self.view addSubview:self.privacyTableView];
    
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
    
}


#pragma mark --  tableView
- (UITableView *)privacyTableView {
    if (!_privacyTableView) {
        _privacyTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NavStatusBarHeight, ScreenWidth, ScreenHeight-NavStatusBarHeight) style:UITableViewStyleGrouped];
        _privacyTableView.dataSource = self;
        _privacyTableView.delegate = self;
        
    }
    return _privacyTableView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

    if (section == 0) {
        return 40;
    }
    return 0.000001;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    if (section == 0) {
        HeadView *headView = [[HeadView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 40)];
        return headView;

    }
    return [UIView new];
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {

    
    return 10;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 150;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 1;
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    WPPrivicyTableViewCell11 *cell = [WPPrivicyTableViewCell11 cellWithTableView:tableView];
    cell.infoDelegate = self;
    return cell;
    
}


#pragma mark -- 切换个人信息中的隐私
- (void)checkPrivicySetting:(NSInteger)index {

    

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
