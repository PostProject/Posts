//
//  WPNoticeTableViewCell.m
//  BigRound
//
//  Created by 王海鹏 on 16/11/6.
//  Copyright © 2016年 王鹏. All rights reserved.
//

#import "WPNoticeTableViewCell.h"


@implementation VoiceHeadView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {

        self.backgroundColor = [UIColor colorWithHexString:@"ebebeb"];
        _lbTxt = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, 30)];
        _lbTxt.font = FontSize(12);
        _lbTxt.textColor = [UIColor colorWithHexString:@"333333"];
        [self addSubview:_lbTxt];
        
        
        _btnClean = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnClean.frame = CGRectMake(ScreenWidth-80, 0, 80, 30);
        _btnClean.titleLabel.font = FontSize(12);
        [_btnClean setTitleColor:[UIColor colorWithHexString:@"333333"] forState:UIControlStateNormal];
        [_btnClean setTitle:@"清空" forState:UIControlStateNormal];
        [_btnClean addTarget:self action:@selector(cleanNoticeAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_btnClean];
        
    }
    return self;
}

// 清空事件
- (void)cleanNoticeAction {
    
    if (self.cleanDelegate && [self.cleanDelegate respondsToSelector:@selector(cleanNotice:)]) {
        [self.cleanDelegate cleanNotice:self.section];
    }
}


@end

/**************************************************************/

@interface WPNoticeTableViewCell ()

@property (nonatomic,strong) UIImageView *ivHeadIcon; // 头像
@property (nonatomic,strong) UILabel *lbDesc; // 描述
@property (nonatomic,strong) UILabel *lbTime; // 时间

@end


@implementation WPNoticeTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


+ (WPNoticeTableViewCell *)cellWithTableView:(UITableView *)tableView {
    static NSString *indentifier = @"WPNoticeTableViewCell";
    WPNoticeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (!cell) {
        cell = [[WPNoticeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indentifier];
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
        
        
        // ----------描述
        _lbDesc = [[UILabel alloc] initWithFrame:CGRectMake(_ivHeadIcon.right+10, 10, ScreenWidth-130, 20)];
        _lbDesc.text = @"小明关注了你";
        _lbDesc.font = FontSize(15);
        _lbDesc.textColor = [UIColor colorWithHexString:@"333333"];
        [self.contentView addSubview:_lbDesc];
        
        // ----------时间
        _lbTime = [[UILabel alloc] initWithFrame:CGRectMake(_ivHeadIcon.right+10, _lbDesc.bottom, ScreenWidth-130, 20)];
        _lbTime.text = @"11：20";
        _lbTime.textColor = [UIColor colorWithHexString:@"888888"];
        _lbTime.font = FontSize(12);
        [self.contentView addSubview:_lbTime];
        
        
    }
 
    return self;
}

@end
