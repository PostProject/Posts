//
//  IPZoomScrollView.h
//  IPickerDemo
//
//  Created by Wangjianlong on 16/2/29.
//  Copyright © 2016年 JL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IPAssetModel,IPickerViewController;

@interface IPZoomScrollView : UIScrollView

/**核心*/
@property (nonatomic, weak)IPickerViewController *ipVc;

@property (nonatomic) IPAssetModel * imageModel;

- (void)prepareForReuse;

- (void)displayImage;
//- (void)displayImageWithFullScreenImage:(UIImage *)img;
- (void)displayImageWithFullScreenImage;
@end
