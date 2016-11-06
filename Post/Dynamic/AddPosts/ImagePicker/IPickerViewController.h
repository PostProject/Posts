//
//  IPickerViewController.h
//  ImagePickerDemo
//
//  Created by Wangjianlong on 16/2/27.
//  Copyright © 2016年 JL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IPAssetModel.h"


/**弹出样式*/
typedef NS_ENUM(NSUInteger,  IPickerViewControllerPopStyle) {
    /**由上到下*/
    IPickerViewControllerPopStylePresent,
    /**由左到右*/
    IPickerViewControllerPopStylePush
};
/**展示样式*/
typedef NS_ENUM(NSUInteger,  IPickerViewControllerDisplayStyle) {
    /**展示相册*/
    IPickerViewControllerDisplayStyleImage,
    /**展示视频*/
    IPickerViewControllerDisplayStyleVideo
};


typedef void(^RequestImageBlock)(UIImage *image,NSError *error);

@class IPickerViewController;
@protocol IPickerViewControllerDelegate <NSObject>
/**
 *  选择图片完成后的回调方法
 *
 *  @param datas 图片URL数组
 */
- (void)didClickCompleteBtn:(NSArray<NSURL *> *)datas;

/**
 *  拍摄视频完成后,的回调方法
 *
 *  @param videoInfo     视频的相关信息
 *  @option videourl:NSURL  videoduration:NSNumber videothumbail:UIImage
 *
 *
 *  @param progressBlock 导出的进度
 */
- (void)imgPicker:(IPickerViewController *)ipVc didFinishCaptureVideoItem:(AVPlayerItem *)playerItem Videourl:(NSURL *)videoUrl videoDuration:(float)duration thumbailImage:(UIImage *)thumbail;

@end

@interface IPickerViewController : UIViewController

/**
 *  弹出样式
 */
@property (nonatomic, assign)IPickerViewControllerPopStyle popStyle;


/**
 *  最大可选择的图片数量
 *  Note:请传入 "> 0" 的数
 */
@property (nonatomic, assign)NSUInteger maxCount;


/**代理*/
@property (nonatomic, weak)id<IPickerViewControllerDelegate> delegate;

/*!
 @property
 @abstract 跳入此页面的层级
 */
@property (nonatomic, assign) NSInteger navViewControllers;

/**
 *  创建对象
 *
 *  @param style 样式
 *
 *  @return 实例
 */
+ (instancetype)instanceWithDisplayStyle:(IPickerViewControllerDisplayStyle)style;

/**
 *  通过url获取全屏高清图片
 *
 *  @param url   图片资源的唯一标识
 */
+ (void)getImageWithImageURL:(NSURL *)imageUrl RequestBlock:(RequestImageBlock)block;
/**
 *  通过url获取等比缩略图
 *
 *  @param imageUrl 图片url
 *  @param width    图片宽度
 *  @param block    回调
 */
+ (void)getAspectThumbailImageWithImageURL:(NSURL *)imageUrl Width:(CGFloat)width RequestBlock:(RequestImageBlock)block;
/**
 *  通过url获取缩略图
 *
 *  @param imageUrl 图片url
 *  @param block    回调
 */
+ (void)getThumbailImageWithImageURL:(NSURL *)imageUrl RequestBlock:(RequestImageBlock)block;

/**
 *  此方法会根据animation的属性,做清除数据的处理
 *
 *  @param animation YES: 销毁控制器 NO:仅仅清除控制器数据
 */
- (void)exitIPickerWithAnimation:(BOOL)animation;

@end
