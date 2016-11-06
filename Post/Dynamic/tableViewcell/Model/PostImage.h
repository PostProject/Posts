//
//  PostImage.h
//  Post
//
//  Created by 陈世文 on 2016/11/5.
//  Copyright © 2016年 Post. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PostImage : NSObject
@property (nonatomic , copy) NSString *filepath;
@property (nonatomic, assign) int  filetype;
@property (nonatomic, assign) int  postid;
@property (nonatomic , copy) NSString *realpath;


@end
