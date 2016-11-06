//
//  IPImageReaderViewController.m
//  IPickerDemo
//
//  Created by Wangjianlong on 16/2/29.
//  Copyright © 2016年 JL. All rights reserved.
//

#import "IPImageReaderViewController.h"
#import "IPZoomScrollView.h"
#import "IPAssetModel.h"
#import "IPAlertView.h"
#import<AssetsLibrary/AssetsLibrary.h>
#import "IPPrivateDefine.h"


@interface IPImageReaderCell : UICollectionViewCell
/**伸缩图*/
@property (nonatomic, strong)IPZoomScrollView *zoomScroll;


@end

@implementation IPImageReaderCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        // Configure the cell
        self.backgroundColor = [UIColor blackColor];
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _zoomScroll  = [[IPZoomScrollView alloc]init];
        _zoomScroll.frame = self.bounds;
        [self addSubview:_zoomScroll];
    }
    return self;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    _zoomScroll.frame = self.bounds;
}

@end


@interface IPImageReaderViewController ()<UICollectionViewDelegateFlowLayout>
/**图片数组*/
@property (nonatomic, strong)NSArray *dataArr;
/**第一次出现时,要滚动到指定位置*/
@property (nonatomic, assign)BOOL isFirst;

/**发生转屏时,要滚动到指定位置*/
@property (nonatomic, assign)BOOL isRoration;
/**需要跳转到指定位置*/
@property (nonatomic, assign)NSUInteger targetIndex;

/**左返回按钮*/
@property (nonatomic, weak)UIButton *leftButton;

/**右返回按钮*/
@property (nonatomic, weak)UIButton *rightButton;

/**头部视图*/
@property (nonatomic, weak)UIImageView *headerView;

/**当前位置*/
@property (nonatomic, assign)NSUInteger currentIndex;

/**旋屏前的位置*/
@property (nonatomic, assign)NSUInteger pageIndexBeforeRotation;

///**itemSize*/
//@property (nonatomic, assign)CGSize itemSize;


@end

@implementation IPImageReaderViewController

static NSString * const reuseIdentifier = @"Cell";
+ (instancetype)imageReaderViewControllerWithData:(NSArray<IPAssetModel *> *)data TargetIndex:(NSUInteger)index{
    if (data == nil || data.count == 0 ) {
        return nil;
    }
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc]init];
    
    flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flow.minimumInteritemSpacing = 0;
    flow.minimumLineSpacing = 0;
    IPImageReaderViewController *vc = [[IPImageReaderViewController alloc]initWithCollectionViewLayout:flow];
    vc.dataArr = data;
    vc.targetIndex = index;
    return vc;
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    [self.collectionView registerClass:[IPImageReaderCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    [self addHeaderView];
    
}
- (void)addHeaderView{
    
    //添加背景图
    UIImageView *headerView = [[UIImageView alloc]init];
    headerView.userInteractionEnabled = YES;
    UIImage *headerImage =[UIImage imageNamed:@"photobrowse_top"];
    headerView.image = headerImage;
    headerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:headerView];
    self.headerView = headerView;
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
    UIImage *leftBtnImage =[UIImage imageNamed:@"bar_btn_icon_returntext_white"];
    [leftBtn setImage:leftBtnImage forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(cancle) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:leftBtn];
    self.leftButton = leftBtn;
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    UIImage *image =[UIImage imageNamed:@"img_icon_check_Big"];
    UIImage *image_p =[UIImage imageNamed:@"img_icon_check_Big_p"];
    [rightBtn setImage:image forState:UIControlStateNormal];
    [rightBtn setImage:image_p forState:UIControlStateSelected];
    [rightBtn addTarget:self action:@selector(selectBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:rightBtn];
    self.rightButton = rightBtn;
    
    
}
- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
}
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.headerView.frame = CGRectMake(0, 0, self.view.bounds.size.width, IOS7_STATUS_BAR_HEGHT + 44);
    self.leftButton.frame = CGRectMake(10, IOS7_STATUS_BAR_HEGHT, 15, 25);
    self.rightButton.frame = CGRectMake(self.view.bounds.size.width - 44, IOS7_STATUS_BAR_HEGHT, 30, 30);
    
    NSUInteger maxIndex = self.dataArr.count - 1;
    NSUInteger minIndex = 0;
    if (self.targetIndex < minIndex) {
        self.targetIndex = minIndex;
    } else if (self.targetIndex > self.targetIndex) {
        self.targetIndex = maxIndex;
    }
    if (self.isFirst == NO) {
        
        if (self.targetIndex == 0) {//当滚动到0的位置时,默认是不调用scrolldidscroll方法的
            IPAssetModel *model = self.dataArr[0];
            self.rightButton.selected = model.isSelect;
        }
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.targetIndex inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        
        self.isFirst = YES;
    }
    if (self.isRoration) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currentIndex inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        self.isRoration = NO;
        IPAssetModel *model = self.dataArr[_currentIndex];
        IPZoomScrollView *thePage = [self pageDisplayingPhoto:model];
        [thePage displayImageWithFullScreenImage];
    }
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    IPAssetModel *model = self.dataArr[_targetIndex];
    IPZoomScrollView *thePage = [self pageDisplayingPhoto:model];
    [thePage displayImageWithFullScreenImage];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
     NSLog(@"IPImageReaderViewController---didReceiveMemoryWarning");
    
    // Dispose of any resources that can be recreated.
}
- (void)dealloc{
    
    NSLog(@"IPImageReaderViewController---dealloc");
}
- (void)cancle{
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}
- (void)selectBtn:(UIButton *)btn{
    btn.selected = !btn.selected;
    
    if (btn.selected) {
        if (self.currentCount == self.maxCount) {
            [IPAlertView showAlertViewAt:self.view MaxCount:self.maxCount];
            btn.selected = NO;
            return;
        }
        self.currentCount ++;
    }else {
        self.currentCount --;
    }
//    NSLog(@"%tu",_currentIndex);
    IPAssetModel *model = self.dataArr[_currentIndex];
    model.isSelect = btn.selected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickSelectBtnForReaderView:)]) {
        [self.delegate clickSelectBtnForReaderView:model];
    }
    
}

- (BOOL)shouldAutorotate{
    return NO;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    // Remember page index before rotation
    _pageIndexBeforeRotation = _currentIndex;
    
    
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    // Perform layout
    _currentIndex = _pageIndexBeforeRotation;
    self.isRoration = YES;
    
    IPAssetModel *model = self.dataArr[_currentIndex];
    self.rightButton.selected = model.isSelect;
    
    [self.collectionView reloadData];
    
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    self.isRoration = NO;
    
}
#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    IPImageReaderCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    IPAssetModel *model = [self.dataArr objectAtIndex:indexPath.item];
    cell.zoomScroll.ipVc = self.ipVc;
    cell.zoomScroll.imageModel = model;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return self.view.bounds.size;
}
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(IPImageReaderCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%tu",indexPath.item);
    [cell.zoomScroll prepareForReuse];
    
}

#pragma mark <UICollectionViewDelegate>
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.isRoration) {
        return;
    }
    CGRect visibleBounds = scrollView.bounds;
    NSInteger index = (NSInteger)(floorf(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds)));
    if (index < 0) index = 0;
    if (index > [self.dataArr count] - 1) index = [self.dataArr count] - 1;
    NSUInteger previousCurrentPage = _currentIndex;
    _currentIndex = index;
    if (_currentIndex != previousCurrentPage) {
        IPAssetModel *model = self.dataArr[_currentIndex];
        self.rightButton.selected = model.isSelect;
    }
   
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
   
    [UIView animateWithDuration:0.3
                     animations:^{
                         
                         self.headerView.alpha = 0.0f;
                     }completion:nil];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [UIView animateWithDuration:0.3
                     animations:^{
                         
                         self.headerView.alpha = 1.0f;
                     }completion:nil];
    
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    IPAssetModel *model = self.dataArr[_currentIndex];
    IPZoomScrollView *thePage = [self pageDisplayingPhoto:model];
    [thePage displayImageWithFullScreenImage];
    
    NSLog(@"scrollViewDidEndDecelerating");
}

- (IPZoomScrollView *)pageDisplayingPhoto:(IPAssetModel *)model {
    IPZoomScrollView *thePage = nil;
    for (IPImageReaderCell *cell in self.collectionView.visibleCells) {
        if (cell.zoomScroll.imageModel == model) {
            thePage = cell.zoomScroll; break;
        }
    }
    return thePage;
}




@end

