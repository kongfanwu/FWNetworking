//
//  NetworkingTests.m
//  NetworkingTests
//
//  Created by 孔凡伍 on 16/5/3.
//  Copyright © 2016年 kongfanwu. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FWNetworking.h"


@interface NetworkingTests : XCTestCase

@end

@implementation NetworkingTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Request should succeed"];
    
    __block BOOL asuccess;
    
    NSMutableDictionary *param = [FWNetworking requestDictionary];
    param[@"mobile"] = @"15201005728";
    param[@"pwd"] = @"123456";
    param[@"verifyCode"] = @"12345";
    
    [FWNetworking HTTPRequestHeadersBlcok:^NSDictionary<NSString *,NSString *> * _Nonnull{
        return @{@"key" : @"kong", @"key2" : @"12"};
    }];
    
    [FWNetworking POST:@"CustomUser/register.json" parameters:param completeBlock:^(NSURLSessionDataTask *task, id  _Nullable responseObject, BOOL success) {
        
        asuccess = success;
        if (!success) {
            NSLog(@"error %@", responseObject);
            if (((NSError *)responseObject).code == NetworkingErrorCodeReachable) {
                NSLog(@"无网络");
            }
            return;
        }
//        NSLog(@"%@", task.response.URL);
//        NSLog(@"%@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:10.0 handler:nil];
    
    XCTAssertTrue(asuccess, @"请求成功");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
