//
//  WPPrivicyTableViewCell11.m
//  BigRound
//
//  Created by 王海鹏 on 16/11/6.
//  Copyright © 2016年 王鹏. All rights reserved.
//

#import "WPPrivicyTableViewCell11.h"



@implementation HeadView


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        UILabel *lbTxt = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 200, 40)];
        lbTxt.text = @"个人信息";
        lbTxt.textColor = [UIColor colorWithHexString:@"333333"];
        lbTxt.font = FontSize(14);
        [self addSubview:lbTxt];
        
//        UIButton *btnDetail = [UIButton buttonWithType:UIButtonTypeCustom];
//        btnDetail.frame = CGRectMake(0, 0, ScreenWidth, 40);
//        btnDetail.contentEdgeInsets = UIEdgeInsetsMake(0, ScreenWidth/2-30, 0, -ScreenWidth/2+30);
//        [btnDetail setImage:[UIImage imageNamed:@"up"] forState:UIControlStateNormal];
//        [btnDetail setImage:[UIImage imageNamed:@"down"] forState:UIControlStateSelected];
//        [self addSubview:btnDetail];
        
    }
    
    return self;
}


@end


/***************************************************************/

@implementation WPPrivicyTableViewCell11

{
    
    NSInteger userSelectedChannelID;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (WPPrivicyTableViewCell11 *)cellWithTableView:(UITableView *)tableView {
    static NSString *indentifier = @"WPPrivicyTableViewCell11";
    WPPrivicyTableViewCell11 *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (!cell) {
        cell = [[WPPrivicyTableViewCell11 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indentifier];
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    
        userSelectedChannelID = 100;
    
        // ----------------------------第一行
        UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 50)];
        [self.contentView addSubview:view1];
        
        UILabel *lbGK = [[UILabel alloc] initWithFrame:CGRectMake(50, 5, 200, 20)];
        lbGK.text = @"公开";
        lbGK.font = FontSize(14);
        lbGK.textColor = [UIColor colorWithHexString:@"333333"];
        [view1 addSubview:lbGK];
        
        UILabel *lbSY = [[UILabel alloc] initWithFrame:CGRectMake(50, 25, 200, 20)];
        lbSY.text = @"所有人可见";
        lbSY.font = FontSize(12);
        lbSY.textColor = [UIColor colorWithHexString:@"888888"];
        [view1 addSubview:lbSY];
        
        UIButton *button11 = [UIButton buttonWithType:UIButtonTypeCustom];
        button11.frame = CGRectMake(0, 0, ScreenWidth, 50);
        button11.contentEdgeInsets = UIEdgeInsetsMake(0, -ScreenWidth/2+30, 0, ScreenWidth/2-30);
        [button11 setImage:[UIImage imageNamed:@"check_normal"] forState:UIControlStateNormal];
        [button11 setImage:[UIImage imageNamed:@"check_select"] forState:UIControlStateSelected];
        [view1 addSubview:button11];
        button11.tag = 100;
        button11.selected = YES;
        [button11 addTarget:self action:@selector(infoPrivicyAction:) forControlEvents:UIControlEventTouchUpInside];
        
        // ----------------------------第二行
        UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(0, 51, ScreenWidth, 50)];
        [self.contentView addSubview:view2];
        
        UILabel *lbSM = [[UILabel alloc] initWithFrame:CGRectMake(50, 5, 200, 20)];
        lbSM.text = @"私密";
        lbSM.font = FontSize(14);
        lbSM.textColor = [UIColor colorWithHexString:@"333333"];
        [view2 addSubview:lbSM];
        
        UILabel *lbHY = [[UILabel alloc] initWithFrame:CGRectMake(50, 25, 200, 20)];
        lbHY.text = @"仅好友可见";
        lbHY.font = FontSize(12);
        lbHY.textColor = [UIColor colorWithHexString:@"888888"];
        [view2 addSubview:lbHY];
        
        UIButton *button22 = [UIButton buttonWithType:UIButtonTypeCustom];
        button22.frame = CGRectMake(0, 0, ScreenWidth, 50);
        button22.centerY = 25;
        button22.contentEdgeInsets = UIEdgeInsetsMake(0, -ScreenWidth/2+30, 0, ScreenWidth/2-30);
        [button22 setImage:[UIImage imageNamed:@"check_normal"] forState:UIControlStateNormal];
        [button22 setImage:[UIImage imageNamed:@"check_select"] forState:UIControlStateSelected];
        [view2 addSubview:button22];
        button22.tag = 200;
        [button22 addTarget:self action:@selector(infoPrivicyAction:) forControlEvents:UIControlEventTouchUpInside];
        
        // -----------------------------第三行
        
        UIView *view3 = [[UIView alloc] initWithFrame:CGRectMake(0, 101, ScreenWidth, 50)];
        [self.contentView addSubview:view3];
        
        UILabel *lbSM2 = [[UILabel alloc] initWithFrame:CGRectMake(50, 5, 200, 20)];
        lbSM2.text = @"私密";
        lbSM2.font = FontSize(14);
        lbSM2.textColor = [UIColor colorWithHexString:@"333333"];
        [view3 addSubview:lbSM2];
        
        UILabel *lbHY2 = [[UILabel alloc] initWithFrame:CGRectMake(50, 25, 200, 20)];
        lbHY2.text = @"仅好友及关联好友可见";
        lbHY2.font = FontSize(12);
        lbHY2.textColor = [UIColor colorWithHexString:@"888888"];
        [view3 addSubview:lbHY2];
        
        UIButton *button33 = [UIButton buttonWithType:UIButtonTypeCustom];
        button33.frame = CGRectMake(0, 0, ScreenWidth, 50);
        button33.centerY = 25;
        button33.contentEdgeInsets = UIEdgeInsetsMake(0, -ScreenWidth/2+30, 0, ScreenWidth/2-30);
        [button33 setImage:[UIImage imageNamed:@"check_normal"] forState:UIControlStateNormal];
        [button33 setImage:[UIImage imageNamed:@"check_select"] forState:UIControlStateSelected];
        [view3 addSubview:button33];
        button33.tag = 300;
        [button33 addTarget:self action:@selector(infoPrivicyAction:) forControlEvents:UIControlEventTouchUpInside];

        
        // 分割线
        UILabel *line1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 49.5, ScreenWidth-10, SINGLE_LINE)];
        line1.backgroundColor = [UIColor colorWithHexString:@"e5e5e5"];
        [self.contentView addSubview:line1];
        
        UILabel *line2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 99.5, ScreenWidth-10, SINGLE_LINE)];
        line2.backgroundColor = [UIColor colorWithHexString:@"e5e5e5"];
        [self.contentView addSubview:line2];
        

    }
    return self;
}

#pragma mark -- 选择个人隐私
- (void)infoPrivicyAction:(UIButton *)sender {
    
    //如果更换按钮
    if (sender.tag != userSelectedChannelID) {
        //取之前的按钮
        UIButton *lastButton = (UIButton *)[self viewWithTag:userSelectedChannelID];
        lastButton.selected = NO;
        //赋值按钮ID
        userSelectedChannelID = sender.tag;
    }
    if (!sender.selected) {
        sender.selected = YES;
    }
    
    if (self.infoDelegate && [self.infoDelegate respondsToSelector:@selector(checkPrivicySetting:)]) {
        [self.infoDelegate checkPrivicySetting:userSelectedChannelID];
    }
}

@end
