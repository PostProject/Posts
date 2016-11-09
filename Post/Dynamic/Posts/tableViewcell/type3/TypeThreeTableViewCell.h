//
//  TypeThreeTableViewCell.h
//  Post
//
//  Created by admin on 2016/11/4.
//  Copyright © 2016年 Post. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TypeThreeTableViewCell : UITableViewCell

/**
 信息lable的高度
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageHeight;
/**
 imageView距离消息距离 若没有展开按钮，需要将两个同时赋值为0即可
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewTop1;

/**
 展开按钮高度
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnOtherHeight;

@property (nonatomic , weak) IBOutlet UILabel *lbThumUPNames;
@property (nonatomic , weak) IBOutlet UIImageView *headImage;
@property (nonatomic , weak) IBOutlet UILabel *lbName;
@property (nonatomic , weak) IBOutlet UILabel *lbTime;
@property (nonatomic , weak) IBOutlet UILabel *lbMessage;
@property (nonatomic , weak) IBOutlet UIButton *btnAddFriends;
@property (nonatomic , weak) IBOutlet UIButton *btnExpand;
@property (nonatomic , weak) IBOutlet UIImageView *pictureImage;
@property (nonatomic , weak) IBOutlet UIImageView *pictureImage1;
@property (nonatomic , weak) IBOutlet UIImageView *pictureImage2;
@property (nonatomic , weak) IBOutlet UIImageView *pictureImage3;
@property (nonatomic , weak) IBOutlet UIImageView *pictureImage4;
@property (nonatomic , weak) IBOutlet UIImageView *pictureImage5;
@property (nonatomic , weak) IBOutlet UIView *thumView;
@property (nonatomic , weak) IBOutlet UILabel *lbcommitNum;
@property (nonatomic , weak) IBOutlet UILabel *lbshearNum;
@property (nonatomic , weak) IBOutlet UILabel *lbReadNum;
@property (nonatomic , weak) IBOutlet UIButton *btnThumUP;
@property (nonatomic , weak) IBOutlet UIButton *btnCommit;
@property (nonatomic , weak) IBOutlet UIButton *btnShear;

@end
