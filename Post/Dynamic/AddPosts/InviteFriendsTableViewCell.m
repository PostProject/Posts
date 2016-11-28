//
//  InviteFriendsTableViewCell.m
//  Post
//
//  Created by 王海鹏 on 16/11/15.
//  Copyright © 2016年 Post. All rights reserved.
//

#import "InviteFriendsTableViewCell.h"
#import "UIImageView+WebCache.h"

@interface InviteFriendsTableViewCell ()

@property (nonatomic,strong) UIButton *btnCheck; // 选择按钮
@property (nonatomic,strong) UIImageView *ivHeadIcon; // 头像
@property (nonatomic,strong) UILabel *lbNickName; // 昵称
@property (nonatomic,strong) UILabel *lbFriendProfile; // 好友简介


@end

@implementation InviteFriendsTableViewCell



- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


+ (InviteFriendsTableViewCell *)cellWithTableView:(UITableView *)tableView {
    static NSString *indentifier = @"InviteFriendsTableViewCell";
    InviteFriendsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (!cell) {
        cell = [[InviteFriendsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indentifier];
        cell.backgroundColor = [UIColor whiteColor];
        //        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    return cell;
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        CGFloat space = 15;
        
        // 选中按钮
        _btnCheck = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnCheck.frame = CGRectMake(space, 0, 22, 22);
        _btnCheck.centerY = 30;
        [_btnCheck setImage:[UIImage imageNamed:@"check_normal"] forState:UIControlStateNormal];
        [_btnCheck addTarget:self action:@selector(inviteFriends:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_btnCheck];
        
        // ---------头像
        _ivHeadIcon = [[UIImageView alloc] initWithFrame:CGRectMake(_btnCheck.right+space, 10, 40, 40)];
        _ivHeadIcon.image = [UIImage imageNamed:@"headIcon"];
        // 将头像切成圆角
        _ivHeadIcon.layer.cornerRadius = _ivHeadIcon.width/2;
        _ivHeadIcon.layer.masksToBounds = YES;
        _ivHeadIcon.layer.shouldRasterize = YES;
        _ivHeadIcon.layer.rasterizationScale = [UIScreen mainScreen].scale;
        [self.contentView addSubview:_ivHeadIcon];
        
        // ----------名字
        _lbNickName = [[UILabel alloc] initWithFrame:CGRectMake(_ivHeadIcon.right+10, 10, ScreenWidth-170, 20)];
        _lbNickName.text = @"小明";
        _lbNickName.font = FontSize(15);
        _lbNickName.textColor = [UIColor colorWithHexString:@"333333"];
        [self.contentView addSubview:_lbNickName];
        
        // ----------简介
        _lbFriendProfile = [[UILabel alloc] initWithFrame:CGRectMake(_ivHeadIcon.right+10, _lbNickName.bottom, ScreenWidth-170, 20)];
        _lbFriendProfile.text = @"小黄简介小黄简介小黄简介小黄简介小黄简介小黄简介小黄简介小黄简介小黄简介";
        _lbFriendProfile.textColor = [UIColor colorWithHexString:@"888888"];
        _lbFriendProfile.font = FontSize(12);
        [self.contentView addSubview:_lbFriendProfile];
        
    }
    return self;
}


- (void)inviteFriends:(UIButton *)sender {
    if (self.inviteDelegate && [self.inviteDelegate respondsToSelector:@selector(checkFriendsAction:)]) {
        [self.inviteDelegate checkFriendsAction:self.row];
    }
}



- (void)setFriendModel:(GoodsFriendModel *)friendModel {
    _friendModel = friendModel;
    
    // [_ivHeadIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",NetUrl,_friendModel.friendHead]] placeholderImage:@""];

    _lbNickName.text = _friendModel.friendName;
    _lbFriendProfile.text = _friendModel.friendDesc;
    
    if (_friendModel.isCheck) {
        [_btnCheck setImage:[UIImage imageNamed:@"check_select"] forState:UIControlStateNormal];
    }else {
        [_btnCheck setImage:[UIImage imageNamed:@"check_normal"] forState:UIControlStateNormal];
    }
}




@end
