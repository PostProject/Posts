//
//  RegisterViewController.m
//  BigRound
//
//  Created by 王海鹏 on 16/10/9.
//  Copyright © 2016年 王海鹏. All rights reserved.
//

#import "RegisterViewController.h"


@interface RegisterViewController ()

@property (nonatomic,strong) UIView *phoneView; // 手机号view
@property (nonatomic,strong) UITextField *tfPhone; // 手机号
@property (nonatomic,strong) UIView *verifiCodeView; // 验证码
@property (nonatomic,strong) UITextField *tfVerifiCode; // 验证码
@property (nonatomic,strong) UIView *pswView; //  密码view
@property (nonatomic,strong) UITextField *tfPsw; // 密码
@property (nonatomic,strong) UIButton *btnRegister; // 注册按钮

@property (nonatomic,strong) UIView *loginView; // 底部登录view


@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithHexString:@"ebebeb"];
    [self.view addSubview:self.phoneView];
    [self.view addSubview:self.verifiCodeView];
    [self.view addSubview:self.pswView];
    [self.view addSubview:self.btnRegister];
    [self.view addSubview:self.loginView];
}

//  手机号View
- (UIView *)phoneView {
    if (!_phoneView) {
        _phoneView = [[UIView alloc] initWithFrame:CGRectMake(15, 130, ScreenWidth-30, 44)];
        _phoneView.backgroundColor = [UIColor whiteColor];
        // 切圆角
        _phoneView.layer.cornerRadius = 5;
        _phoneView.layer.masksToBounds = YES;
        _phoneView.layer.shouldRasterize = YES;
        _phoneView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        // 头像
        UIImageView *ivHead = [[UIImageView alloc] initWithFrame:CGRectMake(15, 0, 21, 22)];
        ivHead.centerY = 22;
        ivHead.image = [UIImage imageNamed:@"register_account"];
        [_phoneView addSubview:ivHead];
        //  输入框
        _tfPhone = [[UITextField alloc] initWithFrame:CGRectMake(ivHead.right+10, 0, _phoneView.width-ivHead.right-20, 44)];
        _tfPhone.font = FontSize(17);
        _tfPhone.placeholder = @"请输入手机号码";
        _tfPhone.clearButtonMode = UITextFieldViewModeWhileEditing;
        _tfPhone.keyboardType = UIKeyboardTypeNumberPad;
        [_phoneView addSubview:_tfPhone];
        
    }
    return _phoneView;
}

// 验证码view
- (UIView *)verifiCodeView {
    if (!_verifiCodeView) {
        
        _verifiCodeView = [[UIView alloc] initWithFrame:CGRectMake(15, self.phoneView.bottom+15, ScreenWidth-30, 44)];
        _verifiCodeView.backgroundColor = [UIColor whiteColor];
        // 切圆角
        _verifiCodeView.layer.cornerRadius = 5;
        _verifiCodeView.layer.masksToBounds = YES;
        _verifiCodeView.layer.shouldRasterize = YES;
        _verifiCodeView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        // 输入框
        _tfVerifiCode = [[UITextField alloc] initWithFrame:CGRectMake(15, 0, _verifiCodeView.width-120 , 44)];
        _tfVerifiCode.font = FontSize(17);
        _tfVerifiCode.placeholder = @"验证码";
        _tfVerifiCode.clearButtonMode = UITextFieldViewModeWhileEditing;
        _tfVerifiCode.keyboardType = UIKeyboardTypeNumberPad;
        [_verifiCodeView addSubview:_tfVerifiCode];
     
        // 验证码btn
        UIButton *btnVerifi = [UIButton buttonWithType:UIButtonTypeCustom];
        btnVerifi.frame = CGRectMake(_verifiCodeView.width-100, 2, 95, 40);
        [btnVerifi setTitle:@"获取验证码" forState:UIControlStateNormal];
        btnVerifi.titleLabel.font = FontSize(14);
        btnVerifi.layer.backgroundColor = [UIColor colorWithR:69.0 G:140.0 B:105.0 A:1.0].CGColor;
        btnVerifi.layer.cornerRadius = 5;
        btnVerifi.layer.shouldRasterize = YES;
        btnVerifi.layer.masksToBounds = YES;
        btnVerifi.layer.rasterizationScale = [UIScreen mainScreen].scale;
        [btnVerifi addTarget:self action:@selector(getVerifiCodeAction) forControlEvents:UIControlEventTouchUpInside];
        [_verifiCodeView addSubview:btnVerifi];
        
    }
    return _verifiCodeView;
}


// 密码view
- (UIView *)pswView {
    if (!_pswView) {
        _pswView = [[UIView alloc] initWithFrame:CGRectMake(15, self.verifiCodeView.bottom+15, ScreenWidth-30, 44)];
        
        _pswView.backgroundColor = [UIColor whiteColor];
        // 切圆角
        _pswView.layer.cornerRadius = 5;
        _pswView.layer.masksToBounds = YES;
        _pswView.layer.shouldRasterize = YES;
        _pswView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        // 密码图片
        UIImageView *ivPsw = [[UIImageView alloc] initWithFrame:CGRectMake(15, 0, 21, 22)];
        ivPsw.centerY = 22;
        ivPsw.image = [UIImage imageNamed:@"register_psw"];
        [_pswView addSubview:ivPsw];
        //  输入框
        _tfPsw = [[UITextField alloc] initWithFrame:CGRectMake(ivPsw.right+10, 0, _phoneView.width-ivPsw.right-50, 44)];
        _tfPsw.font = FontSize(17);
        _tfPsw.secureTextEntry = NO;
        _tfPsw.placeholder = @"请输入密码";
        _tfPsw.clearButtonMode = UITextFieldViewModeWhileEditing;
        _tfPsw.keyboardType = UIKeyboardTypeNumberPad;
        [_pswView addSubview:_tfPsw];
        
        // 小眼睛
        UIButton *btnEye = [UIButton buttonWithType:UIButtonTypeCustom];
        btnEye.frame = CGRectMake(_pswView.width-40, 0, 22, 18);
        btnEye.centerY = 22;
        [btnEye setImage:[UIImage imageNamed:@"psw_show"] forState:UIControlStateNormal];
        [btnEye setImage:[UIImage imageNamed:@"psw_hide"] forState:UIControlStateSelected];
        [btnEye addTarget:self action:@selector(pswIsShowAction:) forControlEvents:UIControlEventTouchUpInside];
        [_pswView addSubview:btnEye];
        
        
    }
    return _pswView;
}

// 注册btn
- (UIButton *)btnRegister {
    if (!_btnRegister) {
        _btnRegister = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnRegister.frame = CGRectMake(15, self.pswView.bottom+60, ScreenWidth-30, 44);
        [_btnRegister setImage:[UIImage imageNamed:@"register"] forState:UIControlStateNormal];
        [_btnRegister addTarget:self action:@selector(registerAction) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _btnRegister;
}

// 登录view
- (UIView *)loginView {
    if (!_loginView) {
        
        _loginView = [[UIView alloc] initWithFrame: CGRectMake(0, ScreenHeight-44, ScreenWidth, 44)];
        
        UIButton *btnLogin = [UIButton buttonWithType:UIButtonTypeCustom];
        btnLogin.frame = CGRectMake(0, 0, _loginView.width, _loginView.height);
        [btnLogin setTitle:@"已有账户？登录" forState:UIControlStateNormal];
        [btnLogin setTitleColor:[UIColor colorWithHexString:@"333333"] forState:UIControlStateNormal];
        [btnLogin addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
        [_loginView addSubview:btnLogin];
        
        // 线
        UILabel *lbLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, SINGLE_LINE)];
        lbLine.backgroundColor = [UIColor colorWithHexString:@"d6d3d3"];
        [_loginView addSubview:lbLine];
        
    }
    return _loginView;
}


#pragma mark --  获取验证码
- (void)getVerifiCodeAction {

    
}

#pragma mark --  密码是否可见
- (void)pswIsShowAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    _tfPsw.secureTextEntry = sender.selected;
}

#pragma mark --  注册
- (void)registerAction {

    
    
    
}

#pragma mark -- 返回登录
- (void)loginAction {
    [self dismissViewControllerAnimated:YES completion:nil];
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
