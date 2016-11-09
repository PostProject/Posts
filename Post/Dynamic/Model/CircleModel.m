//
//  CircleModel.m
//  Post
//
//  Created by admin on 2016/11/9.
//  Copyright © 2016年 Post. All rights reserved.
//

#import "CircleModel.h"

@implementation CircleModel
-(instancetype)init{
    self = [super init];
    if (self) {
        self.joinCircleArray = [[NSMutableArray alloc] init];
        self.myCircleArray = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
