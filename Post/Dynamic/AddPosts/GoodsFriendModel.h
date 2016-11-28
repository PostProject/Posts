//
//  GoodsFriendModel.h
//  Post
//
//  Created by 王海鹏 on 16/11/20.
//  Copyright © 2016年 Post. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GoodsFriendModel : NSObject

@property (nonatomic,assign) BOOL isCheck;
@property (nonatomic,strong) NSString *friendId;
@property (nonatomic,strong) NSString *friendHead;
@property (nonatomic,strong) NSString *friendName;
@property (nonatomic,strong) NSString *friendDesc;

@end
