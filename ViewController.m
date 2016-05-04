//
//  ViewController.m
//  Networking
//
//  Created by 孔凡伍 on 16/5/3.
//  Copyright © 2016年 kongfanwu. All rights reserved.
//

#import "ViewController.h"
#import "FWNetworking.h"

@interface ViewController ()



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
 
    
    
//    NSMutableDictionary *param = [FWNetworking requestDictionary];
//    param[@"mobile"] = @"15201005728";
//    param[@"pwd"] = @"123456";
//    param[@"verifyCode"] = @"12345";
//    
//    [FWNetworking HTTPRequestHeadersBlcok:^NSDictionary<NSString *,NSString *> * _Nonnull{
//        return @{@"key" : @"kong", @"key2" : @"12"};
//    }];
//    
//    [FWNetworking POST:@"CustomUser/register.json" parameters:param completeBlock:^(NSURLSessionDataTask *task, id  _Nullable responseObject, BOOL success) {
//        if (!success) {
//            NSLog(@"error %@", responseObject);
//            if (((NSError *)responseObject).code == NetworkingErrorCodeReachable) {
//                NSLog(@"无网络");
//            }
//            return;
//        }
//        NSLog(@"%@", task.response.URL);
//        NSLog(@"%@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
//    }];
  

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end