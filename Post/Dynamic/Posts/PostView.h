//
//  PostView.h
//  Post
//
//  Created by admin on 2016/11/9.
//  Copyright © 2016年 Post. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PostViewDelegate <NSObject>

-(void)postViewCommentActionDelegate;

@end


@interface PostView : UIView
@property (nonatomic , strong) UITableView *dynamicTable;
@property (nonatomic, assign) id <PostViewDelegate> delegate;
@end
