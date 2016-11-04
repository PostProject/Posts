//
//  TypeOneTableViewCell.h
//  Post
//
//  Created by admin on 2016/11/4.
//  Copyright © 2016年 Post. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostsView.h"
//@class PostsView;

@interface TypeOneTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIScrollView *hotScrollView;
@property (nonatomic, weak) IBOutlet PostsView *postsView;


@end
