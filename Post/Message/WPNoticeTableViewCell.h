//
//  WPNoticeTableViewCell.h
//  BigRound
//
//  Created by 王海鹏 on 16/11/6.
//  Copyright © 2016年 王鹏. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol CleanDelegate <NSObject>

- (void)cleanNotice:(NSInteger)index;

@end

@interface VoiceHeadView : UIView

@property (nonatomic,strong) UILabel *lbTxt; // 头部索引
@property (nonatomic,strong) UIButton *btnClean; // 清空
@property (nonatomic,assign) NSInteger section; //  哪一组
@property (nonatomic,weak) id <CleanDelegate> cleanDelegate;

@end



/*************************************************/

@interface WPNoticeTableViewCell : UITableViewCell

+ (WPNoticeTableViewCell *)cellWithTableView:(UITableView *)tableView;

@end
