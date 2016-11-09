//
//  TypeTowTableViewCell.h
//  Post
//
//  Created by admin on 2016/11/4.
//  Copyright © 2016年 Post. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TypeTowTableViewCell : UITableViewCell

/**
 信息lable的高度
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageHeight;
/**
 imageView距离消息距离
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewTop;

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
@property (nonatomic , weak) IBOutlet UIView *thumView;
@property (nonatomic , weak) IBOutlet UILabel *lbcommitNum;
@property (nonatomic , weak) IBOutlet UILabel *lbshearNum;
@property (nonatomic , weak) IBOutlet UILabel *lbReadNum;
@property (nonatomic , weak) IBOutlet UIButton *btnThumUP;
@property (nonatomic , weak) IBOutlet UIButton *btnCommit;
@property (nonatomic , weak) IBOutlet UIButton *btnShear;



@end
