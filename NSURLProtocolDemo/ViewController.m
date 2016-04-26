//
//  ViewController.m
//  NSURLProtocolDemo
//
//  Created by 陈爱彬 on 16/4/22.
//  Copyright © 2016年 陈爱彬. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    UISwitch *_sw;
    UILabel *_tip;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //读取当前开发环境
    NSString *currentServer = [[NSUserDefaults standardUserDefaults] valueForKey:@"currentServer"];
    //显示UI界面
    _sw = [[UISwitch alloc] initWithFrame:CGRectMake(100, 100, 100, 40)];
    [_sw addTarget:self action:@selector(onServerChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_sw];
    _tip = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    _tip.center = CGPointMake(150, 160);
    _tip.backgroundColor = [UIColor clearColor];
    _tip.textColor = [UIColor blackColor];
    _tip.textAlignment = NSTextAlignmentCenter;
    if ([currentServer isEqualToString:@"production"]) {
        _tip.text = @"当前环境：正式环境";
        [_sw setOn:YES];
    }else if ([currentServer isEqualToString:@"dev"]) {
        _tip.text = @"当前环境：测试环境";
        [_sw setOn:NO];
    }
    [self.view addSubview:_tip];
    UIButton *fetchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    fetchButton.frame = CGRectMake(100, 200, 100, 40);
    [fetchButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [fetchButton setTitle:@"Fetch" forState:UIControlStateNormal];
    [fetchButton addTarget:self action:@selector(fetchInfo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:fetchButton];
}
//切换了网络环境
- (void)onServerChanged:(UISwitch *)sw
{
    if (sw.isOn) {
        [[NSUserDefaults standardUserDefaults] setValue:@"production" forKey:@"currentServer"];
        _tip.text = @"当前环境：正式环境";
    }else{
        [[NSUserDefaults standardUserDefaults] setValue:@"dev" forKey:@"currentServer"];
        _tip.text = @"当前环境：测试环境";
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}
//请求网络信息
- (void)fetchInfo
{
#warning 替换成自己项目中的url
    NSURL *url = [NSURL URLWithString:@"http://www.yourAppUrl.com:80/yourProject/api"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = 10.f;
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if (connectionError) {
            NSLog(@"请求error:%@",connectionError);
        }else{
            NSString *requestURLString = response.URL.absoluteString;
            NSLog(@"请求地址是:%@",requestURLString);
//            NSLog(@"请求成功:%@",response);
        }
    }];
}

@end
