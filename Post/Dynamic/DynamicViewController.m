//
//  DynamicViewController.m
//  Post
//
//  Created by admin on 2016/11/3.
//  Copyright © 2016年 Post. All rights reserved.
//

#import "DynamicViewController.h"
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

@interface DynamicViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UIButton *_btnDyanmic;
    UIButton *_btnCircle;
    UIView *_titleLine;
}
//@property (weak, nonatomic) IBOutlet UIScrollView *mainScroll;
@property (nonatomic , strong) UIScrollView *mainScroll;
@property (nonatomic , strong) UITableView *dynamicTable;
@property (nonatomic , strong) UITableView *circleTable;
@property (nonatomic , strong) NSMutableArray *dataArray;

@end

@implementation DynamicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
}
-(void)loadView{
    [super loadView];
    self.automaticallyAdjustsScrollViewInsets = NO;
    UIButton *btnsearch = [UIButton buttonWithType:UIButtonTypeCustom];
    btnsearch.frame = CGRectMake(0, 0, 35, 35);
    btnsearch.tag = 1;
    [btnsearch addTarget:self action:@selector(topAction:) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *search = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
    search.image = [UIImage imageNamed:@"search.png"];
    search.frame = CGRectMake(0, 0, 20, 20);
    search.center = btnsearch.center;
    [btnsearch addSubview:search];
    
    UIBarButtonItem *searchItem = [[UIBarButtonItem  alloc]initWithCustomView:btnsearch];
    
    UIButton *btnAdd = [UIButton buttonWithType:UIButtonTypeCustom];
    btnAdd.frame = CGRectMake(0, 0, 35, 35);
    btnAdd.tag = 2;
    [btnAdd addTarget:self action:@selector(topAction:) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *add = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
    add.image = [UIImage imageNamed:@"add.png"];
    add.frame = CGRectMake(0, 0, 20, 20);
    add.center = btnsearch.center;
    [btnAdd addSubview:add];
    
    UIBarButtonItem *addItem = [[UIBarButtonItem  alloc]initWithCustomView:btnAdd];
    
    self.navigationItem.rightBarButtonItems = @[searchItem,addItem];
    
    UIView *title = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    _btnDyanmic = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnDyanmic.frame = CGRectMake(0, 0, 40, 40);
    _btnDyanmic.center = CGPointMake(20, 20);
    _btnDyanmic.tag = 1;
    [_btnDyanmic addTarget:self action:@selector(titleAction:) forControlEvents:UIControlEventTouchUpInside];
    [_btnDyanmic setTitle:@"动态" forState:UIControlStateNormal];
    [_btnDyanmic setTitleColor:APPCOLOR forState:UIControlStateNormal];
    [title addSubview:_btnDyanmic];
    
    _btnCircle = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnCircle.tag = 2;
    _btnCircle.frame = CGRectMake(0, 0, 40, 40);
    _btnCircle.center = CGPointMake(80, 20);
    [_btnCircle addTarget:self action:@selector(titleAction:) forControlEvents:UIControlEventTouchUpInside];
    [_btnCircle setTitle:@"圈子" forState:UIControlStateNormal];
    [_btnCircle setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [title addSubview:_btnCircle];
    
    _titleLine = [[UIView alloc] initWithFrame:CGRectMake(0, 38, 42, 1)];
    _titleLine.center = CGPointMake(20, 38);
    _titleLine.backgroundColor = APPCOLOR;
    [title addSubview:_titleLine];
    
    self.navigationItem.titleView = title;
    [self.view addSubview:self.mainScroll];
    [self.dynamicTable.mj_header beginRefreshing];
    
    
}
-(void)loadData{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    __weak DynamicViewController *weakSelf = self;
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
-(NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}
-(UIScrollView *)mainScroll{
    if (!_mainScroll) {
        _mainScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, UISCREW, UISCREH)];
        _mainScroll.pagingEnabled = YES;
        _mainScroll.contentSize = CGSizeMake(2*UISCREW, 0);
        _mainScroll.showsHorizontalScrollIndicator = NO;
        _mainScroll.showsVerticalScrollIndicator = NO;
        _mainScroll.bounces = NO;
        [_mainScroll addSubview:self.dynamicTable];
        [_mainScroll addSubview:self.circleTable];
     }
    return _mainScroll;
}
-(UITableView *)dynamicTable{
    if (!_dynamicTable) {
        _dynamicTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, UISCREW, UISCREH - 108) style:UITableViewStyleGrouped];
//        _dynamicTable.backgroundColor = [UIColor blueColor];
        _dynamicTable.delegate = self;
        _dynamicTable.dataSource = self;
        _dynamicTable.tag = 0;
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
-(UITableView *)circleTable{
    if (!_circleTable) {
        _circleTable = [[UITableView alloc] initWithFrame:CGRectMake(UISCREW, 64, UISCREW, UISCREH -108) style:UITableViewStyleGrouped];
        _circleTable.backgroundColor = [UIColor redColor];
        _circleTable.delegate = self;
        _circleTable.dataSource = self;
        _circleTable.tag = 1;
    }
    return _circleTable;
}

/**
 标题View点击

 @param btn tag == 1 为动态
 */
-(void)titleAction:(UIButton *)btn{
    [btn setTitleColor:APPCOLOR forState:UIControlStateNormal];
    NSInteger tag = btn.tag;
    if (tag == 1) {
        [UIView animateWithDuration:0.3 animations:^{
            _titleLine.center = CGPointMake(20, 38);
        }];
       [_btnCircle setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

    }else{
        [UIView animateWithDuration:0.3 animations:^{
            _titleLine.center = CGPointMake(74, 38);
        }];
        [_btnDyanmic setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
}
-(void)topAction:(UIButton *)btn{
    UIStoryboard *storyBoard;
    if (btn.tag == 1) {
        MyLog(@"搜索");
        storyBoard = [UIStoryboard storyboardWithName:@"SearchStoryboard" bundle:nil];
        
    }else{
        MyLog(@"添加");
       storyBoard = [UIStoryboard storyboardWithName:@"AddPostsStoryboard" bundle:nil];
    }
    
    [self presentViewController:storyBoard.instantiateInitialViewController animated:YES completion:nil];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PostsModel *posts = [self.dataArray objectAtIndex:indexPath.section];
    
    NSInteger tag = tableView.tag;
    if (tag == 0) {
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
        
    }else{
        static NSString *cellID = @"cellCirleID";
        UITableViewCell *myCell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!myCell) {
            myCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
