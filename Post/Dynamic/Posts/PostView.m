//
//  PostView.m
//  Post
//
//  Created by admin on 2016/11/9.
//  Copyright © 2016年 Post. All rights reserved.
//

#import "PostView.h"
#import "TypeOneTableViewCell.h"
#import "PostsModel.h"
#import "TypeTowTableViewCell.h"
#import "TypeThreeTableViewCell.h"
#import "PostImage.h"
/**
 出去消息后高度后Cell的高度
 */
#define TyptOneH 185
#define TypeTwoH 276
#define TypeThreeH 514

@interface PostView()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic , strong) NSMutableArray *dataArray;

@end

@implementation PostView


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blueColor];
        [self addSubview:self.dynamicTable];
    }
    return self;
}
-(UITableView *)dynamicTable{
    if (!_dynamicTable) {
        _dynamicTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - 5) style:UITableViewStyleGrouped];
        _dynamicTable.delegate = self;
        _dynamicTable.dataSource = self;
        _dynamicTable.tag = 0;
        _dynamicTable.backgroundColor = [UIColor redColor];
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
        [header setTitle:@"下拉刷新" forState:MJRefreshStateIdle];
        [header setTitle:@"松手可刷新" forState:MJRefreshStatePulling];
        [header setTitle:@"加载中..." forState:MJRefreshStateRefreshing];
        _dynamicTable.mj_header = header;
        
        //        _dynamicTable.mj_header.
        _dynamicTable.contentInset = UIEdgeInsetsZero;
        
        _dynamicTable.scrollIndicatorInsets = UIEdgeInsetsZero;
    }
    return _dynamicTable;
}
-(NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}
-(void)loadData{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    __weak PostView *weakSelf = self;
    NSString *url = [NSString stringWithFormat:@"%@getPostByUserId?id=1",HostUrl];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        MyLog(@"FlyElephant: %@", responseObject);
        [weakSelf creatDataArrayFromObj:responseObject];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        MyLog(@"FlyElephant: %@", error);
        [[Toast shareToast] showContent:@"加载失败..." adTime:2];
    }];
    
    
    
}
-(void)creatDataArrayFromObj:(id)obj{
    NSDictionary *dicData = obj;
    MyLog(@"%@",dicData);
    NSArray *contentArray = [dicData objectForKey:@"content"];
    if (contentArray.count == 0 ) {
        [[Toast shareToast] showContent:@"暂无帖子" adTime:2];
        return;
    }
    for (NSDictionary *dic in contentArray) {
        MyLog(@"%@",[dic objectForKey:@"post"]);
        NSDictionary *postDic = [dic objectForKey:@"post"];
        PostsModel *posts = [PostsModel mj_objectWithKeyValues:postDic];
        NSArray *imageArray = [dic objectForKey:@"postImages"];
        for (NSDictionary *imageDic in imageArray) {
            PostImage *postImage = [PostImage mj_objectWithKeyValues:imageDic];
            [posts.postImageArray  addObject:postImage];
        }
        if ([posts.content isEqualToString:@"音频"]) {
            posts.isAudo = YES;
        }
        ///判断类型
        if (posts.isAudo) {
            posts.type = 1;
        }else if (posts.postImageArray.count <= 1 && !posts.isAudo) {
            posts.type = 2;
        }else{
            posts.type = 3;
        }
        ///设置消息高度
        if (!posts.isAudo) {
            posts.lbMessageHeight = [Tool measureMutilineStringHeight:posts.content andFont:MessageFont andWidthSetup:UISCREW - 20];
        }
        if (posts.lbMessageHeight > 53) {
            posts.isCoverHiden = YES;
        }
        if (posts.type == 1) {
            posts.cellHeight = TyptOneH;
        }
        if (posts.type == 2) {
            posts.cellHeight = TypeTwoH + posts.lbMessageHeight;
            
        }
        if (posts.type == 3) {
            if (posts.postImageArray.count > 3) {
                posts.cellHeight = TypeThreeH + posts.lbMessageHeight;
                
            }else{
                posts.cellHeight = TypeThreeH + posts.lbMessageHeight - 123;
            }
        }
        
        [self.dataArray addObject:posts];
    }
    [self.dynamicTable.mj_header endRefreshing];
    [self.dynamicTable reloadData];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PostsModel *posts = [self.dataArray objectAtIndex:indexPath.section];
    
    if (posts.type == 1) {
        static NSString *cellID = @"TypeOneTableViewCell";
        TypeOneTableViewCell *myCell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!myCell) {
            myCell = [[[NSBundle mainBundle]loadNibNamed:cellID owner:self options:nil] firstObject];
            
        }
#warning 给各种控件赋值即可
        [myCell.hotScrollView addSubview:myCell.postsView];
        return myCell;
    }else if (posts.type == 2) {
        static NSString *cellID = @"TypeTowTableViewCell";
        TypeTowTableViewCell *myCell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!myCell) {
            myCell = [[[NSBundle mainBundle]loadNibNamed:cellID owner:self options:nil] firstObject];
            
        }
        myCell.messageHeight.constant = posts.lbMessageHeight;
        myCell.lbMessage.text = posts.content;
        if (posts.isCoverHiden) {
            myCell.imageViewTop.constant = 1;
        }else{
            myCell.imageViewTop.constant = 16;
        }
        return myCell;
    }else{
        static NSString *cellID = @"TypeThreeTableViewCell";
        TypeThreeTableViewCell *myCell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!myCell) {
            myCell = [[[NSBundle mainBundle]loadNibNamed:cellID owner:self options:nil] firstObject];
        }
        myCell.messageHeight.constant = posts.lbMessageHeight;
        if (posts.isCoverHiden) {
            myCell.imageViewTop.constant = 1;
            myCell.imageViewTop1.constant = 1;
        }else{
            myCell.imageViewTop.constant = 16;
            myCell.imageViewTop1.constant = 16;
        }
        return myCell;
    }
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 20;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    PostsModel *model = [self.dataArray objectAtIndex:indexPath.section];
    return model.cellHeight;
}
@end
