//
//  CircleView.m
//  Post
//
//  Created by admin on 2016/11/9.
//  Copyright © 2016年 Post. All rights reserved.
//

#import "CircleView.h"
#import "TypeOneTableViewCell.h"
#import "TypeTowTableViewCell.h"
#import "TypeThreeTableViewCell.h"
#import "Cricle.h"
#import "CircleModel.h"
#import "TableViewCell.h"
#import "HeaderView.h"
/**
 出去消息后高度后Cell的高度
 */
#define TyptOneH 185
#define TypeTwoH 276
#define TypeThreeH 514

@interface CircleView()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic , strong) CircleModel *circleModel;
@property (nonatomic , strong) NSMutableArray *hostArray;
@end

@implementation CircleView


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blueColor];
        [self addSubview:self.circleTable];
    }
    return self;
}
-(UITableView *)circleTable{
    if (!_circleTable) {
        _circleTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - 5) style:UITableViewStyleGrouped];
        _circleTable.delegate = self;
        _circleTable.dataSource = self;
        _circleTable.tag = 0;
//        _circleTable.backgroundColor = [UIColor redColor];
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
        [header setTitle:@"下拉刷新" forState:MJRefreshStateIdle];
        [header setTitle:@"松手可刷新" forState:MJRefreshStatePulling];
        [header setTitle:@"加载中..." forState:MJRefreshStateRefreshing];
        _circleTable.mj_header = header;
        
        //        _circleTable.mj_header.
        _circleTable.contentInset = UIEdgeInsetsZero;
        
        _circleTable.scrollIndicatorInsets = UIEdgeInsetsZero;
    }
    return _circleTable;
}
-(CircleModel *)circleModel{
    if (!_circleModel) {
        _circleModel = [[CircleModel alloc] init];
    }
    return _circleModel;
}
-(NSMutableArray *)hostArray{
    if (!_hostArray) {
        _hostArray = [[NSMutableArray alloc] init];
    }
    return _hostArray;
}
-(void)loadData{
    __weak CircleView *weakSelf = self;
    NSString *url = [NSString stringWithFormat:@"%@getPostByUserId?",HostUrl];
    NSDictionary *params = @{@"id":@"1"};
    
    [CSNetWorking GET:url adParams:params adSuccecBlock:^(id responseObject) {
        MyLog(@"FlyElephant: %@", responseObject);
        [weakSelf creatDataArrayFromObj:responseObject];
    } adFaluerBlock:^(NSError *error) {
        MyLog(@"FlyElephant: %@", error);
        [[Toast shareToast] showContent:@"加载失败..." adTime:2];
    }];
    
    
    
}
-(void)creatDataArrayFromObj:(id)obj{
    NSDictionary *dicData = obj;
    MyLog(@"%@",dicData);
    NSArray *contentArray = [dicData objectForKey:@"content"];
    if (contentArray.count == 0 ) {
        [[Toast shareToast] showContent:@"暂无数据" adTime:2];
        return;
    }
    
    [self.circleTable.mj_header endRefreshing];
    [self.circleTable reloadData];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    Cricle *cricle;
    ///我的圈层
//    if (indexPath.section == 1) {
//        cricle = [self.circleModel.myCircleArray objectAtIndex:indexPath.row];
//    }
//    if (indexPath.section == 1) {
//        cricle = [self.circleModel.joinCircleArray objectAtIndex:indexPath.row];
//    }
    
    static NSString *cellID = @"TableViewCell";
    TableViewCell *myCell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!myCell) {
        myCell = [[[NSBundle mainBundle]loadNibNamed:cellID owner:self options:nil] firstObject];
    }
    myCell.lbName.text = [NSString stringWithFormat:@"圈层%li",indexPath.row];
    
    return myCell;
    
    
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView;
    if (section == 0) {
        HeaderView *header = [[[NSBundle mainBundle] loadNibNamed:@"HeaderView" owner:self options:nil] firstObject];
        
        headerView = header;
    }
    if (section == 1) {
        UILabel *lbMyCricle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
        lbMyCricle.text = @"   我的圈层";
        lbMyCricle.font = [UIFont systemFontOfSize:12];
        lbMyCricle.textColor = [UIColor lightGrayColor];
        headerView = lbMyCricle;
    }
    if (section == 2) {
        UILabel *lbMyCricle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
        lbMyCricle.text = @"   我加入的圈层";
        lbMyCricle.font = [UIFont systemFontOfSize:12];
        lbMyCricle.textColor = [UIColor lightGrayColor];
        headerView = lbMyCricle;
    }
    return headerView;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger row = 0;
    if (section == 1) {
        row = self.circleModel.myCircleArray.count;
        ///测试数据
        row = 5;
    }
    if (section == 2) {
        row = self.circleModel.joinCircleArray.count;
        ///测试数据
        row = 5;
    }
    return row;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 113;
    }
    return 30;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
@end
