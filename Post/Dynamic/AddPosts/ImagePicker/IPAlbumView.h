//
//  IPAlbumView.h
//  IPickerDemo
//
//  Created by Wangjianlong on 16/2/27.
//  Copyright © 2016年 JL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IPAlbumView;
@protocol IPAlbumViewDelegate<NSObject>

- (void)shouldRemoveFrom:(IPAlbumView *)view;

- (void)clickCellForIndex:(NSIndexPath *)indexPath ForView:(IPAlbumView *)View;
@end


@interface IPAlbumView : UIView

/**代理*/
@property (nonatomic, weak)id <IPAlbumViewDelegate> delegate;

+ (instancetype)albumViewWithData:(NSArray *)data;


@end
