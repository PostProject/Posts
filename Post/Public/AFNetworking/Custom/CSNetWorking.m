//
//  CSNetWorking.m
//  AFNetWorking
//
//  Created by admin on 2016/12/1.
//  Copyright © 2016年 Rcfans. All rights reserved.
//

#import "CSNetWorking.h"
#import "AFNetworking.h"
@implementation CSNetWorking



+(void)GET:(NSString *)url adParams:(NSDictionary *)params adSuccecBlock:(void (^)(id responseObject))success adFaluerBlock:(void (^)(NSError *error))failuer{
    AFHTTPSessionManager *manager =[AFHTTPSessionManager manager];
    [manager GET:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        // error 错误信息
        failuer(error);
    }];
}
+(void)POST:(NSString *)url adParams:(NSDictionary *)params adSuccecBlock:(void (^)(id responseObject))success adFaluerBlock:(void (^)(NSError *error))failuer{
    AFHTTPSessionManager *manager =[AFHTTPSessionManager manager];
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        // error 错误信息
        failuer(error);
    }];
}
@end
