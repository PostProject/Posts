//
//  GoodsFriendTableViewCell.h
//  BigRound
//
//  Created by 王海鹏 on 16/10/13.
//  Copyright © 2016年 王海鹏. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FriendHeadView : UIView

@property (nonatomic,strong) UILabel *lbTxt; // 头部索引

@end


/*********************************************************/

@interface GoodsFriendTableViewCell : UITableViewCell

+ (GoodsFriendTableViewCell *)cellWithTableView:(UITableView *)tableView;

@end


/**********************************************************/

@interface GoodsFriendTableViewCell22 : UITableViewCell

+ (GoodsFriendTableViewCell22 *)cellWithTableView:(UITableView *)tableView;

@end
