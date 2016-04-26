//
//  CCHTTPProtocol.m
//  NSURLProtocolDemo
//
//  Created by 陈爱彬 on 16/4/22.
//  Copyright © 2016年 陈爱彬. All rights reserved.
//

#import "CCHTTPProtocol.h"

static NSString *const kHTTPURLProtocolHandledKey = @"ccURLProtocolHandledKey";
static NSString *const kAPIFilterPath = @"yourProject/api";

@interface CCHTTPProtocol()
<NSURLConnectionDelegate,
NSURLConnectionDataDelegate>

@property (nonatomic,weak) NSURLConnection *connection;
@end

@implementation CCHTTPProtocol

#pragma mark - 必须实现的方法
+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    NSString *scheme = [[request URL] scheme];
    NSString *urlString = [[request URL] absoluteString];
    //只处理http和https请求,并且判断是否包含网络请求中的特定字符串，如果包含则是自己的服务器，替换请求
    if (([scheme caseInsensitiveCompare:@"http"] == NSOrderedSame || [scheme caseInsensitiveCompare:@"https"] == NSOrderedSame) && [urlString containsString:kAPIFilterPath]) {
        //看看是否已经处理过了，防止无限循环
        if ([NSURLProtocol propertyForKey:kHTTPURLProtocolHandledKey inRequest:request]) {
            return NO;
        }
        return YES;
    }
    return NO;
}
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}
+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b
{
    return [super requestIsCacheEquivalent:a toRequest:b];
}
- (void)startLoading
{
    NSMutableURLRequest *request = [[self request] mutableCopy];
    //自定义request，修改Host和Port
    request = [self redirectHostAndPortInRequest:request];
    //标示request已经处理过了，防止无限循环
    [NSURLProtocol setProperty:@(YES) forKey:kHTTPURLProtocolHandledKey inRequest:request];
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
}
- (void)stopLoading
{
    [self.connection cancel];
    self.connection = nil;
}
#pragma mark - Helper
//修改请求的Host和Port
- (NSMutableURLRequest *)redirectHostAndPortInRequest:(NSMutableURLRequest *)request
{
    if ([request.URL host].length == 0) {
        return request;
    }
    NSString *originURLString = [request.URL absoluteString];
    NSString *originHost = [request.URL host];
    NSNumber *originPort = [request.URL port];
    NSRange hostRange = [originURLString rangeOfString:originHost];
    if (hostRange.location == NSNotFound) {
        return request;
    }
    //读取当前的开发环境,这里暂用NSUserDefaults做效果
    NSDictionary *serverInfo = [[NSUserDefaults standardUserDefaults] valueForKey:@"ccServerInfo"];
    NSString *currentServer = [[NSUserDefaults standardUserDefaults] valueForKey:@"currentServer"];
    NSString *host = serverInfo[currentServer][@"host"];
    NSString *port = serverInfo[currentServer][@"port"];
    //重定向请求Host
    NSString *urlString = [originURLString stringByReplacingCharactersInRange:hostRange withString:host];
    //替换端口号
    if (originPort) {
        urlString = [urlString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@",originPort] withString:port];
    }
    //修改request的URL
    NSURL *url = [NSURL URLWithString:urlString];
    request.URL = url;
    return request;
}
#pragma mark - NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.client URLProtocol:self didLoadData:data];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self.client URLProtocolDidFinishLoading:self];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.client URLProtocol:self didFailWithError:error];
}
@end
