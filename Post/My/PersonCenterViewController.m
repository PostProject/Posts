//
//  PersonCenterViewController.m
//  Post
//
//  Created by 王鹏 on 16/11/27.
//  Copyright © 2016年 Post. All rights reserved.
//

#import "PersonCenterViewController.h"
#import "UIBarButtonItem+WP.h"

@interface PersonCenterViewController ()

@property (nonatomic,strong) UIScrollView *bgScrollerView;
@property (nonatomic,strong) UIView *headerView;
@property (nonatomic,strong) UIView *personInfoView;
@property (nonatomic,strong) UIView *finishView;

@property (nonatomic,strong) UITextField *tfUserName; // 用户名
@property (nonatomic,strong) UITextField *tfNickname; // 昵称
@property (nonatomic,strong) UILabel *lbSex; // 性别
@property (nonatomic,strong) UILabel *lbAddress; // 所在地
@property (nonatomic,strong) UITextField *tfPhoneNum; // 手机号
@property (nonatomic,strong) UITextField *tfEmail; //邮箱
@property (nonatomic,strong) UITextField *tfOther; // 其他联系方式
@property (nonatomic,strong) UITextField *tfDesc; // 个人描述


@end

@implementation PersonCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem newItemWithTarget:self action:@selector(cancleInvite) normalImg:@"back" higLightImg:@"back"];
    
    
    _bgScrollerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NavStatusBarHeight, ScreenWidth, ScreenHeight-NavStatusBarHeight)];
    [self.view addSubview:_bgScrollerView];
    _bgScrollerView.contentSize = CGSizeMake(0, 570);
    
    [_bgScrollerView addSubview:self.headerView];
    [_bgScrollerView addSubview:self.personInfoView];
    [_bgScrollerView addSubview:self.finishView];
}

- (void)cancleInvite {
    [self.navigationController popViewControllerAnimated:YES];
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
        [btnHead addTarget:self action:@selector(changeHeadImg) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _headerView;
}

- (UIView *)personInfoView {

    if (!_personInfoView) {
        _personInfoView = [[UIView alloc] initWithFrame:CGRectMake(0, 130, ScreenHeight, 320)];
        _personInfoView.backgroundColor = [UIColor whiteColor];
        // 用户名
        UILabel *lbYHM = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 40)];
        lbYHM.text = @"用户名";
        lbYHM.font = FontSize(14);
        lbYHM.textColor = [UIColor colorWithHexString:@"888888"];
        [_personInfoView addSubview:lbYHM];
        
        CGFloat infoX = 110;
        CGFloat infoW = ScreenWidth-120;
        
        _tfUserName = [[UITextField alloc] initWithFrame:CGRectMake(infoX, 0, infoW, 40)];
        _tfUserName.textAlignment = NSTextAlignmentRight;
        _tfUserName.text = @"123445556";
        _tfUserName.font = FontSize(14);
        _tfUserName.textColor = [UIColor colorWithHexString:@"333333"];
        [_personInfoView addSubview:_tfUserName];
        
        // 昵称
        UILabel *lbNC = [[UILabel alloc] initWithFrame:CGRectMake(10, lbYHM.bottom, 100, 40)];
        lbNC.text = @"昵称";
        lbNC.font = FontSize(14);
        lbNC.textColor = [UIColor colorWithHexString:@"888888"];
        [_personInfoView addSubview:lbNC];
        
        _tfNickname = [[UITextField alloc] initWithFrame:CGRectMake(infoX, _tfUserName.bottom, infoW, 40)];
        _tfNickname.textAlignment = NSTextAlignmentRight;
        _tfNickname.text = @"小明";
        _tfNickname.font = FontSize(14);
        _tfNickname.textColor = [UIColor colorWithHexString:@"333333"];
        [_personInfoView addSubview:_tfNickname];
        
        // 性别
        UILabel *lbXB = [[UILabel alloc] initWithFrame:CGRectMake(10, lbNC.bottom, 100, 40)];
        lbXB.text = @"昵称";
        lbXB.font = FontSize(14);
        lbXB.textColor = [UIColor colorWithHexString:@"888888"];
        [_personInfoView addSubview:lbXB];
        
        _lbSex = [[UILabel alloc] initWithFrame:CGRectMake(infoX, _tfNickname.bottom, infoW, 40)];
        _lbSex.text = @"男";
        _lbSex.font = FontSize(14);
        _lbSex.textAlignment = NSTextAlignmentRight;
        _lbSex.textColor = [UIColor colorWithHexString:@"333333"];
        [_personInfoView addSubview:_lbSex];
        
        // 所在地
        UILabel *lbSZD = [[UILabel alloc] initWithFrame:CGRectMake(10, lbXB.bottom, 100, 40)];
        lbSZD.text = @"所在地";
        lbSZD.font = FontSize(14);
        lbSZD.textColor = [UIColor colorWithHexString:@"888888"];
        [_personInfoView addSubview:lbSZD];
        
        _lbAddress = [[UILabel alloc] initWithFrame:CGRectMake(infoX, _lbSex.bottom, infoW, 40)];
        _lbAddress.text = @"江苏南京";
        _lbAddress.font = FontSize(14);
        _lbAddress.textAlignment = NSTextAlignmentRight;
        _lbAddress.textColor = [UIColor colorWithHexString:@"333333"];
        [_personInfoView addSubview:_lbAddress];
        
        // 手机号
        UILabel *lbSJH = [[UILabel alloc] initWithFrame:CGRectMake(10, lbSZD.bottom, 100, 40)];
        lbSJH.text = @"手机号";
        lbSJH.font = FontSize(14);
        lbSJH.textColor = [UIColor colorWithHexString:@"888888"];
        [_personInfoView addSubview:lbSJH];
        
        _tfPhoneNum = [[UITextField alloc] initWithFrame:CGRectMake(infoX, _lbAddress.bottom, infoW, 40)];
        _tfPhoneNum.text = @"13888888888";
        _tfPhoneNum.font = FontSize(14);
        _tfPhoneNum.textAlignment = NSTextAlignmentRight;
        _tfPhoneNum.textColor = [UIColor colorWithHexString:@"333333"];
        [_personInfoView addSubview:_tfPhoneNum];
        
        // 邮箱
        UILabel *lbYX = [[UILabel alloc] initWithFrame:CGRectMake(10, lbSJH.bottom, 100, 40)];
        lbYX.text = @"邮箱";
        lbYX.font = FontSize(14);
        lbYX.textColor = [UIColor colorWithHexString:@"888888"];
        [_personInfoView addSubview:lbYX];
        
        _tfEmail = [[UITextField alloc] initWithFrame:CGRectMake(infoX, _tfPhoneNum.bottom, infoW, 40)];
        _tfEmail.text = @"1111111111@163.com";
        _tfEmail.font = FontSize(14);
        _tfEmail.textAlignment = NSTextAlignmentRight;
        _tfEmail.textColor = [UIColor colorWithHexString:@"333333"];
        [_personInfoView addSubview:_tfEmail];
        
        // 其他联系方式
        UILabel *lbQT = [[UILabel alloc] initWithFrame:CGRectMake(10, lbYX.bottom, 100, 40)];
        lbQT.text = @"其他联系方式";
        lbQT.font = FontSize(14);
        lbQT.textColor = [UIColor colorWithHexString:@"888888"];
        [_personInfoView addSubview:lbQT];
        
        _tfOther = [[UITextField alloc] initWithFrame:CGRectMake(infoX, _tfEmail.bottom, infoW, 40)];
        _tfOther.text = @"1111111111@163.com";
        _tfOther.font = FontSize(14);
        _tfOther.textAlignment = NSTextAlignmentRight;
        _tfOther.textColor = [UIColor colorWithHexString:@"333333"];
        [_personInfoView addSubview:_tfOther];
        
        
        
        // 个人描述
        UILabel *lbMS = [[UILabel alloc] initWithFrame:CGRectMake(10, lbQT.bottom, 100, 40)];
        lbMS.text = @"个人描述";
        lbMS.font = FontSize(14);
        lbMS.textColor = [UIColor colorWithHexString:@"888888"];
        [_personInfoView addSubview:lbMS];
        
        _tfDesc = [[UITextField alloc] initWithFrame:CGRectMake(infoX, _tfOther.bottom, infoW, 40)];
        _tfDesc.text = @"人见人爱，花见花开";
        _tfDesc.font = FontSize(14);
        _tfDesc.textAlignment = NSTextAlignmentRight;
        _tfDesc.textColor = [UIColor colorWithHexString:@"333333"];
        [_personInfoView addSubview:_tfDesc];
        
        
    }
    return _personInfoView;
}


- (UIView *)finishView {
    if (!_finishView) {
        
        _finishView = [[UIView alloc] initWithFrame:CGRectMake(0, self.personInfoView.bottom, ScreenWidth, 120)];
        UIButton *btnLeave = [UIButton buttonWithType:UIButtonTypeCustom];
        btnLeave.frame = CGRectMake(20, 0, ScreenWidth-40, 45);
        btnLeave.centerY = _finishView.height/2;
        [btnLeave setImage:[UIImage imageNamed:@"finish"] forState:UIControlStateNormal];
        [btnLeave addTarget:self action:@selector(finishAction) forControlEvents:UIControlEventTouchUpInside];
        [_finishView addSubview:btnLeave];
        
    }
    return _finishView;
}

#pragma mark -- 完成修改
- (void)finishAction {

    
}



#pragma mark -- 更改头像
- (void)changeHeadImg {
    

    
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
