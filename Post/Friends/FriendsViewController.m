//
//  FriendsViewController.m
//  Post
//
//  Created by admin on 2016/11/3.
//  Copyright © 2016年 Post. All rights reserved.
//

#import "FriendsViewController.h"
#import "GoodsFriendTableViewCell.h"

@interface FriendsViewController () <UITableViewDataSource,UITableViewDelegate>


@property (nonatomic,strong) UITableView *friendTableView; // 好友tableview
@property (nonatomic,strong) NSMutableArray *friendArray; // 存放好友信息的数组
@property (nonatomic,strong) NSMutableArray *titleArray; // 页眉数组
@property (nonatomic,strong) NSMutableArray *indexsArray; //索引数组

@end

@implementation FriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"好友";
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.friendTableView];
}

- (NSMutableArray *)indexsArray {
    if (!_indexsArray) {
        
        _indexsArray = [NSMutableArray array];
        _titleArray = [NSMutableArray array];
        [_titleArray addObject:@"新朋友"];
        
        for(char c = 'A'; c <= 'Z'; c++ )
        {
            [_indexsArray addObject:[NSString stringWithFormat:@"%c",c]];
            [_titleArray addObject:[NSString stringWithFormat:@"%c",c]];
        }
    }
    return _indexsArray;
}



- (UITableView *)friendTableView {
    
    if (!_friendTableView) {
        
        _friendTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-TabBarHeight) style:UITableViewStylePlain];
        _friendTableView.dataSource = self;
        _friendTableView.delegate = self;
        _friendTableView.rowHeight = 60;
        _friendTableView.backgroundColor = self.view.backgroundColor;
        // 设置索引值颜色
        _friendTableView.sectionIndexColor = [UIColor lightGrayColor];
        // 设置选中时，索引背景颜色
        _friendTableView.sectionIndexTrackingBackgroundColor = self.view.backgroundColor;
        // 设置默认时，索引的背景颜色
        _friendTableView.sectionIndexBackgroundColor = [UIColor clearColor];
        
    }
    return _friendTableView;
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
    
    return self.indexsArray.count+1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        GoodsFriendTableViewCell *cell = [GoodsFriendTableViewCell cellWithTableView:tableView];
        return cell;
    }else {
        
        GoodsFriendTableViewCell22 *cell = [GoodsFriendTableViewCell22 cellWithTableView:tableView];
        return cell;
    }
    
    
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

//先要设Cell可编辑

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
    
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return   UITableViewCellEditingStyleDelete;
    
}

// 进入编辑模式

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath

{
    if (editingStyle != UITableViewCellEditingStyleDelete) {
        return;
    }
    
}


- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        
        NSLog(@"点击了删除");
        
        // 1. 更新数据
        // 2. 更新UI
        
        //        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:indexPath.section];
        //        [tableView moveRowAtIndexPath:indexPath toIndexPath:firstIndexPath];
    }];
    
    deleteRowAction.backgroundColor = [UIColor colorWithR:197.0 G:197.0 B:197.0 A:1];
    return @[deleteRowAction];
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
