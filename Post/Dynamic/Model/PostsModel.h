//
//  PostsModel.h
//  Post
//
//  Created by admin on 2016/11/4.
//  Copyright © 2016年 Post. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PostsModel : NSObject
//@property (nonatomic, copy) NSString *type;
@property (nonatomic, assign) CGFloat cellHeight;

/**
 消息高度
 */
@property (nonatomic, assign) CGFloat  lbMessageHeight;

@property (nonatomic , copy) NSString *commentnum;
@property (nonatomic , copy) NSString *content;
@property (nonatomic , copy) NSString *createDate;
@property (nonatomic, assign) int  funnum;
@property (nonatomic , copy) NSString *location;
//@property (nonatomic, assign) int  id;
@property (nonatomic, assign) int  ownerid;
@property (nonatomic, assign) int  sharenum;
@property (nonatomic, assign) int  state;
@property (nonatomic, assign) int  type;

/**
 是否是语音
 */
@property (nonatomic, assign) BOOL  isAudo;
@property (nonatomic , strong) NSMutableArray *postImageArray;

/**
 展开按钮是否隐藏
 */
@property (nonatomic, assign) BOOL  isCoverHiden;




@end
