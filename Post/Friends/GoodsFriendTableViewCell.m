//
//  GoodsFriendTableViewCell.m
//  BigRound
//
//  Created by 王海鹏 on 16/10/13.
//  Copyright © 2016年 王海鹏. All rights reserved.
//

#import "GoodsFriendTableViewCell.h"


@implementation FriendHeadView


- (instancetype)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"ebebeb"];
        _lbTxt = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, ScreenWidth-30, 30)];
        _lbTxt.font = FontSize(12);
        _lbTxt.textColor = [UIColor colorWithHexString:@"333333"];
        [self addSubview:_lbTxt];
        
    }
    return self;
}

@end



/*********************************************************/

@interface GoodsFriendTableViewCell ()

@property (nonatomic,strong) UIImageView *ivHeadIcon; // 头像
@property (nonatomic,strong) UILabel *lbNickName; // 昵称
@property (nonatomic,strong) UILabel *lbFriendProfile; // 好友简介
@property (nonatomic,strong) UIButton *btnAgree; // 同意按钮

@end

@implementation GoodsFriendTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


+ (GoodsFriendTableViewCell *)cellWithTableView:(UITableView *)tableView {
    static NSString *indentifier = @"GoodsFriendTableViewCell";
    GoodsFriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (!cell) {
        cell = [[GoodsFriendTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indentifier];
        cell.backgroundColor = [UIColor whiteColor];
        //        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    return cell;
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        CGFloat space = 15;
        
        // ---------头像
        _ivHeadIcon = [[UIImageView alloc] initWithFrame:CGRectMake(space, 10, 40, 40)];
        _ivHeadIcon.image = [UIImage imageNamed:@"headIcon"];
        // 将头像切成圆角
        _ivHeadIcon.layer.cornerRadius = _ivHeadIcon.width/2;
        _ivHeadIcon.layer.masksToBounds = YES;
        _ivHeadIcon.layer.shouldRasterize = YES;
        _ivHeadIcon.layer.rasterizationScale = [UIScreen mainScreen].scale;
        [self.contentView addSubview:_ivHeadIcon];
        
        
        // ----------名字
        _lbNickName = [[UILabel alloc] initWithFrame:CGRectMake(_ivHeadIcon.right+10, 10, ScreenWidth-130, 20)];
        _lbNickName.text = @"小明";
        _lbNickName.font = FontSize(15);
        _lbNickName.textColor = [UIColor colorWithHexString:@"333333"];
        [self.contentView addSubview:_lbNickName];
        
        // ----------简介
        _lbFriendProfile = [[UILabel alloc] initWithFrame:CGRectMake(_ivHeadIcon.right+10, _lbNickName.bottom, ScreenWidth-130, 20)];
        _lbFriendProfile.text = @"小黄简介小黄简介小黄简介小黄简介小黄简介小黄简介小黄简介小黄简介小黄简介";
        _lbFriendProfile.textColor = [UIColor colorWithHexString:@"888888"];
        _lbFriendProfile.font = FontSize(12);
        [self.contentView addSubview:_lbFriendProfile];
        
        // 同意按钮
        _btnAgree = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnAgree.frame = CGRectMake(0, 0, 40, 22);
        _btnAgree.right  = ScreenWidth-space;
        _btnAgree.centerY = 30;
        [_btnAgree setImage:[UIImage imageNamed:@"agree"] forState:UIControlStateNormal];
        [self.contentView addSubview:_btnAgree];

    }
    return self;
}


@end



/****************************************************************/

@interface GoodsFriendTableViewCell22 ()

@property (nonatomic,strong) UIImageView *ivHeadIcon; // 头像
@property (nonatomic,strong) UILabel *lbNickName; // 昵称
@property (nonatomic,strong) UILabel *lbFriendProfile; // 好友简介

@end


@implementation GoodsFriendTableViewCell22

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


+ (GoodsFriendTableViewCell22 *)cellWithTableView:(UITableView *)tableView {
    static NSString *indentifier = @"GoodsFriendTableViewCell22";
    GoodsFriendTableViewCell22 *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (!cell) {
        cell = [[GoodsFriendTableViewCell22 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indentifier];
        cell.backgroundColor = [UIColor whiteColor];
        //        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    return cell;
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        CGFloat space = 15;
        
        // ---------头像
        _ivHeadIcon = [[UIImageView alloc] initWithFrame:CGRectMake(space, 10, 40, 40)];
        _ivHeadIcon.image = [UIImage imageNamed:@"headIcon"];
        // 将头像切成圆角
        _ivHeadIcon.layer.cornerRadius = _ivHeadIcon.width/2;
        _ivHeadIcon.layer.masksToBounds = YES;
        _ivHeadIcon.layer.shouldRasterize = YES;
        _ivHeadIcon.layer.rasterizationScale = [UIScreen mainScreen].scale;
        [self.contentView addSubview:_ivHeadIcon];
        
        
        // ----------名字
        _lbNickName = [[UILabel alloc] initWithFrame:CGRectMake(_ivHeadIcon.right+10, 10, ScreenWidth-130, 20)];
        _lbNickName.text = @"小明";
        _lbNickName.font = FontSize(15);
        _lbNickName.textColor = [UIColor colorWithHexString:@"333333"];
        [self.contentView addSubview:_lbNickName];
        
        // ----------简介
        _lbFriendProfile = [[UILabel alloc] initWithFrame:CGRectMake(_ivHeadIcon.right+10, _lbNickName.bottom, ScreenWidth-130, 20)];
        _lbFriendProfile.text = @"小黄简介小黄简介小黄简介小黄简介小黄简介小黄简介小黄简介小黄简介小黄简介";
        _lbFriendProfile.textColor = [UIColor colorWithHexString:@"888888"];
        _lbFriendProfile.font = FontSize(12);
        [self.contentView addSubview:_lbFriendProfile];
        
    }
    return self;
}




@end

