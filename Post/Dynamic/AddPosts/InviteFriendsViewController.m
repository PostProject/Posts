//
//  InviteFriendsViewController.m
//  Post
//
//  Created by 王海鹏 on 16/11/15.
//  Copyright © 2016年 Post. All rights reserved.
//

#import "InviteFriendsViewController.h"
#import "InviteFriendsTableViewCell.h"
#import "GoodsFriendTableViewCell.h"
#import "UIBarButtonItem+WP.h"


@interface InviteFriendsViewController () <UITableViewDataSource,UITableViewDelegate,InviteDelegate>

@property (nonatomic,strong) UITableView *inviteTableView; // 好友tableview
@property (nonatomic,strong) NSMutableArray *friendArray; // 存放好友信息的数组
@property (nonatomic,strong) NSMutableArray *titleArray; // 页眉数组
@property (nonatomic,strong) NSMutableArray *indexsArray; //索引数组


@end

@implementation InviteFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem newItemWithTarget:self action:@selector(cancleInvite) normalImg:@"back" higLightImg:@"back"];
    
    [self.view addSubview:self.inviteTableView];
}

- (void)cancleInvite {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSMutableArray *)indexsArray {
    if (!_indexsArray) {
        
        _indexsArray = [NSMutableArray array];
        _titleArray = [NSMutableArray array];
        
        for(char c = 'A'; c <= 'Z'; c++ )
        {
            [_indexsArray addObject:[NSString stringWithFormat:@"%c",c]];
            [_titleArray addObject:[NSString stringWithFormat:@"%c",c]];
        }
    }
    return _indexsArray;
}



- (UITableView *)inviteTableView {
    
    if (!_inviteTableView) {
        
        _inviteTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NavStatusBarHeight, ScreenWidth, ScreenHeight-NavStatusBarHeight) style:UITableViewStylePlain];
        _inviteTableView.dataSource = self;
        _inviteTableView.delegate = self;
        _inviteTableView.rowHeight = 60;
        _inviteTableView.backgroundColor = self.view.backgroundColor;
        // 设置索引值颜色
        _inviteTableView.sectionIndexColor = [UIColor lightGrayColor];
        // 设置选中时，索引背景颜色
        _inviteTableView.sectionIndexTrackingBackgroundColor = self.view.backgroundColor;
        // 设置默认时，索引的背景颜色
        _inviteTableView.sectionIndexBackgroundColor = [UIColor clearColor];
        
    }
    return _inviteTableView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 30;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0.000001;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    FriendHeadView *headView = [[FriendHeadView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 30)];
    headView.lbTxt.text = self.titleArray[section];
    return headView;
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.indexsArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    InviteFriendsTableViewCell *cell = [InviteFriendsTableViewCell cellWithTableView:tableView];
    cell.inviteDelegate = self;
    cell.row = indexPath.row;
    return cell;
    
}

//返回索引数组
-(NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    
    return self.indexsArray;
}

//响应点击索引时的委托方法
-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    
    NSInteger count = 0;
    
    for (NSString *character in self.indexsArray) {
        
        if ([[character uppercaseString] hasPrefix:title]) {
            return count;
        }
        
        count++;
    }
    
    return  0;
}

#pragma mark -- 选择好友
- (void)checkFriendsAction:(NSInteger)index {

    
    
    
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
