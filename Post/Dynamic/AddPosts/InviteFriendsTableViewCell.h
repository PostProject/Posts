//
//  InviteFriendsTableViewCell.h
//  Post
//
//  Created by 王海鹏 on 16/11/15.
//  Copyright © 2016年 Post. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoodsFriendModel.h"

@protocol InviteDelegate <NSObject>

- (void)checkFriendsAction:(NSInteger)index;

@end

@interface InviteFriendsTableViewCell : UITableViewCell

@property (nonatomic,weak) id <InviteDelegate> inviteDelegate;
@property (nonatomic,assign) NSInteger row;


+ (InviteFriendsTableViewCell *)cellWithTableView:(UITableView *)tableView;

@property (nonatomic,strong) GoodsFriendModel *friendModel;

@end
