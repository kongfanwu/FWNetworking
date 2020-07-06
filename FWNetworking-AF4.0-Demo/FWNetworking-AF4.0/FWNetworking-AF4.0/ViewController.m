//
//  ViewController.m
//  FWNetworking-AF4.0
//
//  Created by kfw on 2020/7/6.
//  Copyright © 2020 神灯智能. All rights reserved.
//

#import "ViewController.h"
#import "FWNetworking.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        NSMutableDictionary *param = [FWNetworking requestDictionary];
        param[@"mobile"] = @"15201005728";
        param[@"pwd"] = @"123456";
        param[@"verifyCode"] = @"12345";
    
        [FWNetworking HTTPRequestHeadersBlcok:^NSDictionary<NSString *,NSString *> * _Nonnull{
            return @{@"key" : @"kong", @"key2" : @"12"};
        }];
    
        [FWNetworking POST:@"/" parameters:param completeBlock:^(NSURLSessionDataTask *task, id  _Nullable responseObject, BOOL success) {
            if (!success) {
                NSLog(@"error %@", responseObject);
                if (((NSError *)responseObject).code == NetworkingErrorCodeReachable) {
                    NSLog(@"无网络");
                }
                return;
            }
            NSLog(@"%@", task.response.URL);
            NSLog(@"%@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        }];
    
    
//    [FWNetworking POST:nil parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
//
//    } progress:^(NSProgress * _Nonnull pro) {
//
//    } completeBlock:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject, BOOL success) {
//
//    }];
}


@end
