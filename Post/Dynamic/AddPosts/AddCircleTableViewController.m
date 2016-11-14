//
//  AddCircleTableViewController.m
//  Post
//
//  Created by 陈世文 on 2016/11/13.
//  Copyright © 2016年 Post. All rights reserved.
//

#import "AddCircleTableViewController.h"
#import "User.h"

#define InviteFriendsHeight UISCREW/5

@interface AddCircleTableViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    ///邀请成员View的高度
    NSInteger _inviteHeight;
}

@property (weak, nonatomic) IBOutlet UISwitch *switchAction;

/**
 邀请View
 */
@property (weak, nonatomic) IBOutlet UIView *inviteView;

@end

@implementation AddCircleTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}
- (IBAction)addCircleCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)inviteFriendsAction{
    MyLog(@"邀请好友");
    for (UIView *view in self.inviteView.subviews) {
        [view removeFromSuperview];
    }
    ///测试数据
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i<21; i++) {
        [array addObject:@"asldkj"];
    }
    [self creatInviteFriendsFromUserArray:array];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)creatInviteFriendsFromUserArray:(NSArray *)array{
    if (array) {
        NSUInteger arrayCount = array.count;
        NSUInteger btnI = 0;
        ///行
        for (NSUInteger i = 0; i<arrayCount/5.0; i++) {
            ///列
            for (NSUInteger j = 0; j <=5; j ++) {
                ///当前遍历个数
                NSUInteger count = 5 * i + j+1;
                if (count <= arrayCount) {
                    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(j * InviteFriendsHeight, i* InviteFriendsHeight, InviteFriendsHeight, InviteFriendsHeight)];
                    bgView.backgroundColor = [UIColor blueColor];
                    UILabel *lbName = [[UILabel alloc] initWithFrame:CGRectMake(0, 45, InviteFriendsHeight, 30)];
                    lbName.text = @"asldfkjasldfaksdfasldfasdfjas;dfads;flkasd";
                    [bgView addSubview:lbName];
                    [self.inviteView addSubview:bgView];
                    
                    if (count == arrayCount) {
                        NSLog(@"最后一个用户");
                        btnI = i + 1;
                        
                    }
                }else{
                    MyLog(@"最后一个加号按钮");
                    UIButton *btnAddUser = [UIButton buttonWithType:UIButtonTypeCustom];
                    btnAddUser.frame = CGRectMake(j * InviteFriendsHeight, i* InviteFriendsHeight, InviteFriendsHeight, InviteFriendsHeight);
                    [btnAddUser addTarget:self action:@selector(inviteFriendsAction) forControlEvents:UIControlEventTouchUpInside];
                    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"circleAddUser.png"]];
                    imageView.frame = CGRectMake(0, 0, 30, 30);
                    imageView.center = btnAddUser.center;
                    imageView.userInteractionEnabled = NO;
                    [self.inviteView addSubview:imageView];
                    float countHeight = count/5;
                    _inviteHeight = countHeight == 0 ? countHeight : countHeight +1;
                    _inviteHeight = _inviteHeight * InviteFriendsHeight;
                    self.inviteView.frame = CGRectMake(0, 0, UISCREW, _inviteHeight);
                    [self.inviteView addSubview:btnAddUser];
                    break;
                }
            }
            
        }
        if (arrayCount % 5 == 0) {
            MyLog(@"最后一个加号按钮");
            UIButton *btnAddUser = [UIButton buttonWithType:UIButtonTypeCustom];
            btnAddUser.frame = CGRectMake(0, btnI * InviteFriendsHeight, InviteFriendsHeight, InviteFriendsHeight);
            [btnAddUser addTarget:self action:@selector(inviteFriendsAction) forControlEvents:UIControlEventTouchUpInside];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"circleAddUser.png"]];
            imageView.frame = CGRectMake(0, 0, 40, 40);
            imageView.center = btnAddUser.center;
            _inviteHeight = (btnI+1) * InviteFriendsHeight;
            self.inviteView.frame = CGRectMake(0, 0, UISCREW, _inviteHeight);
            [self.inviteView addSubview:imageView];
            [self.inviteView addSubview:btnAddUser];
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 1) {
        if (_inviteHeight == 0) {
            return 55;
        }
        return _inviteHeight;
    }
    return 55;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
