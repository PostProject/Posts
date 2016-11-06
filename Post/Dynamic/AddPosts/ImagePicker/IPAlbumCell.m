//
//  IPAblumCell.m
//  IPickerDemo
//
//  Created by Wangjianlong on 16/2/27.
//  Copyright © 2016年 JL. All rights reserved.
//

#import "IPAlbumCell.h"
#import "IPAlbumModel.h"

@interface IPAlbumCell ()
/**封面view*/
@property (nonatomic, weak)UIImageView *posterView;
/**描述*/
@property (nonatomic, weak)UILabel *descLabel;
/**是否选中图片*/
@property (nonatomic, weak)UIImageView *accessoryImgView;


/**是否选中图片*/
@property (nonatomic, weak)UIView  *spliteline;
/**当前状态*/
//@property (nonatomic, assign)BOOL ;
@end

@implementation IPAlbumCell
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
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self creatSubViews];
    }
    return self;
}
- (void)creatSubViews{
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIView  *spliteline = [[UIView alloc]init];
    spliteline.backgroundColor = [UIColor lightGrayColor];
    self.spliteline = spliteline;
    [self.contentView addSubview:spliteline];
    
    UIImageView *post = [[UIImageView alloc]init];
    post.clipsToBounds = YES;
    post.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:post];
    self.posterView = post;
    
    UILabel *descLabel = [[UILabel alloc]init];
    descLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [self.contentView addSubview:descLabel];
    self.descLabel = descLabel;
    
    UIImageView *selectedImgView = [[UIImageView alloc]init];
    selectedImgView.contentMode = UIViewContentModeCenter;
    selectedImgView.image = [UIImage imageNamed:@"forms_icon_select2"];
   
    [self.contentView addSubview:selectedImgView];
    self.accessoryImgView = selectedImgView;
    
}
- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat viewW = self.bounds.size.width;
    CGFloat viewH = self.bounds.size.height;
    CGFloat MaxMargin = 10.0f;
    
    self.spliteline.frame = CGRectMake(0, 0, viewW, 0.5);
    self.posterView.frame = CGRectMake(0, 0, viewH, viewH);
    self.descLabel.frame = CGRectMake(viewH + MaxMargin, 0, viewW - viewH - 2*MaxMargin - 20, viewH);
    self.accessoryImgView.frame = CGRectMake(viewW - MaxMargin - 20, 0, 20, viewH);

    
}
- (void)setModel:(IPAlbumModel *)model{
    if (_model != model) {
        _model = model;
        self.posterView.image = model.posterImage;
        
        self.descLabel.text = [NSString stringWithFormat:@"%@ (%ld)",model.albumName, (long)model.imageCount];
        if (_model.isSelected) {
            self.descLabel.textColor = [UIColor blueColor];
            
        }else {
            
            self.descLabel.textColor = [UIColor grayColor];
        }
        self.accessoryImgView.hidden = !_model.isSelected;
    }
    
}

@end
