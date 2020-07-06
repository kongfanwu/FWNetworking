//
//  FWNetworking.h
//  Networking
//
//  Created by 孔凡伍 on 16/5/3.
//  Copyright © 2016年 kongfanwu. All rights reserved.
//



#import <Foundation/Foundation.h>
#import <AFNetworking.h>

typedef NS_ENUM(NSInteger,RequestBodyType) {
    RequestBodyTypeHTTP = 0,
    RequestBodyTypeJSON,
    RequestBodyTypePropertyList,
};

typedef NS_ENUM(NSInteger,ResponseDataType) {
    ResponseDataTypeHTTP = 0,
    ResponseDataTypeJSON,
    ResponseDataTypeXMLParser,
    ResponseDataTypePropertyList,
    ResponseDataTypeImage,
    ResponseDataTypeCompound,
};

typedef NS_ENUM(NSInteger, NetworkingErrorCode) {
    NetworkingErrorCodeReachable = 10000, // 无网络
};

/** base url */
FOUNDATION_EXTERN NSString * const _Nonnull FWBaseURL;
/** 超时时间 */
FOUNDATION_EXTERN NSTimeInterval const FWTimeoutInterval;
/** 默认请求类型 */
FOUNDATION_EXTERN RequestBodyType const RequestBodyTypeDefault;
/** 默认数据解析类型 */
FOUNDATION_EXTERN ResponseDataType const ResponseDataTypeDefault;

/** 回调block */
typedef void(^CompleteBlock)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject, BOOL success);

NS_ASSUME_NONNULL_BEGIN

@interface FWNetworking : NSObject

/**
 *  设置请求头。
 *
 *  @param block 回调block，返回key value为NSStrign类型的NSDictionary
 *
 *  @return 返回请求头字典
 */
+ (void)HTTPRequestHeadersBlcok:(NSDictionary <NSString *, NSString *> * (^)(void))block;

/**
 *  作为请求数据字典
 */
+ (NSMutableDictionary *)requestDictionary;

+ (NSURLSessionDataTask *)dataTaskWithURL:(NSString *)url
                               parameters:(NSDictionary *)parameters
                          timeoutInterval:(NSTimeInterval)timeoutInterval
                          requestBodyType:(RequestBodyType)requestType
                         responseDataType:(ResponseDataType)responseType
                                   method:(NSString *)method
                constructingBodyWithBlock:(nullable void (^)(id <AFMultipartFormData> formData))block
                                 progress:(nullable void (^)(NSProgress * _Nullable))progress
                            completeBlock:(CompleteBlock)complete;

+ (NSURLSessionTask *)GET:(NSString *)url parameters:(NSDictionary *)parameters completeBlock:(CompleteBlock)complete;

+ (NSURLSessionTask *)POST:(NSString *)url parameters:(NSDictionary *)parameters completeBlock:(CompleteBlock)complete;

+ (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(id)parameters
     constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                      progress:(nullable void (^)(NSProgress * _Nonnull))uploadProgress
                 completeBlock:(CompleteBlock)complete;

+ (NSURLSessionTask *)download:(NSString *)URLString
                    parameters:(NSDictionary *)parameters
                      progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress
                 completeBlock:(CompleteBlock)complete;

@end

NS_ASSUME_NONNULL_END
