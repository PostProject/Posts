//
//  LoginViewController.m
//  BigRound
//
//  Created by 王海鹏 on 16/10/9.
//  Copyright © 2016年 王海鹏. All rights reserved.
//
#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "ChangePhoneViewController.h"
#import "ResetPswViewController.h"
@interface LoginViewController ()

@property (nonatomic,strong) UIImageView *ivLogo; // 大圈logo
@property (nonatomic,strong) UIView *inputView; // 输入框view
@property (nonatomic,strong) UITextField *tfAccount; // 账号输入框
@property (nonatomic,strong) UITextField *tfPassword; // 密码输入框
@property (nonatomic,strong) UIButton *btnLogin; // 登录btn
@property (nonatomic,strong) UIButton *btnForgetPsw; // 忘记密码
@property (nonatomic,strong) UIButton *btnChangePhone; // 更换绑定
@property (nonatomic,strong) UIButton *btnRegister; // 注册

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    
    // 设置inputView的centerY 根据inputview 进行布局 因此首先要添加inputView 到self.view上
    [self.view addSubview:self.inputView];
    [self.view addSubview:self.ivLogo];
    [self.view addSubview:self.btnLogin];
    [self.view addSubview:self.btnForgetPsw];
    [self.view addSubview:self.btnChangePhone];
    [self.view addSubview:self.btnRegister];
    // 注册顶部分割线
    
    UILabel *lbLine = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, ScreenWidth-40, SINGLE_LINE)];
    lbLine.bottom = self.btnRegister.top;
    lbLine.backgroundColor = [UIColor colorWithHexString:@"e5e5e5"];
    [self.view addSubview:lbLine];
    
    
}

#pragma mark -- 懒加载logo
- (UIImageView *)ivLogo {
    if (!_ivLogo) {
        _ivLogo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        _ivLogo.centerX = ScreenWidth/2;
        _ivLogo.bottom = self.inputView.top-40;
        _ivLogo.image = [UIImage imageNamed:@"roundLogo"];
    }
    return _ivLogo;
}



#pragma mark -- 懒加载输入框
- (UIView *)inputView {
    if (!_inputView) {
        _inputView = [[UIView alloc] initWithFrame:CGRectMake(20, 0, ScreenWidth-40, 100)];
        _inputView.centerY = ScreenHeight/2-50;
        
        // 账号
        UIImageView *ivAccount = [[UIImageView alloc] initWithFrame:CGRectMake(15, 0, 21, 22)];
        ivAccount.centerY = 25;
        ivAccount.image = [UIImage imageNamed:@"login_account"];
        [_inputView addSubview:ivAccount];
        // 账号输入框
        _tfAccount = [[UITextField alloc] initWithFrame:CGRectMake(ivAccount.right+10, 0, _inputView.width-ivAccount.right-20, 50)];
        // 设置placeholder的颜色
        NSString *strAccount = @"请输入手机号码";
        NSMutableAttributedString *placeholder11 = [[NSMutableAttributedString alloc]initWithString:strAccount];
        [placeholder11 addAttribute:NSForegroundColorAttributeName
                           value:[UIColor whiteColor]
                           range:NSMakeRange(0, strAccount.length)];
        _tfAccount.attributedPlaceholder = placeholder11;
        _tfAccount.clearButtonMode = UITextFieldViewModeWhileEditing;
        _tfAccount.font = FontSize(15);
        _tfAccount.textColor = [UIColor whiteColor];
        _tfAccount.keyboardType = UIKeyboardTypeNumberPad;
        [_inputView addSubview:_tfAccount];
        
        
        // 中间分割线
        UILabel *lbLine11 = [[UILabel alloc] initWithFrame:CGRectMake(10, 49.5, _inputView.width-20, SINGLE_LINE)];
        lbLine11.backgroundColor = [UIColor colorWithHexString:@"e5e5e5"];
        [_inputView addSubview:lbLine11];
        
    
        //密码
        UIImageView *ivPsw = [[UIImageView alloc] initWithFrame:CGRectMake(15, 0, 19, 23)];
        ivPsw.centerY = 75;
        ivPsw.image = [UIImage imageNamed:@"login_psw"];
        [_inputView addSubview:ivPsw];
        // 密码输入框
        _tfPassword = [[UITextField alloc] initWithFrame:CGRectMake(ivAccount.right+10, 50, _inputView.width-ivAccount.right-20, 50)];
        NSString *strPsw = @"请输入密码";
        NSMutableAttributedString *placeholder22 = [[NSMutableAttributedString alloc]initWithString:strPsw];
        [placeholder22 addAttribute:NSForegroundColorAttributeName
                            value:[UIColor whiteColor]
                            range:NSMakeRange(0, strPsw.length)];
        _tfPassword.attributedPlaceholder = placeholder22;
        
        _tfPassword.clearButtonMode = UITextFieldViewModeWhileEditing;
        _tfPassword.font = FontSize(15);
        _tfPassword.textColor = [UIColor whiteColor];
        _tfPassword.autocorrectionType = UITextAutocorrectionTypeNo;
        [_inputView addSubview:_tfPassword];
        
        
        // 中间分割线
        UILabel *lbLine22 = [[UILabel alloc] initWithFrame:CGRectMake(10, 99.5, _inputView.width-20, SINGLE_LINE)];
        lbLine22.backgroundColor = [UIColor colorWithHexString:@"e5e5e5"];
        [_inputView addSubview:lbLine22];
        
    }
    return _inputView;
}

#pragma Mark -- 登录btn
- (UIButton *)btnLogin {
    if (!_btnLogin) {
        _btnLogin = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnLogin.frame = CGRectMake(20, _inputView.bottom+50, ScreenWidth-40, 44);
        [_btnLogin setImage:[UIImage imageNamed:@"login"] forState:UIControlStateNormal];
        [_btnLogin addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnLogin;
}

#pragma mark -- 忘记密码
- (UIButton *)btnForgetPsw {
    if (!_btnForgetPsw) {
        NSString *string = @"忘记密码？";
        CGSize size = [string sizeWithFont:FontSize(15) maxSize:CGSizeMake(ScreenWidth , 40)];
        _btnForgetPsw = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnForgetPsw.frame = CGRectMake(20, _btnLogin.bottom, size.width, 40);
        [_btnForgetPsw setTitle:string forState:UIControlStateNormal];
        _btnForgetPsw.titleLabel.font = FontSize(15);
        [_btnForgetPsw addTarget:self action:@selector(forgetPswAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnForgetPsw;
}

#pragma mark -- 绑定
- (UIButton *)btnChangePhone {
    if (!_btnChangePhone) {
        NSString *string = @"更换绑定";
        CGSize size = [string sizeWithFont:FontSize(15) maxSize:CGSizeMake(ScreenWidth , 40)];
        _btnChangePhone = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnChangePhone.frame = CGRectMake(0, _btnLogin.bottom, size.width, 40);
        _btnChangePhone.right = ScreenWidth-20;
        [_btnChangePhone setTitle:string forState:UIControlStateNormal];
        _btnChangePhone.titleLabel.font = FontSize(15);
        [_btnChangePhone addTarget:self action:@selector(changePhoneAction) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _btnChangePhone;
}

#pragma mark -- 注册

- (UIButton *)btnRegister {

    if (!_btnRegister) {
        _btnRegister = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnRegister.frame = CGRectMake(20, ScreenHeight-50, ScreenWidth-40, 50);
        [_btnRegister setTitle:@"还没有账户？注册" forState:UIControlStateNormal];
        _btnRegister.titleLabel.font = FontSize(15);
        [_btnRegister addTarget:self action:@selector(registerAction) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _btnRegister;
}

/**********************************************************************************/

#pragma mark -- 登录事件
- (void)loginAction {
//    BaseTabBarViewController *tabbarVC = [[BaseTabBarViewController alloc] init];
//    [[UIApplication sharedApplication].delegate window].rootViewController = tabbarVC;
    
    /*测试数据*/
    [self dismissViewControllerAnimated:YES completion:nil];

}

#pragma mark -- 忘记密码
- (void)forgetPswAction {
    ResetPswViewController *resetPswVC = [[ResetPswViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:resetPswVC];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark -- 更换绑定事件
- (void)changePhoneAction {
    ChangePhoneViewController *changePhoneVC = [[ChangePhoneViewController alloc] init];
    UINavigationController *nav= [[UINavigationController alloc] initWithRootViewController:changePhoneVC];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark -- 注册事件
- (void)registerAction {
    RegisterViewController *registerVC = [[RegisterViewController alloc] init];
    [self presentViewController:registerVC animated:YES completion:nil];
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
