//
//  AddCircleTableViewController.m
//  Post
//
//  Created by 陈世文 on 2016/11/13.
//  Copyright © 2016年 Post. All rights reserved.
//

#import "AddCircleTableViewController.h"

@interface AddCircleTableViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    ///邀请成员View的高度
    NSInteger _inviteHeight;
}

@property (weak, nonatomic) IBOutlet UISwitch *switchAction;

/**
 邀请View
 */
@property (weak, nonatomic) IBOutlet UIView *inviteView;

@end

@implementation AddCircleTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
- (IBAction)addCircleCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)inviteFriendsAction:(id)sender {
    MyLog(@"邀请好友");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 1) {
        if (_inviteHeight == 0) {
            return 55;
        }
        return 150;
    }
    return 55;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
