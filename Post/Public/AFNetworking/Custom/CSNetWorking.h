//
//  CSNetWorking.h
//  AFNetWorking
//
//  Created by admin on 2016/12/1.
//  Copyright © 2016年 Rcfans. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSNetWorking : NSObject

+(void)GET:(NSString *)url adParams:(NSDictionary *)params adSuccecBlock:(void (^)(id responseObject))success adFaluerBlock:(void (^)(NSError *error))failuer;
@end
