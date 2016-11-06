//
//  IPAblumCell.h
//  IPickerDemo
//
//  Created by Wangjianlong on 16/2/27.
//  Copyright © 2016年 JL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IPAlbumModel;

@interface IPAlbumCell : UITableViewCell
/**数据对象*/
@property (nonatomic, strong)IPAlbumModel *model;
@end
