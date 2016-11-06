//
//  IPImageCell.m
//  IPickerDemo
//
//  Created by Wangjianlong on 16/2/27.
//  Copyright © 2016年 JL. All rights reserved.
//

#import "IPImageCell.h"
#import "IPAssetModel.h"
#import "IPAssetManager.h"
#import "IPickerViewController.h"

@interface IPickerViewController ()
- (void)getThumibImageWithAsset:(IPAssetModel *)imageModel photoWidth:(CGSize)photoSize completion:(void (^)(UIImage *photo,NSDictionary *info))completion;

@end

@interface IPImageCell ()
/**缩略图*/
@property (nonatomic, weak) UIImageView *imgView;
/**右上角按钮*/
@property (nonatomic, weak) UIButton *rightCornerBtn;


/**背景*/
@property (nonatomic, strong)UIImageView *bottomBackView;
/**时间label*/
@property (nonatomic, strong)UILabel *timeLabel;
/**video*/
@property (nonatomic, strong)UIImageView *videoImgView;

/**拍照--拍视频*/
@property (nonatomic, strong)UIImageView *actionImageView;
@end

@implementation IPImageCell
- (void)prepareForReuse{
    self.imgView.image = nil;
    self.actionImageView.hidden = YES;
    self.videoImgView.hidden = YES;
    self.bottomBackView.hidden = YES;
    self.timeLabel.hidden = YES;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self creatSubViews];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self creatSubViews];
    }
    return self;
}
- (void)endDisplay{
    if (self.model.assetType != IPAssetModelMediaTypePhoto) {
        self.bottomBackView.hidden = YES;
        self.timeLabel.hidden = YES;
        self.videoImgView.hidden = YES;
        self.actionImageView.hidden = YES;
    }
}
- (void)creatSubViews{
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:self.bounds];
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    imgView.clipsToBounds = YES;
    [self.contentView addSubview:imgView];
    imgView.image = [UIImage imageNamed:@"default_8_120"];
    self.imgView = imgView;
    
    UIButton *rightCornerBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.bounds.size.width - 18-5, 5, 18, 18)];
   
    [rightCornerBtn addTarget:self action:@selector(clickBtnInCell:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:rightCornerBtn];
    self.rightCornerBtn = rightCornerBtn;
    

    
}
- (UIImageView *)bottomBackView{
    if (_bottomBackView == nil) {
        _bottomBackView = [[UIImageView alloc]init];
        _bottomBackView.hidden = YES;
        [_bottomBackView setImage:[UIImage imageNamed:@"photobrowse_bottom"]];
        [self.contentView addSubview:_bottomBackView];
    }
    return _bottomBackView;
}
- (UILabel *)timeLabel{
    if (_timeLabel == nil) {
       
        _timeLabel = [[UILabel alloc]init];
        _timeLabel.hidden = YES;
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.font = [UIFont systemFontOfSize:12];
        [self.bottomBackView addSubview:_timeLabel];
    }
    return _timeLabel;
}
- (UIImageView *)videoImgView{
    if (_videoImgView == nil) {
        
        _videoImgView = [[UIImageView alloc]init];
        _videoImgView.hidden  = YES;
        _videoImgView.contentMode = UIViewContentModeCenter;
        _videoImgView.image = [UIImage imageNamed:@"icon_video"];
        [self.bottomBackView addSubview:_videoImgView];
    }
    return _videoImgView;
}
- (UIImageView *)actionImageView{
    if (_actionImageView == nil) {
        _actionImageView = [[UIImageView alloc]initWithFrame:self.bounds];
        _actionImageView.contentMode = UIViewContentModeCenter;
        _actionImageView.hidden = YES;
        [self.contentView addSubview:_actionImageView];
    }
    return _actionImageView;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    UIImage *image,*image_p;
    if ([UIScreen mainScreen].bounds.size.width<375) {
        
        image =[UIImage imageNamed:@"album_icon_check.png"];
        image_p =[UIImage imageNamed:@"album_icon_check_p.png"];
    }else {
        image =[UIImage imageNamed:@"img_icon_check_Big.png"];
        image_p =[UIImage imageNamed:@"img_icon_check_Big_p.png"];
    }
    [self.rightCornerBtn setImage:image forState:UIControlStateNormal];
    [self.rightCornerBtn setImage:image_p forState:UIControlStateSelected];
    
    self.imgView.frame = self.bounds;
    CGFloat w = self.bounds.size.width / 2.6f;
    self.rightCornerBtn.frame = CGRectMake(self.bounds.size.width - w, 0, w, w);
    
    [self.bottomBackView setFrame:CGRectMake(0, self.bounds.size.height - 20, self.bounds.size.width, 20)];
    self.videoImgView.frame = CGRectMake(10, 0, 24, 20);
    self.timeLabel.frame = CGRectMake(40, 0, self.bounds.size.width - 40, 20);
}
- (void)setModel:(IPAssetModel *)model{
    _model = model;
    __weak typeof(self) weakSelf = self;
    
    if (_model.assetType == IPAssetModelMediaTypeVideo ) {
        [self.ipVc getThumibImageWithAsset:_model photoWidth:self.bounds.size completion:^(UIImage *photo, NSDictionary *info) {
            weakSelf.imgView.image = photo;
        }];
        self.bottomBackView.hidden = NO;
        self.timeLabel.hidden = NO;
        self.videoImgView.hidden = NO;
        self.timeLabel.text = _model.videoDuration;
        self.rightCornerBtn.hidden = YES;
    }else if ( _model.assetType ==IPAssetModelMediaTypeTakeVideo){
        self.actionImageView.image = [UIImage imageNamed:@"icon_video_big"];
        self.actionImageView.hidden = NO;
        
        self.backgroundColor = [UIColor colorWithRed:0.7 green:0.1 blue:0.7 alpha:0.6];
        
        self.rightCornerBtn.hidden = YES;
    }
    else if ( _model.assetType ==IPAssetModelMediaTypeTakePhoto){
        self.actionImageView.image = [UIImage imageNamed:@"photo"];
        self.actionImageView.hidden = NO;
        self.backgroundColor = [UIColor colorWithRed:0.7 green:0.1 blue:0.7 alpha:0.6];
        
        self.rightCornerBtn.hidden = YES;
    }else {
        
        self.rightCornerBtn.selected = model.isSelect;
        [self.ipVc getThumibImageWithAsset:_model photoWidth:self.bounds.size completion:^(UIImage *photo, NSDictionary *info) {
            weakSelf.imgView.image = photo;
        }];
    }
}
- (void)clickBtnInCell:(UIButton *)btn{
    
    btn.selected = !btn.selected;
    self.model.isSelect = btn.selected;
    
    BOOL denySelect;
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickRightCornerBtnForView:)]) {
        denySelect = [self.delegate clickRightCornerBtnForView:self.model];
    }
    if (!denySelect) {
        btn.selected = NO;
        self.model.isSelect = NO;
    }
    
    
}
@end
