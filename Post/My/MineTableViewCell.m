
//
//  MineTableViewCell.m
//  BigRound
//
//  Created by 王海鹏 on 16/10/12.
//  Copyright © 2016年 王海鹏. All rights reserved.
//

#import "MineTableViewCell.h"

@implementation MyCellInfoModel



@end



/****************************************************/

@interface MineTableViewCell ()

@property (nonatomic,strong) UIImageView *ivIcon;
@property (nonatomic,strong) UILabel *lbName;

@end

@implementation MineTableViewCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


+ (MineTableViewCell *)cellWithTableView:(UITableView *)tableView {
    static NSString *indentifier = @"MineTableViewCell";
    MineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (!cell) {
        cell = [[MineTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indentifier];
        cell.backgroundColor = [UIColor whiteColor];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {

    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
      
        CGFloat space = 15;
        
        // logo
        _ivIcon = [[UIImageView alloc] initWithFrame:CGRectMake(space, 0, 22, 22)];
        _ivIcon.centerY = 25;
        _ivIcon.image = [UIImage imageNamed:@"myPost"];
        [self.contentView addSubview:_ivIcon];
        
        // 名字
        _lbName = [[UILabel alloc] initWithFrame:CGRectMake(_ivIcon.right+10, 0, 200, 50)];
        _lbName.text = @"我的帖子";
        _lbName.textColor = [UIColor colorWithHexString:@"333333"];
        _lbName.font = FontSize(15);
        [self.contentView addSubview:_lbName];
        
    }
    return self;
}



- (void)setCellModel:(MyCellInfoModel *)cellModel {

    _cellModel = cellModel;
    _ivIcon.image = [UIImage imageNamed:cellModel.cellIcon];
    _lbName.text = cellModel.cellName;
    
}

@end






