//
//  DynamicViewController.m
//  Post
//
//  Created by admin on 2016/11/3.
//  Copyright © 2016年 Post. All rights reserved.
//

#import "DynamicViewController.h"
#import "PostView.h"
#import "CircleView.h"




@interface DynamicViewController ()<UIScrollViewDelegate>
{
    UIButton *_btnDyanmic;
    UIButton *_btnCircle;
    UIView *_titleLine;
}
//@property (weak, nonatomic) IBOutlet UIScrollView *mainScroll;
@property (nonatomic , strong) UIScrollView *mainScroll;
@property (nonatomic , strong) PostView *postsView;

@property (nonatomic , strong) CircleView *circleView;

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
    _btnDyanmic.tag = 0;
    [_btnDyanmic addTarget:self action:@selector(titleAction:) forControlEvents:UIControlEventTouchUpInside];
    [_btnDyanmic setTitle:@"动态" forState:UIControlStateNormal];
    [_btnDyanmic setTitleColor:APPCOLOR forState:UIControlStateNormal];
    [title addSubview:_btnDyanmic];
    
    _btnCircle = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnCircle.tag = 1;
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
    [self.postsView.dynamicTable.mj_header beginRefreshing];
    
    
}


-(UIScrollView *)mainScroll{
    if (!_mainScroll) {
        _mainScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, UISCREW, UISCREH)];
        _mainScroll.pagingEnabled = YES;
        _mainScroll.contentSize = CGSizeMake(2*UISCREW, 0);
        _mainScroll.showsHorizontalScrollIndicator = NO;
        _mainScroll.showsVerticalScrollIndicator = NO;
        _mainScroll.bounces = NO;
        _mainScroll.delegate = self;
        [_mainScroll addSubview:self.postsView];
        [_mainScroll addSubview:self.circleView];
     }
    return _mainScroll;
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if ([[scrollView class] isSubclassOfClass:[UIScrollView class]]) {
        NSInteger page = scrollView.contentOffset.x / scrollView.width;
        MyLog(@"%li",page);
        if (page == 1) {
            [self titleAction:_btnCircle];
        }else{
            [self titleAction:_btnDyanmic];
        }
    }
    
}
-(PostView *)postsView{
    if (!_postsView) {
        _postsView = [[PostView alloc] initWithFrame:CGRectMake(0, 64, UISCREW, UISCREH -108)];
    }
    return _postsView;
}
-(CircleView *)circleView{
    if (!_circleView) {
        _circleView = [[CircleView alloc] initWithFrame:CGRectMake(UISCREW, 64, UISCREW, UISCREH -108)];
    }
    return _circleView;
}
/**
 标题View点击

 @param btn tag == 1 为圈子
 */
-(void)titleAction:(UIButton *)btn{
    
    [btn setTitleColor:APPCOLOR forState:UIControlStateNormal];
    NSInteger tag = btn.tag;
    [self.mainScroll setContentOffset:CGPointMake(tag * UISCREW, 0) animated:YES];
    if (tag == 1) {
        [UIView animateWithDuration:0.3 animations:^{
            _titleLine.center = CGPointMake(74, 38);
        }];
       [_btnDyanmic setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

    }else{
        [UIView animateWithDuration:0.3 animations:^{
            _titleLine.center = CGPointMake(20, 38);
        }];
        [_btnCircle setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
}
-(void)topAction:(UIButton *)btn{
    /// page：判断是否是帖子界面
    NSInteger page = self.mainScroll.contentOffset.x/UISCREW;
    UIStoryboard *storyBoard;
    if (btn.tag == 1) {
        MyLog(@"搜索");
        if (page == 0) {
            MyLog(@"搜索帖子");
            storyBoard = [UIStoryboard storyboardWithName:@"SearchPostStoryboard" bundle:nil];
        }else{
            MyLog(@"搜索圈子");
            storyBoard = [UIStoryboard storyboardWithName:@"SearchCircleStoryboard" bundle:nil];

        }
        
    }else{
        MyLog(@"添加");
        if (page == 0) {
            MyLog(@"添加帖子");
             storyBoard = [UIStoryboard storyboardWithName:@"AddPostsStoryboard" bundle:nil];
        }else{
            MyLog(@"添加圈子");
            
            storyBoard = [UIStoryboard storyboardWithName:@"AddCircleStoryboard" bundle:nil];
        }
      
    }
    
    [self presentViewController:storyBoard.instantiateInitialViewController animated:YES completion:nil];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
