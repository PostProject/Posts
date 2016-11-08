//
//  WPPrivicyTableViewCell11.h
//  BigRound
//
//  Created by 王海鹏 on 16/11/6.
//  Copyright © 2016年 王鹏. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeadView : UIView



@end



/******************************************************/


@protocol PrivicyDelegate <NSObject>

- (void)checkPrivicySetting:(NSInteger)index;

@end


@interface WPPrivicyTableViewCell11 : UITableViewCell

@property (nonatomic,weak) id <PrivicyDelegate> infoDelegate;

+ (WPPrivicyTableViewCell11 *)cellWithTableView:(UITableView *)tableView;


@end
