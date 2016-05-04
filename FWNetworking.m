//
//  FWNetworking.m
//  Networking
//
//  Created by 孔凡伍 on 16/5/3.
//  Copyright © 2016年 kongfanwu. All rights reserved.
//

#import "FWNetworking.h"
NS_ASSUME_NONNULL_BEGIN

NSString * const FWBaseURL = @"http://123.57.6.35:8080/shiguangbiaojv/service/";
NSTimeInterval const FWTimeoutInterval = 60.f;
RequestBodyType const RequestBodyTypeDefault = RequestBodyTypeHTTP;
ResponseDataType const ResponseDataTypeDefault = ResponseDataTypeHTTP;
static NSDictionary * _Nullable HTTPRequestHeadersDic;
static AFNetworkReachabilityManager *networkReachabilityManager;

FOUNDATION_STATIC_INLINE AFHTTPRequestSerializer *requestSerializerRequestBodyType(RequestBodyType requestType)
{
    switch (requestType) {
        case RequestBodyTypeHTTP:
            return AFHTTPRequestSerializer.new;
            break;
        case RequestBodyTypeJSON:
            return AFJSONRequestSerializer.new;
            break;
        case RequestBodyTypePropertyList:
            return AFPropertyListRequestSerializer.new;
            break;
        default:
            return nil;
            break;
    }
}

FOUNDATION_STATIC_INLINE AFHTTPResponseSerializer *responseSerializerResponseDataType(ResponseDataType responseType)
{
    switch (responseType) {
        case ResponseDataTypeHTTP:
            return AFHTTPResponseSerializer.new;
            break;
        case ResponseDataTypeJSON:
            return AFJSONResponseSerializer.new;
            break;
        case ResponseDataTypeXMLParser:
            return AFXMLParserResponseSerializer.new;
            break;
        case ResponseDataTypePropertyList:
            return AFPropertyListResponseSerializer.new;
            break;
        case ResponseDataTypeImage:
            return AFImageResponseSerializer.new;
            break;
        case ResponseDataTypeCompound:
            return AFCompoundResponseSerializer.new;
            break;
        default:
            return nil;
            break;
    }
}

@implementation FWNetworking


+ (void)initialize
{
    if (self == [FWNetworking class]) {
        [self networkReachability];
    }
}

+ (void)networkReachability
{
    networkReachabilityManager = [AFNetworkReachabilityManager managerForDomain:@"http://www.baidu.com"];
    [networkReachabilityManager startMonitoring];
    [networkReachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWiFi:
//                NSLog(@"无线网络");
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
//                NSLog(@"3G网络");
                break;
            case AFNetworkReachabilityStatusNotReachable:
//                NSLog(@"未连接");
                break;
            case AFNetworkReachabilityStatusUnknown:
//                NSLog(@"未知错误");
                break;
        }
    }];
}

+ (void)HTTPRequestHeadersBlcok:(NSDictionary <NSString *, NSString *> * (^)(void))block
{
    if (block) {
        HTTPRequestHeadersDic = block();
    }
}

+ (AFHTTPSessionManager *)HTTPSessionManagerRequestBodyType:(RequestBodyType)requestType
                                           responseDataType:(ResponseDataType)responseType
                                            timeoutInterval:(NSTimeInterval)timeoutInterval
{
    NSURLSessionConfiguration *URLSessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    URLSessionConfiguration.timeoutIntervalForResource = (timeoutInterval > 0 ? timeoutInterval : FWTimeoutInterval);
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:FWBaseURL] sessionConfiguration:URLSessionConfiguration];
    manager.requestSerializer = requestSerializerRequestBodyType(requestType);
    manager.responseSerializer = responseSerializerResponseDataType(responseType);
    
    // 设置请求头
    [HTTPRequestHeadersDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [manager.requestSerializer setValue:obj forHTTPHeaderField:key];
    }];
    return manager;
}

#pragma mark - public

+ (NSMutableDictionary *)requestDictionary
{
    return [NSMutableDictionary dictionaryWithCapacity:1];
}

+ (NSURLSessionDataTask *)dataTaskWithURL:(NSString *)url
                               parameters:(NSDictionary *)parameters
                                 timeoutInterval:(NSTimeInterval)timeoutInterval
                                 requestBodyType:(RequestBodyType)requestType
                                responseDataType:(ResponseDataType)responseType
                                      method:(NSString *)method
                                 constructingBodyWithBlock:(nullable void (^)(id <AFMultipartFormData> formData))block
                                 progress:(nullable void (^)(NSProgress * _Nullable))progress
                                   completeBlock:(CompleteBlock)complete
{
    
    
    // 2 打印信息
    CompleteBlock completeTransform = ^(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject, BOOL success) {
#ifdef DEBUG
        char * _Nullable response;
        if ([responseObject isKindOfClass:[NSError class]]) {
            response = (char *)[[responseObject description] UTF8String];
        } else {
            response = (char *)[[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] UTF8String];
        }
        
        NSString *paramString = [[NSString alloc] initWithData:task.originalRequest.HTTPBody encoding:NSUTF8StringEncoding];
        NSString *requestURL = [NSString stringWithFormat:@"%@ %@/%@", task.originalRequest.HTTPMethod, [task.originalRequest.URL absoluteString], paramString];
        printf("--- BEGIN --- \n%s\n\n%s\n---- END ----\n\n", [requestURL UTF8String], response);
#endif
        // 1 检查网络
        if (!networkReachabilityManager.isReachable && !success) {
            if (complete) complete(nil, [NSError errorWithDomain:url code:NetworkingErrorCodeReachable userInfo:@{@"describe" : @"无网络"}], NO);
        } else {
            if (complete) complete(task, responseObject, success);
        }
    };
    
    // 3 创建AFHTTPSessionManager并设置请求头
    AFHTTPSessionManager *manager = [self HTTPSessionManagerRequestBodyType:requestType responseDataType:responseType timeoutInterval:timeoutInterval];

    // 4 判断请求方式
    NSURLSessionDataTask *dataTask;
    if ([method isEqualToString:@"get"] || [method isEqualToString:@"GET"]) {
        dataTask = [manager GET:url parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
            if (progress) progress(downloadProgress);
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (completeTransform) completeTransform(task, responseObject, YES);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (completeTransform) completeTransform(task, error, NO);
        }];
    }
    else if ([method isEqualToString:@"post"] || [method isEqualToString:@"POST"]) {
        dataTask = [manager POST:url parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
            if (progress) progress(downloadProgress);
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (completeTransform) completeTransform(task, responseObject, YES);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (completeTransform) completeTransform(task, error, NO);
        }];
    }
    else if ([method isEqualToString:@"upload"] || [method isEqualToString:@"UPLOAD"]) {
        [manager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            if (block) block(formData);
        } progress:^(NSProgress * _Nonnull uploadProgress) {
            if (progress) progress(uploadProgress);
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (completeTransform) completeTransform(task, responseObject, YES);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (completeTransform) completeTransform(task, error, NO);
        }];
    }
    return dataTask;
}

+ (NSURLSessionTask *)GET:(NSString *)URLString parameters:(NSDictionary *)parameters completeBlock:(CompleteBlock)complete
{
    return [self dataTaskWithURL:URLString parameters:parameters timeoutInterval:FWTimeoutInterval requestBodyType:RequestBodyTypeDefault responseDataType:ResponseDataTypeDefault method:@"GET" constructingBodyWithBlock:nil progress:nil completeBlock:complete];
}

+ (NSURLSessionTask *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters completeBlock:(CompleteBlock)complete
{
    return [self dataTaskWithURL:URLString parameters:parameters timeoutInterval:FWTimeoutInterval requestBodyType:RequestBodyTypeDefault responseDataType:ResponseDataTypeDefault method:@"POST" constructingBodyWithBlock:nil progress:nil completeBlock:complete];
}

+ (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(id)parameters
     constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                      progress:(nullable void (^)(NSProgress * _Nonnull))uploadProgress
                 completeBlock:(CompleteBlock)complete

{
    return [self dataTaskWithURL:URLString parameters:parameters timeoutInterval:FWTimeoutInterval requestBodyType:RequestBodyTypeDefault responseDataType:ResponseDataTypeDefault method:@"UPLOAD" constructingBodyWithBlock:block progress:uploadProgress completeBlock:complete];
}

+ (NSURLSessionTask *)download:(NSString *)URLString
                    parameters:(NSDictionary *)parameters
                      progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress
                 completeBlock:(CompleteBlock)complete
{
    return [self dataTaskWithURL:URLString parameters:parameters timeoutInterval:FWTimeoutInterval requestBodyType:RequestBodyTypeDefault responseDataType:ResponseDataTypeDefault method:@"GET" constructingBodyWithBlock:nil progress:downloadProgress completeBlock:complete];
}

@end

NS_ASSUME_NONNULL_END
