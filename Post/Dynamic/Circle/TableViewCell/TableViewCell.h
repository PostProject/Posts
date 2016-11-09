//
//  TableViewCell.h
//  Post
//
//  Created by admin on 2016/11/9.
//  Copyright © 2016年 Post. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewCell : UITableViewCell
@property (nonatomic , weak) IBOutlet UILabel *lbName;
@property (nonatomic , weak) IBOutlet UILabel *lbCount;
@property (nonatomic , weak) IBOutlet UIImageView *headerImage;
@end
