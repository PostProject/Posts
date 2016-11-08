//
//  MineTableViewCell.h
//  BigRound
//
//  Created by 王海鹏 on 16/10/12.
//  Copyright © 2016年 王海鹏. All rights reserved.
//

//#import "WPBaseTableViewCell.h"


@interface MyCellInfoModel : NSObject

@property (nonatomic,copy) NSString *cellIcon;
@property (nonatomic,copy) NSString *cellName;
@property (nonatomic,strong) id cellClass;

@end


/***************************************************/


@interface MineTableViewCell : UITableViewCell

@property (nonatomic,strong) MyCellInfoModel *cellModel;

+ (MineTableViewCell *)cellWithTableView:(UITableView *)tableView;

@end





