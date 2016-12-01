//
//  MyViewController.m
//  Post
//
//  Created by admin on 2016/11/3.
//  Copyright © 2016年 Post. All rights reserved.
//

#import "MyViewController.h"
#import "MineTableViewCell.h"
#import "MyPostViewController.h"
#import "MyCircleViewController.h"
#import "MyFriendViewController.h"
#import "PrivacySettingViewController.h"
#import "AccountSafeViewController.h"
#import "LoginViewController.h"
#import "PersonCenterViewController.h"


@interface MyViewController () <UITableViewDataSource,UITableViewDelegate>


@property (nonatomic,strong) UITableView *myTableView;
@property (nonatomic,strong) NSMutableArray *myCellInfo; // cell的每一行icon和名字
@property (nonatomic,strong) UIView *headerView;
@property (nonatomic,strong) UIView *footerView;



@end

@implementation MyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *lbTitleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 200, 44)];
    lbTitleView.text = @"小明";
    lbTitleView.textAlignment = NSTextAlignmentCenter;
    lbTitleView.centerX = ScreenWidth/2;
    self.navigationItem.titleView = lbTitleView;
    [self.view addSubview:self.myTableView];
    // Do any additional setup after loading the view.
}


- (NSMutableArray *)myCellInfo {
    if (!_myCellInfo) {
        
        _myCellInfo = [NSMutableArray array];
        
        MyPostViewController *postVC = [[MyPostViewController alloc] init];
        MyCircleViewController *circleVC = [[MyCircleViewController alloc] init];
        MyFriendViewController *myFriendVC = [[MyFriendViewController alloc] init];
        PrivacySettingViewController *privacyVC = [[PrivacySettingViewController alloc] init];
        AccountSafeViewController *accountVC = [[AccountSafeViewController alloc] init];
        
        MyCellInfoModel *model11 = [MyCellInfoModel new];
        model11.cellIcon = @"myPost";
        model11.cellName = @"我的帖子";
        model11.cellClass = postVC;
        [_myCellInfo addObject:model11];
        
        MyCellInfoModel *model22 = [MyCellInfoModel new];
        model22.cellIcon = @"myCircle";
        model22.cellName = @"我的圈层";
        model22.cellClass = circleVC;
        [_myCellInfo addObject:model22];
        
        MyCellInfoModel *model33 = [MyCellInfoModel new];
        model33.cellIcon = @"myFriend";
        model33.cellName = @"我的好友";
        model33.cellClass = myFriendVC;
        [_myCellInfo addObject:model33];
        
        MyCellInfoModel *model44 = [MyCellInfoModel new];
        model44.cellIcon = @"privacySetting";
        model44.cellName = @"隐私设置";
        model44.cellClass = privacyVC;
        [_myCellInfo addObject:model44];
        
        MyCellInfoModel *model55 = [MyCellInfoModel new];
        model55.cellIcon = @"accountSecurity";
        model55.cellName = @"账号安全";
        model55.cellClass = accountVC;
        [_myCellInfo addObject:model55];
        
    }
    return _myCellInfo;
    
}


- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 120)];
        _headerView.backgroundColor = [UIColor colorWithR:200 G:200 B:200 A:1];
        
        UIButton *btnHead = [UIButton buttonWithType:UIButtonTypeCustom];
        btnHead.size = CGSizeMake(80, 80);
        btnHead.center = CGPointMake(_headerView.width/2, _headerView.height/2);
        [btnHead setImage:[UIImage imageNamed:@"111.jpg"] forState:UIControlStateNormal];
        btnHead.layer.cornerRadius = btnHead.width/2;
        btnHead.layer.masksToBounds = YES;
        btnHead.layer.shouldRasterize = YES;
        btnHead.layer.rasterizationScale = [UIScreen mainScreen].scale;
        btnHead.layer.borderColor = [UIColor whiteColor].CGColor;
        btnHead.layer.borderWidth = 2;
        [_headerView addSubview:btnHead];
        [btnHead addTarget:self action:@selector(personCenterAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _headerView;
}

-  (UIView *)footerView {
    if (!_footerView) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 100)];
        UIButton *btnLeave = [UIButton buttonWithType:UIButtonTypeCustom];
        btnLeave.frame = CGRectMake(20, 0, ScreenWidth-40, 45);
        btnLeave.centerY = _footerView.height/2;
        [btnLeave setImage:[UIImage imageNamed:@"leaveLogin"] forState:UIControlStateNormal];
        [btnLeave addTarget:self action:@selector(logoutAction) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:btnLeave];
    }
    return _footerView;
}


- (UITableView *)myTableView {
    
    if (!_myTableView) {
        
        _myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0, ScreenWidth, ScreenHeight-TabBarHeight) style:UITableViewStyleGrouped];
        _myTableView.dataSource = self;
        _myTableView.delegate = self;
        _myTableView.rowHeight = 50;
        _myTableView.tableHeaderView = self.headerView;
        _myTableView.tableFooterView = self.footerView;
    }
    return _myTableView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 10;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0.0001;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    }
    return 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MineTableViewCell *cell = [MineTableViewCell cellWithTableView:tableView];
    if (indexPath.section == 0) {
        cell.cellModel = self.myCellInfo[indexPath.row];
        
    }
    if (indexPath.section == 1) {
        cell.cellModel = self.myCellInfo[indexPath.row+3];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MyCellInfoModel *model = nil;
    if (indexPath.section == 0) {
        model = self.myCellInfo[indexPath.row];
    }
    else if (indexPath.section == 1) {
        model = self.myCellInfo[indexPath.row+3];
    }
    UIViewController *controller = model.cellClass;
    controller.title = model.cellName;
    [self.navigationController pushViewController:model.cellClass animated:YES];
    
}

#pragma mark -- 个人中心
- (void)personCenterAction {
    PersonCenterViewController *personCenterVC = [[PersonCenterViewController alloc] init];
    personCenterVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:personCenterVC animated:YES];
}



#pragma mark -- 退出登录
- (void)logoutAction {
    
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    loginVC.title = @"登录";
    
//    [[UIApplication sharedApplication].delegate window].rootViewController = loginVC;
    [self presentViewController:loginVC animated:YES completion:nil];
    
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
