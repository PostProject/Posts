//
//  IPickerViewController.m
//  ImagePickerDemo
//
//  Created by Wangjianlong on 16/2/27.
//  Copyright © 2016年 JL. All rights reserved.
//

#import "IPickerViewController.h"
#import "IP3DTouchPreviewVC.h"
#import<AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "IPAlbumModel.h"
#import "IPAlbumView.h"
#import "IPImageCell.h"
#import "IPAssetManager.h"
#import "IPImageReaderViewController.h"
#import "IPAlertView.h"
#import "IPTakeVideoViewController.h"

#import "IPPrivateDefine.h"


/**获取图片样式*/
typedef NS_ENUM(NSUInteger,  GetImageType) {
    
    GetImageTypeThumbail,
    
    GetImageTypeAspectThumbail,
    
    GetImageTypeFullScreen
};

NSString * const IPICKER_LOADING_DID_END_Thumbnail_NOTIFICATION = @"IPICKER_LOADING_DID_END_Thumbnail_NOTIFICATION";

@interface IPickerViewController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,IPAlbumViewDelegate,IPAssetManagerDelegate,IPImageCellDelegate,IPImageReaderViewControllerDelegate,IPTakeVideoViewControllerDelegate,UIViewControllerPreviewingDelegate,PHPhotoLibraryChangeObserver,CAAnimationDelegate>
/**图库*/
@property (nonatomic, strong)IPAssetManager *defaultAssetManager;


/**头部视图*/
@property (nonatomic, weak)UIView *headerView;

/**头部视图*/
@property (nonatomic, weak)UIButton *leftBtn;

/**中部视图*/
@property (nonatomic, weak)UIButton *centerBtn;

/**箭头指示器*/
@property (nonatomic, weak)UIImageView *arrowImge;

/**右部LABEL*/
@property (nonatomic, weak)UILabel *rightLabel;

/**右部视图*/
@property (nonatomic, weak)UIButton *rightBtn;

/**头部视图底部分割线*/
@property (nonatomic, weak)UIView *spliteView;

/**主视图*/
@property (nonatomic, weak)UICollectionView *mainView;

/**布局对象*/
@property (nonatomic, strong)UICollectionViewFlowLayout *flowOut;

/**相册列表view*/
@property (nonatomic, strong)IPAlbumView *albumView;

/**选中的图片数量*/
@property (nonatomic, assign)NSUInteger selectPhotoCount;

/**当前选择的图片数组*/
@property (nonatomic, strong)NSMutableArray *priCurrentSelArr;

/**专辑背景view*/
@property (nonatomic, strong)UIView *albumBackView;

/**图片数组的缓存*/
@property (nonatomic, strong)NSMutableDictionary *imageModelDic;

/**当前显示的图片数组*/
@property (nonatomic, strong)NSMutableArray *curImageModelArr;

/**显示样式*/
@property (nonatomic, assign)IPickerViewControllerDisplayStyle displayStyle;

/**需要重新刷新*/
@property (nonatomic, assign)BOOL refreshData;

@end
static NSString *IPicker_CollectionID = @"IPicker_CollectionID";

@implementation IPickerViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.maxCount = 50;
        if (iOS8Later) {
            [[PHPhotoLibrary sharedPhotoLibrary]registerChangeObserver:self];
            if([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusDenied) {
                //                [PHPhotoLibrary requestAuthorization:nil];
            };
        }
    }
    return self;
}
- (instancetype)init{
    if (self = [super init]) {
        self.maxCount = 50;
        
    }
    return self;
}
- (void)getDataFromManager{
    if (self.refreshData == YES) return;
    
    self.refreshData = YES;
    if (self.displayStyle == IPickerViewControllerDisplayStyleVideo) {
        self.arrowImge.hidden = YES;
        self.centerBtn.userInteractionEnabled = NO;
        [self.centerBtn setTitle:@"选择视频" forState:UIControlStateNormal];
        
        [self.defaultAssetManager reloadVideosFromLibrary];
        self.rightBtn.hidden = YES;
    }else {
        [self.defaultAssetManager reloadImagesFromLibrary];
    }
}
- (void)freeAllData{
    _refreshData = NO;
    _defaultAssetManager = nil;
    [_imageModelDic removeAllObjects];
    [_curImageModelArr removeAllObjects];
    _selectPhotoCount = 0;
    [_priCurrentSelArr removeAllObjects];
    [IPAssetManager freeAssetManger];
    
}
- (void)photoLibraryDidChange:(PHChange *)changeInstance{
    
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
        
        
        if (self.curImageModelArr.count == 0) {
            if (self.displayStyle == IPickerViewControllerDisplayStyleVideo) {
                
                [self.defaultAssetManager reloadVideosFromLibrary];
            }else {
                [self.defaultAssetManager reloadImagesFromLibrary];
            }
        }
        
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    [self addMainView];
    [self addHeaderView];
    [self getDataFromManager];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)dealloc{
    NSLog(@"IPickerViewController--dealloc");
    [self freeAllData];
    
    [[PHPhotoLibrary sharedPhotoLibrary]unregisterChangeObserver:self];
    
}


#pragma mark - UI -
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    CGFloat viewW = self.view.bounds.size.width;
    CGFloat viewH = self.view.bounds.size.height;
    CGFloat headerH = IOS7_STATUS_BAR_HEGHT + headerHeight;
    CGFloat btnH = headerHeight;
    CGFloat btnW = headerHeight;
    CGFloat MaxMargin = 5.0f;
    
    
    self.headerView.frame = CGRectMake(0, 0, viewW, headerH);
    self.leftBtn.frame = CGRectMake(MaxMargin, IOS7_STATUS_BAR_HEGHT, btnW, btnH);
    
    CGSize tempSize = CGSizeZero;
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:15.0f]/*,NSParagraphStyleAttributeName:paragraph*/};
    tempSize = [@"这里是汽车之家测试" boundingRectWithSize:CGSizeMake(MAXFLOAT, btnH) options: NSStringDrawingTruncatesLastVisibleLine |
                    NSStringDrawingUsesLineFragmentOrigin |
                    NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    
    
    CGSize size = [self.centerBtn sizeThatFits:tempSize];
    CGFloat minMargin = 0;
    if (size.width > tempSize.width) {
        size = tempSize;
        minMargin = 6;
        if ([[UIDevice currentDevice].systemVersion doubleValue] >= 9.0) {
            minMargin = 3;
        }
    }
    self.centerBtn.frame = CGRectMake(self.headerView.center.x - size.width/2, IOS7_STATUS_BAR_HEGHT, size.width, btnH);
    self.rightBtn.frame = CGRectMake(viewW - btnW -MaxMargin, IOS7_STATUS_BAR_HEGHT, btnW, btnH);
    
    self.arrowImge.frame = CGRectMake(CGRectGetMaxX(self.centerBtn.frame)- minMargin, IOS7_STATUS_BAR_HEGHT, btnW/2, btnH);
    
    
    self.spliteView.frame = CGRectMake(0, headerH - 0.5,viewW, 0.5);
    
    self.mainView.frame = CGRectMake(0, headerH, viewW, viewH - headerH);
}
- (void)addHeaderView{
    
    UIView *headerView = [[UIView alloc]init];
    [headerView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:headerView];
    self.headerView = headerView;
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.backgroundColor = [UIColor clearColor];
    [leftBtn sizeToFit];
    [leftBtn setTitle:@"取消" forState:UIControlStateNormal];
    [leftBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//    [leftBtn.titleLabel setFontSizeKey:textfont05];
    [leftBtn addTarget:self action:@selector(exitIPicker) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:leftBtn];
    self.leftBtn = leftBtn;
    
    UIButton *centerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    centerBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [centerBtn addTarget:self action:@selector(displayAlbumView:) forControlEvents:UIControlEventTouchUpInside];
    centerBtn.contentMode = UIViewContentModeCenter;
    centerBtn.titleLabel.font = [UIFont systemFontOfSize:15];//textsize04
    centerBtn.backgroundColor = [UIColor clearColor];
    [centerBtn setTitle:@"选择相册" forState:UIControlStateNormal];
    [centerBtn setTitleColor:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0] forState:UIControlStateNormal];
    [centerBtn sizeToFit];
    [headerView addSubview:centerBtn];
    self.centerBtn = centerBtn;
    
    
    UIImageView *arrowImge = [[UIImageView alloc]init];
    arrowImge.contentMode = UIViewContentModeCenter;
    UIImage *image =[UIImage imageNamed:@"common_icon_arrow"];
    [arrowImge  setImage:image];
    [headerView addSubview:arrowImge];
    self.arrowImge = arrowImge;
    
    UILabel    *rightLabel = [[UILabel alloc]init];
    rightLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewContentModeBottom | UIViewContentModeBottomRight;
    rightLabel.font = [UIFont systemFontOfSize:12];
    rightLabel.textAlignment = NSTextAlignmentCenter;
    rightLabel.clipsToBounds = YES;
    rightLabel.textColor = [UIColor whiteColor];
    [rightLabel setBackgroundColor:[UIColor blueColor]];
    [rightLabel setText:@""];
    [rightLabel sizeToFit];
    rightLabel.hidden = YES;
    [headerView addSubview:rightLabel];
    self.rightLabel = rightLabel;
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn sizeToFit];
    [rightBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
//    [rightBtn.titleLabel setFontSizeKey:textfont05];
    [rightBtn setTitle:@"完成" forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(completeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    rightBtn.userInteractionEnabled = NO;
    [headerView addSubview:rightBtn];
    rightBtn.backgroundColor = [UIColor clearColor];
    self.rightBtn = rightBtn;
    
    UIView *spliteView = [[UIView alloc]init];
    spliteView.backgroundColor = [UIColor lightGrayColor];
    [headerView addSubview:spliteView];
    self.spliteView = spliteView;
}

- (void)addMainView{
    _flowOut = [[UICollectionViewFlowLayout alloc]init];
    _flowOut.sectionInset = UIEdgeInsetsMake(5, 0, 0, 0);
    UICollectionView *mainView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:_flowOut];
    mainView.showsHorizontalScrollIndicator = NO;
    mainView.showsVerticalScrollIndicator = NO;
    [mainView setBackgroundColor:[UIColor lightGrayColor]];
    mainView.delegate = self;
    mainView.dataSource = self;
    [mainView registerClass:[IPImageCell class] forCellWithReuseIdentifier:IPicker_CollectionID];
    self.mainView = mainView;
    [self.view addSubview:mainView];
}

#pragma mark - collectionview-

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.curImageModelArr.count;
}
- (IPImageCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    IPImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:IPicker_CollectionID forIndexPath:indexPath];
    cell.ipVc = self;
    if (self.curImageModelArr.count > indexPath.item) {
        
        IPAssetModel *model = self.curImageModelArr[indexPath.item];
        cell.model = model;
        cell.delegate = self;
    }
    if ([[UIDevice currentDevice].systemVersion doubleValue] >= 9.0f) {
        [self registerForPreviewingWithDelegate:self sourceView:cell];
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSUInteger rowCount = 4;
    NSUInteger margin = 5;
    CGFloat itemWidth = (collectionView.frame.size.width - (rowCount-1)*margin)/rowCount;
    return CGSizeMake(itemWidth, itemWidth);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 5;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 5;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.item < self.curImageModelArr.count) {
        IPAssetModel *model = self.curImageModelArr[indexPath.item];
        __weak typeof(self) weakSelf = self;
        
        
        
        if (model.assetType == IPAssetModelMediaTypeTakeVideo) {
            
            IPTakeVideoViewController *takeVideo = [[IPTakeVideoViewController alloc]init];
            takeVideo.delegate = weakSelf;
            [self presentViewController:takeVideo animated:YES completion:nil];
            
        }
        else if(model.assetType == IPAssetModelMediaTypeTakePhoto){
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"拍照" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            
        }
        else if(model.assetType == IPAssetModelMediaTypeVideo){
            __block IPAlertView *alert = [IPAlertView showAlertViewAt:self.view Text:@"视频加载中..."];
            [self.defaultAssetManager compressVideoWithAssetModel:model CompleteBlock:^(AVPlayerItem *item) {
                [alert dismissFromHostView];
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(imgPicker:didFinishCaptureVideoItem:Videourl:videoDuration:thumbailImage:)]) {
                    
                    [weakSelf.delegate imgPicker:weakSelf didFinishCaptureVideoItem:item Videourl:nil videoDuration:(float)model.duration thumbailImage:model.VideoThumbail];
                    
                }
                NSLog(@"%@",[NSThread currentThread]);
                //                [weakSelf exitIPickerWithAnimation:YES];
                
                
            }];
            
        }else {
            IPImageReaderViewController *reader = [IPImageReaderViewController imageReaderViewControllerWithData:self.curImageModelArr TargetIndex:indexPath.item];
            reader.maxCount = self.maxCount;
            reader.currentCount = self.selectPhotoCount;
            reader.delegate = self;
            reader.ipVc = self;
            if (reader) {
                //定义个转场动画
                CATransition *animation = [CATransition animation];
                //转场动画持续时间
                animation.duration = 0.2f;
                //计时函数，从头到尾的流畅度？？？
                animation.timingFunction=UIViewAnimationCurveEaseInOut;
                //转场动画类型
                animation.type = kCATransitionPush;
                //转场动画将去的方向
                animation.subtype = kCATransitionFromRight;
                animation.delegate = self;
                //添加动画 （转场动画是添加在层上的动画）
                [self.view.window.layer addAnimation:animation forKey:nil];
                [self presentViewController:reader animated:YES completion:nil];
            }else {
                NSLog(@"内存吃紧啊");
            }
            
        }
        
    }
    
    
}
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(IPImageCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    [cell endDisplay];
}

#pragma  mark - 导航条左右按钮的处理逻辑 -
- (void)exitIPickerWithAnimation:(BOOL)animation{
    if (animation) {
        [self exitIPicker];
    }else {
        [self freeAllData];
    }
}
/**
 *  左上角的取消按钮点击
 */
- (void)exitIPicker{
    
    CATransition * transition=[CATransition animation];
    transition.duration=0.3f;
    transition.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    transition.type=kCATransitionReveal;
    if (self.popStyle == IPickerViewControllerPopStylePush) {
        transition.subtype=kCATransitionFromLeft;
    }else {
        transition.subtype = kCATransitionFromBottom;
    }
    
    transition.delegate=self;
    if (self.navigationController) {
        [self.navigationController.view.layer addAnimation:transition forKey:nil];
        [self.navigationController popViewControllerAnimated:YES];
        
    }else if(self.presentingViewController){
        
        [self.view.layer addAnimation:transition forKey:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
/**
 *  右上角 完成 按钮点击
 */
- (void)completeBtnClick{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickCompleteBtn:)]) {
        [self.delegate didClickCompleteBtn:[self.priCurrentSelArr copy]];
    }
    [self exitIPicker];
}
#pragma mark 点击右上角的"对勾"对应的逻辑
/**
 *  点击cell右上角的选中按钮
 */
- (BOOL)clickRightCornerBtnForView:(IPAssetModel *)model{
    if (model.isSelect) {
        if (self.selectPhotoCount >= self.maxCount) {
            [IPAlertView showAlertViewAt:self.view MaxCount:self.maxCount];
            return NO;
        }
        [self addImageModel:model WithIsAdd:YES];
    }else {
        [self addImageModel:model WithIsAdd:NO];
    }
    return YES;
}
/**
 *  点击大图浏览时的选中按钮的代理回调方法
 *
 *  @param assetModel 对应的imageModel对象
 */
- (void)clickSelectBtnForReaderView:(IPAssetModel *)assetModel{
    if (assetModel.isSelect) {
        [self addImageModel:assetModel WithIsAdd:YES];
    }else {
        [self addImageModel:assetModel WithIsAdd:NO];
    }
}
- (void)addImageModel:(IPAssetModel *)model WithIsAdd:(BOOL)isAdd{
    if (isAdd) {
        self.selectPhotoCount++;
        if (![self.priCurrentSelArr containsObject:model]) {
            [self.priCurrentSelArr addObject:model];
        }
    }else {
        self.selectPhotoCount--;
        if ([self.priCurrentSelArr containsObject:model]) {
            [self.priCurrentSelArr removeObject:model];
        }
        
    }
}
- (void)setSelectPhotoCount:(NSUInteger)selectPhotoCount{
    if (_selectPhotoCount != selectPhotoCount) {
        _selectPhotoCount = selectPhotoCount;
        if (_selectPhotoCount <= 0) {
            self.rightLabel.hidden = YES;
            self.rightBtn.userInteractionEnabled = NO;
            self.rightBtn.selected = NO;
        }else {
            self.rightBtn.userInteractionEnabled = YES;
            self.rightLabel.hidden = NO;
            self.rightBtn.selected = YES;
        }
        CGFloat labelW = 18.0f;
        if (_selectPhotoCount > 9) {
            
            self.rightLabel.frame = CGRectMake(CGRectGetMinX(self.rightBtn.frame) - labelW-3, IOS7_STATUS_BAR_HEGHT+13, labelW+6, labelW);
        }else {
            
            [self.rightLabel setFrame:CGRectMake(CGRectGetMinX(self.rightBtn.frame) - labelW, IOS7_STATUS_BAR_HEGHT+13, labelW, labelW)];
            
        }
        self.rightLabel.layer.cornerRadius = labelW/2;
        
        [self.rightLabel setText:[NSString stringWithFormat:@"%tu",_selectPhotoCount]];
    }
}
#pragma mark 点击中心按钮对应的逻辑
/**
 *  点击中部相册名称,展示相册列表
 */
- (void)displayAlbumView:(UIButton *)btn{
    
    [self.centerBtn setTitle:@"选择相册" forState:UIControlStateNormal];
    if (_albumView == nil) {
        _albumView = [IPAlbumView albumViewWithData:self.defaultAssetManager.albumArr];
        _albumView.delegate =self;
        
       
    }
    if (_albumBackView == nil) {
        _albumBackView = [[UIView alloc]initWithFrame:CGRectMake(0, IOS7_STATUS_BAR_HEGHT + headerHeight, self.view.bounds.size.width, self.view.bounds.size.height - IOS7_STATUS_BAR_HEGHT - headerHeight)];
        _albumBackView.backgroundColor = [UIColor blackColor];
        _albumBackView.alpha = 0.0f;
    }
    
    if (_albumView.superview) {
        [self shouldRemoveFrom:nil];
        return;
    }
    
    [self.view insertSubview:_albumBackView belowSubview:self.headerView];
    [_albumView setFrame:CGRectMake(0,-(self.view.bounds.size.height - IOS7_STATUS_BAR_HEGHT - headerHeight) , self.view.bounds.size.width, self.view.bounds.size.height - IOS7_STATUS_BAR_HEGHT - headerHeight)];
    [self.view insertSubview:_albumView atIndex:2];
    [UIView animateWithDuration:0.1 animations:^{
        _albumBackView.alpha = 0.6f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            
            self.arrowImge.transform = CGAffineTransformRotate(self.arrowImge.transform,M_PI);
            
            _albumView.transform = CGAffineTransformMakeTranslation(0, self.view.bounds.size.height);
        } completion:^(BOOL finished) {
        }];
    }];
    
    
}
/**
 *  将专辑列表移除
 */
- (void)shouldRemoveFrom:(IPAlbumView *)view{
    
    [self.centerBtn setTitle:self.defaultAssetManager.currentAlbumModel.albumName forState:UIControlStateNormal];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.arrowImge.transform = CGAffineTransformIdentity;
        _albumView.transform = CGAffineTransformMakeTranslation(0, -self.view.bounds.size.height);
    } completion:^(BOOL finished) {
        
        [_albumView removeFromSuperview];
        [_albumView setFrame:CGRectZero];
        _albumView.transform = CGAffineTransformIdentity;
        [UIView animateWithDuration:0.1 animations:^{
            _albumBackView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            if (_albumBackView.superview) {
                [_albumBackView removeFromSuperview];
            }
        }];
    }];
    
}
/**
 *  选中专辑列表的某个cell时的回调方法
 *
 *  @param indexPath 点击对应的索引
 *  @param View      专辑列表 view
 */
- (void)clickCellForIndex:(NSIndexPath *)indexPath ForView:(IPAlbumView *)View{
    IPAlbumModel *model = [self.defaultAssetManager.albumArr objectAtIndex:indexPath.item];
    if (model == self.defaultAssetManager.currentAlbumModel) {
        [self shouldRemoveFrom:View];
        return;
    }
    [self.centerBtn setTitle:model.albumName forState:UIControlStateNormal];
    self.defaultAssetManager.currentAlbumModel = model;
    [self shouldRemoveFrom:View];
    self.selectPhotoCount = self.priCurrentSelArr.count;
    
    if ([self.imageModelDic objectForKey:model.albumIdentifier]) {
        self.curImageModelArr = [self.imageModelDic objectForKey:model.albumIdentifier];

        [self.mainView reloadData];
    }else {
        [self.defaultAssetManager getImagesForAlbumModel:model];
    }
    
    
    
    
}
#pragma mark - Rotation
//- (BOOL)shouldAutorotate{
//    return NO;
//}
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
//    return UIInterfaceOrientationMaskPortrait;
//}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    
    [self.mainView reloadData];
    
}

#pragma mark 获取相册的所有图片
- (void)loadImageUserDeny:(IPAssetManager *)manager{
    NSString *message = @"请在设置->通用->访问限制->照片 启用访问图片的权限!";
    if ([[[UIDevice currentDevice]systemVersion]floatValue]<6.0) {
        message = @"请在设置->通用->访问限制->位置 启用定位服务!";
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"图片访问失败" message:message delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:nil];
    [alertView show];
    
    [self.centerBtn setTitle:@"访问相册失败" forState:UIControlStateNormal];
    [self.centerBtn sizeToFit];
    [self.view setNeedsLayout];
}
- (void)loadImageOccurError:(IPAssetManager *)manager{
    NSString *message = @"访问相册失败,请重试";
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"图片访问失败" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alertView show];
    
    [self.centerBtn setTitle:@"访问相册失败" forState:UIControlStateNormal];
    [self.centerBtn sizeToFit];
    [self.view setNeedsLayout];
}
- (void)loadImageDataFinish:(IPAssetManager *)manager{
    
    self.curImageModelArr = [NSMutableArray arrayWithArray:self.defaultAssetManager.currentPhotosArr];
    [self.curImageModelArr removeObjectAtIndex:0];
    if (self.defaultAssetManager.currentAlbumModel.albumIdentifier) {
        [self.imageModelDic setObject:self.curImageModelArr forKey:self.defaultAssetManager.currentAlbumModel.albumIdentifier];
    }
    
    
    if ([[NSThread currentThread] isMainThread]) {
        [self.centerBtn setTitle:self.defaultAssetManager.currentAlbumModel.albumName forState:UIControlStateNormal];
        [self.centerBtn sizeToFit];
        [self.view setNeedsLayout];
        [self.mainView reloadData];
    }else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.centerBtn setTitle:self.defaultAssetManager.currentAlbumModel.albumName forState:UIControlStateNormal];
            [self.centerBtn sizeToFit];
            [self.view setNeedsLayout];
            [self.mainView reloadData];
        });
    }
}

#pragma mark - alert框的处理
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self exitIPicker];
}
#pragma mark -private
- (void)getAspectPhotoWithAsset:(IPAssetModel *)imageModel photoWidth:(CGSize)photoSize completion:(void (^)(UIImage *photo,NSDictionary *info))completion{
    [self.defaultAssetManager getAspectPhotoWithAsset:imageModel photoWidth:photoSize completion:completion];
}
- (void)getFullScreenImageWithAsset:(IPAssetModel *)imageModel photoWidth:(CGSize)photoSize completion:(void (^)(UIImage *photo,NSDictionary *info))completion{
    [self.defaultAssetManager getFullScreenImageWithAsset:imageModel photoWidth:photoSize completion:completion];
}
- (void)getThumibImageWithAsset:(IPAssetModel *)imageModel photoWidth:(CGSize)photoSize completion:(void (^)(UIImage *photo,NSDictionary *info))completion{
    [self.defaultAssetManager getThumibImageWithAsset:imageModel photoWidth:photoSize completion:completion];
}
#pragma mark - lazy -
- (IPAssetManager *)defaultAssetManager{
    if (_defaultAssetManager == nil) {
        _defaultAssetManager = [IPAssetManager defaultAssetManager];
        _defaultAssetManager.delegate = self;
    }
    return _defaultAssetManager;
}

- (void)setMaxCount:(NSUInteger)maxCount{
    NSInteger tempCount = (NSInteger)maxCount;
    if (_maxCount != tempCount && tempCount > 0) {
        _maxCount = tempCount;
    }else {
        _maxCount = 50;
    }
}
- (NSMutableArray *)priCurrentSelArr{
    if (_priCurrentSelArr == nil) {
        _priCurrentSelArr = [NSMutableArray arrayWithCapacity:self.maxCount];
    }
    return _priCurrentSelArr;
}
- (NSMutableDictionary *)imageModelDic{
    if (_imageModelDic == nil) {
        _imageModelDic = [NSMutableDictionary dictionaryWithCapacity:self.defaultAssetManager.albumArr.count];
    }
    return _imageModelDic;
}

#pragma mark interface
+ (instancetype)instanceWithDisplayStyle:(IPickerViewControllerDisplayStyle)style{
    IPickerViewController *ipVC = [[IPickerViewController alloc]init];
    
    ipVC.displayStyle = style;
    return ipVC;
}
+ (void)getAspectThumbailImageWithImageURL:(NSURL *)imageUrl Width:(CGFloat)width RequestBlock:(RequestImageBlock)block{
    [self getImageWithImageURL:imageUrl Width:width Type:GetImageTypeAspectThumbail RequestBlock:block];
}
+ (void)getThumbailImageWithImageURL:(NSURL *)imageUrl RequestBlock:(RequestImageBlock)block{
    [self getImageWithImageURL:imageUrl Width:80 Type:GetImageTypeThumbail RequestBlock:block];
}
+ (void)getImageWithImageURL:(NSURL *)imageUrl RequestBlock:(RequestImageBlock)block{
    
    [self getImageWithImageURL:imageUrl Width:[UIScreen mainScreen].bounds.size.width Type:GetImageTypeFullScreen RequestBlock:block];
}
+ (BOOL)checkResultIsUseful:(PHFetchResult *)result{
    if (result) {
        if (result.count > 0) {
            return YES;
        }else {
            return NO;
        }
    }else {
        return NO;
    }
}
+ (void)getImageWithImageURL:(NSURL *)imageUrl Width:(CGFloat)width Type:(GetImageType)type RequestBlock:(RequestImageBlock)block{
    if ([imageUrl.absoluteString rangeOfString:@"library:"].location == NSNotFound) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            PHFetchResult *results = nil;
            
            results = [PHAsset fetchAssetsWithLocalIdentifiers:@[imageUrl.absoluteString] options:nil];
            
            if (results.count == 0) {
                PHAssetCollectionSubtype PhotoStreamSubtype = PHAssetCollectionSubtypeAlbumMyPhotoStream;
                
                //获取智能相册
                PHFetchOptions *imageOption = [[PHFetchOptions alloc] init];
                imageOption.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
                imageOption.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
                
                PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum  subtype:PhotoStreamSubtype options:nil];
                for (PHAssetCollection *collection in smartAlbums) {
                    //                NSLog(@"collection %@",collection.localizedTitle);
                    results = [PHAsset fetchAssetsInAssetCollection:collection options:imageOption];
                    break;
                }
                
            }
            if (![self checkResultIsUseful:results]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (block) {
                        block(nil,[NSError errorWithDomain:@"没找到图片" code:404 userInfo:nil]);
                    }
                });
            }
            __block BOOL isFind = NO;
            [results enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
                if ([asset.localIdentifier isEqualToString:[imageUrl absoluteString]]) {
                    isFind = YES;
                    PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
                    CGFloat aspectRatio = asset.pixelWidth / (CGFloat)asset.pixelHeight;
                    CGFloat multiple = [UIScreen mainScreen].scale;
                    CGFloat pixelWidth = width * multiple;
                    CGFloat pixelHeight = pixelWidth / aspectRatio;
                    if (type == GetImageTypeThumbail) {
                        options.resizeMode = PHImageRequestOptionsResizeModeExact;
                        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
                    }else if (type == GetImageTypeAspectThumbail){
                        options.resizeMode = PHImageRequestOptionsResizeModeExact;
                        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
                    }else {
                        options.resizeMode = PHImageRequestOptionsResizeModeExact;
                        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
                    }
                    
                    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(pixelWidth, pixelHeight) contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                        if (result) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (block) {
                                    block(result,nil);
                                }
                            });
                        }else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (block) {
                                    block(nil,[NSError errorWithDomain:@"没找到图片" code:404 userInfo:nil]);
                                }
                            });
                        }
                        
                    }];
                    
                }
                
            }];
            
            if (isFind == NO) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (block) {
                        block(nil,[NSError errorWithDomain:@"没找到图片" code:404 userInfo:nil]);
                    }
                });
            }
        });
    }else {
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
            [lib assetForURL:imageUrl resultBlock:^(ALAsset *asset) {
                if (asset) {
                    UIImage *image;
                    if (type == GetImageTypeThumbail) {
                        image = [UIImage imageWithCGImage:asset.thumbnail];
                    }else if (type == GetImageTypeAspectThumbail){
                        image = [UIImage imageWithCGImage:asset.aspectRatioThumbnail];
                    }else {
                        ALAssetRepresentation *representation = asset.defaultRepresentation;
                        image = [UIImage imageWithCGImage:representation.fullScreenImage];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (block) {
                            block(image,nil);
                        }
                    });
                    
                }else {
                    [lib enumerateGroupsWithTypes:ALAssetsGroupPhotoStream
                                       usingBlock:^(ALAssetsGroup *group, BOOL *stop)
                     {
                         if(group)
                         {
                             __block BOOL isFind = NO;
                             [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                 if([result.defaultRepresentation.url isEqual:imageUrl])
                                 {
                                     isFind = YES;
                                     UIImage *image;
                                     if (type == GetImageTypeThumbail) {
                                         image = [UIImage imageWithCGImage:result.thumbnail];
                                     }else if (type == GetImageTypeAspectThumbail){
                                         image = [UIImage imageWithCGImage:result.aspectRatioThumbnail];
                                     }else {
                                         ALAssetRepresentation *representation = result.defaultRepresentation;
                                         image = [UIImage imageWithCGImage:representation.fullScreenImage];
                                     }
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         if (block) {
                                             block(image,nil);
                                         }
                                     });
                                     *stop = YES;
                                     
                                 }
                             }];
                             if (isFind == NO) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     if (block) {
                                         block(nil,[NSError errorWithDomain:@"没找到图片" code:404 userInfo:nil]);
                                     }
                                 });
                             }
                         }
                         else
                         {
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 if (block) {
                                     block(nil,[NSError errorWithDomain:@"没找到图片" code:404 userInfo:nil]);
                                 }
                             });
                         }
                     }
                                     failureBlock:^(NSError *error)
                     {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             if (block) {
                                 block(nil,error);
                             }
                         });
                     }];
                }
                
            } failureBlock:^(NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (block) {
                        block(nil,error);
                    }
                });
            }];
        });
    }
}



#pragma mark - about video -
- (void)presentTakeVideoViewController:(IPAssetManager *)manager{
    IPTakeVideoViewController *takeVideo = [[IPTakeVideoViewController alloc]init];
    takeVideo.delegate = self;
    [self presentViewController:takeVideo animated:YES completion:nil];
}

- (void)VisionDidCaptureFinish:(IPVision *)vision withThumbnail:(NSURL *)thumbnail withVideoDuration:(float)duration{
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:thumbnail]];
    
    __weak typeof(self) weakSelf = self;
    [vision exportVideo:^(BOOL success,NSURL *url){
        
        if (success) {
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(imgPicker:didFinishCaptureVideoItem:Videourl:videoDuration:thumbailImage:)]) {
                [weakSelf.delegate imgPicker:weakSelf didFinishCaptureVideoItem:nil Videourl:url videoDuration:duration thumbailImage:image];
            }
        }
        else{
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(imgPicker:didFinishCaptureVideoItem:Videourl:videoDuration:thumbailImage:)]) {
                [weakSelf.delegate imgPicker:weakSelf didFinishCaptureVideoItem:nil Videourl:nil videoDuration:duration thumbailImage:image];
            }
        }
        [weakSelf popViewControllerCustomAnimation];
        
        //        [weakSelf exitIPickerWithAnimation:YES];
        
    }withProgress:^(float progress){
        
    }];
    
}
- (void)popViewControllerCustomAnimation {
    if (self.navViewControllers != 0 && self.navViewControllers < self.navigationController.viewControllers.count) {
        UIViewController *ctrl = self.navigationController.viewControllers[self.navViewControllers];
        CATransition * transition=[CATransition animation];
        transition.duration=0.3f;
        transition.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        transition.type=kCATransitionReveal;
        transition.subtype = kCATransitionFromBottom;
        [self.navigationController.view.layer addAnimation:transition forKey:@""];
        [self.navigationController popToViewController:ctrl animated:NO];
        return;
    }
}
#pragma mark 3DTouch
- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location{
    UICollectionViewCell *cell = (UICollectionViewCell *)previewingContext.sourceView;
    
    NSIndexPath *path = [self.mainView indexPathForCell:cell];
    IPAssetModel *model = self.curImageModelArr[path.item];
    
//    IP3DTouchPreviewVC *reader = [IP3DTouchPreviewVC previewViewControllerWithModel:model];
    IPImageReaderViewController *reader = [IPImageReaderViewController imageReaderViewControllerWithData:self.curImageModelArr TargetIndex:path.item];
    

    return reader;
    
}
- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    
    UICollectionViewCell *cell = (UICollectionViewCell *)previewingContext.sourceView;
    
    NSIndexPath *path = [self.mainView indexPathForCell:cell];
//    IPImageReaderViewController *reader = [IPImageReaderViewController imageReaderViewControllerWithData:self.curImageModelArr TargetIndex:path.item];
//    
//    [self showViewController:reader sender:self];
    
    
    [self showViewController:viewControllerToCommit sender:self];
}

@end
