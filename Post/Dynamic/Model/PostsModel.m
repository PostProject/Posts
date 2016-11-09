//
//  PostsModel.m
//  Post
//
//  Created by admin on 2016/11/4.
//  Copyright © 2016年 Post. All rights reserved.
//

#import "PostsModel.h"

@implementation PostsModel
-(instancetype)init{
    self =  [super init];
    if (self) {
        self.postImageArray = [[NSMutableArray alloc] init];
    }
    
    return self;
}

@end
