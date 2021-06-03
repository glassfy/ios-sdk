//
//  GYAPIManager.m
//  Glassfy
//
//  Created by Luca Garbolino on 18/12/20.
//

#import <CommonCrypto/CommonDigest.h>
#import "GYSysInfo.h"
#import "GYAPIManager.h"
#import "Glassfy+Private.h"
#import "SKProduct+GYEncode.h"
#import "SKPaymentTransaction+GYEncode.h"
#import "GYError.h"
#import "GYLogger.h"
#import "GYCacheManager.h"
#import "GYUtils.h"
#import "GYUserProperties+Private.h"

#define BASE_URL @"https://api.glassfy.net/v0"

typedef void(^GYBaseAPICompletion)(id<GYDecodeProtocol>, NSError *);

@interface GYAPIManager()
@property(nonatomic, strong) GYCacheManager *cache;
@property(nonatomic, strong) NSURLSession *session;
@property(nonatomic, strong) NSString *apiKey;
@property(nonatomic, strong) NSString *glii;

@property(nonatomic, strong) NSMutableDictionary<NSString*,NSMutableArray<GYBaseAPICompletion>*> *completions;
@end

@implementation GYAPIManager

- (instancetype)initWithApiKey:(NSString *)apiKey cache:(GYCacheManager *)cache
{
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    NSString *glii = GYSysInfo.installationInfo;
    return [self initWithApiKey:apiKey cache:cache session:session glii:glii];
}

- (instancetype)initWithApiKey:(NSString *)apiKey cache:(GYCacheManager *)cache session:(NSURLSession *)session glii:(NSString *)glii
{
    self = [super init];
    if (self) {
        self.apiKey = apiKey;
        self.session = session;
        self.glii = glii;
        self.cache = cache;
        
        self.completions = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSURLComponents *)baseURL
{
    NSURLComponents *baseURL = [NSURLComponents componentsWithString:BASE_URL];
    
    NSString *installationId = self.cache.installationId;
    NSMutableArray *queryItems = [NSMutableArray array];
    [queryItems addObject:[NSURLQueryItem queryItemWithName:@"installationid" value:installationId]];
    [queryItems addObject:[NSURLQueryItem queryItemWithName:@"glii" value:self.glii]];
    baseURL.queryItems = [queryItems copy];
    
    return baseURL;
}


#pragma mark - public

- (void)getInitWithInfoWithCompletion:(GYGetInitCompletion)block
{
    NSURLComponents *url = [self baseURL];
    url.path = [url.path stringByAppendingPathComponent:@"init"];
    
    NSURLRequest *req = [self authorizedRequestWithComponents:url];
    [self callApiWithRequest:req response:GYAPIInitResponse.class completion:block];
}

- (void)getOfferingsWithCompletion:(GYGetOfferingsCompletion)block
{
    NSURLComponents *url = [self baseURL];
    url.path = [url.path stringByAppendingPathComponent:@"offerings"];

    NSURLRequest *req = [self authorizedRequestWithComponents:url];
    [self callApiWithRequest:req response:GYAPIOfferingsResponse.class completion:block];
}

- (void)getSignatureForProductId:(NSString *)productid
                         offerId:(NSString *)offerId
                      completion:(GYGetSignatureCompletion)block
{
    NSURLComponents *url = [self baseURL];
    url.path = [url.path stringByAppendingPathComponent:@"signature"];
    NSMutableArray<NSURLQueryItem*> *queryItems = [(url.queryItems ?: @[]) mutableCopy];
    [queryItems addObject:[NSURLQueryItem queryItemWithName:@"productid" value:productid]];
    [queryItems addObject:[NSURLQueryItem queryItemWithName:@"subscriptionofferid" value:offerId]];
    [queryItems addObject:[NSURLQueryItem queryItemWithName:@"appbundleid" value:NSBundle.mainBundle.bundleIdentifier]];
    url.queryItems = queryItems;

    NSURLRequest *req = [self authorizedRequestWithComponents:url];
    [self callApiWithRequest:req response:GYAPISignatureResponse.class completion:block];
}

- (void)getPermissionsWithCompletion:(GYGetPermissionsCompletion)block
{
    NSURLComponents *url = [self baseURL];
    url.path = [url.path stringByAppendingPathComponent:@"permissions"];
    
    NSURLRequest *req = [self authorizedRequestWithComponents:url];
    [self callApiWithRequest:req response:GYAPIPermissionsResponse.class completion:block];
}

- (void)postProducts:(NSArray<SKProduct *> *)products completion:(GYBaseCompletion)block
{
    NSMutableArray *productsEncoded = [NSMutableArray array];
    for (SKProduct *p in products) {
        NSDictionary *pEncoded = [p encodedObject];
        if (pEncoded) {
            [productsEncoded addObject:pEncoded];
        }
    }
    NSDictionary *bodyEncoded = @{@"productsinfo": productsEncoded};
    
    NSError *err;
    NSData *body;
    if (![NSJSONSerialization isValidJSONObject:bodyEncoded]) {
        err = GYError.encodeData;
    }
    else {
        body = [NSJSONSerialization dataWithJSONObject:bodyEncoded options:kNilOptions error:&err];
    }
    
    if (err) {
        dispatch_async(Glassfy.shared.glqueue, ^{
            GYBaseCompletion completion = block;
            if (completion) {
                completion(nil, err);
            }
        });
        return;
    }
    
    NSURLComponents *url = [self baseURL];
    url.path = [url.path stringByAppendingPathComponent:@"products"];
    
    NSMutableURLRequest *req = [self authorizedRequestWithComponents:url];
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:body];
    [self callApiWithRequest:req response:GYAPIBaseResponse.class completion:block];
}

- (void)postReceipt:(NSData *)receipt
            product:(SKProduct *)product
        transaction:(SKPaymentTransaction *)transaction
         completion:(GYGetPermissionsCompletion)block
{
    NSMutableDictionary *bodyEncoded = [NSMutableDictionary dictionary];
    bodyEncoded[@"receiptdata"] = [receipt base64EncodedStringWithOptions:kNilOptions];
    bodyEncoded[@"productinfo"] = [product encodedObject];
    bodyEncoded[@"transactioninfo"] = [transaction encodedObject];
    
    NSError *err;
    NSData *body;
    if (![NSJSONSerialization isValidJSONObject:bodyEncoded]) {
        err = GYError.encodeData;
    }
    else {
        body = [NSJSONSerialization dataWithJSONObject:bodyEncoded options:kNilOptions error:&err];
    }
    if (err || !receipt) {
        dispatch_async(Glassfy.shared.glqueue, ^{
            GYGetPermissionsCompletion completion = block;
            if (completion) {
                completion(nil, err ?: GYError.missingReceipt);
            }
        });
        return;
    }
    
    NSURLComponents *url = [self baseURL];
    url.path = [url.path stringByAppendingPathComponent:@"receipt"];
    
    NSMutableURLRequest *req = [self authorizedRequestWithComponents:url];
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:body];
    [self callApiWithRequest:req response:GYAPIPermissionsResponse.class completion:block];
}

- (void)postLogoutWithCompletion:(GYLogoutCompletion _Nullable)block
{
    NSURLComponents *url = [self baseURL];
    url.path = [url.path stringByAppendingPathComponent:@"logout"];
    
    NSMutableURLRequest *req = [self authorizedRequestWithComponents:url];
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req setHTTPMethod:@"POST"];
    [self callApiWithRequest:req response:GYAPIBaseResponse.class completion:block];
}

- (void)postLogin:(NSString *)userId withCompletion:(GYLoginCompletion _Nullable)block
{
    NSURLComponents *url = [self baseURL];
    url.path = [url.path stringByAppendingPathComponent:@"login"];
    
    NSMutableDictionary *bodyEncoded = [NSMutableDictionary dictionary];
    bodyEncoded[@"userid"] = userId;
    
    NSError *err;
    NSData *body;
    if (![NSJSONSerialization isValidJSONObject:bodyEncoded]) {
        err = GYError.encodeData;
    }
    else {
        body = [NSJSONSerialization 
                dataWithJSONObject:bodyEncoded options:kNilOptions error:&err];
    }
    if (err) {
        dispatch_async(Glassfy.shared.glqueue, ^{
            GYLoginCompletion completion = block;
            if (completion) {
                completion(nil, err);
            }
        });
        return;
    }
    
    NSMutableURLRequest *req = [self authorizedRequestWithComponents:url];
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:body];
    [self callApiWithRequest:req response:GYAPIBaseResponse.class completion:block];
}

- (void)putLastSeen
{
    NSURLComponents *url = [self baseURL];
    url.path = [url.path stringByAppendingPathComponent:@"lastseen"];
    NSMutableURLRequest *req = [self authorizedRequestWithComponents:url];
    [req setHTTPMethod:@"PUT"];
    [self callApiWithRequest:req response:nil completion:nil];
}

- (void)postProperty:(GYUserPropertyType)property obj:(id _Nullable)obj completion:(GYGetPropertiesCompletion _Nullable)block
{
    NSURLComponents *url = [self baseURL];
    url.path = [url.path stringByAppendingPathComponent:@"property"];
    
    NSString *propertyStr = [GYUserProperties stringWithPropertyType:property];
    NSDictionary *bodyEncoded = @{propertyStr: obj ?: NSNull.null};
    
    NSError *err;
    NSData *body;
    if (![NSJSONSerialization isValidJSONObject:bodyEncoded]) {
        err = GYError.encodeData;
    }
    else {
        body = [NSJSONSerialization dataWithJSONObject:bodyEncoded options:kNilOptions error:&err];
    }
    
    if (body.length > 1048576) {
        err = GYError.exceedSizeLimits;
    }
    
    if (err) {
        dispatch_async(Glassfy.shared.glqueue, ^{
            GYGetPropertiesCompletion completion = block;
            if (completion) {
                completion(nil, err);
            }
        });
        return;
    }
    
    NSMutableURLRequest *req = [self authorizedRequestWithComponents:url];
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:body];
    [self callApiWithRequest:req response:GYAPIPropertiesResponse.class completion:block];
}

- (void)getPropertiesWithCompletion:(GYGetPropertiesCompletion _Nullable)block
{
    NSURLComponents *url = [self baseURL];
    url.path = [url.path stringByAppendingPathComponent:@"property"];
    
    NSURLRequest *req = [self authorizedRequestWithComponents:url];
    [self callApiWithRequest:req response:GYAPIPropertiesResponse.class completion:block];
}

#pragma mark - private

- (NSMutableURLRequest *_Nullable)authorizedRequestWithComponents:(NSURLComponents *)urlComponents
{
    NSMutableURLRequest *req;
    if (urlComponents.URL) {
        req = [NSMutableURLRequest requestWithURL:urlComponents.URL];
        [req addValue:[@"Bearer " stringByAppendingString:self.apiKey] forHTTPHeaderField:@"Authorization"];
    }
    return req;
}

- (void)callApiWithRequest:(NSURLRequest *)req
                  response:(Class<GYDecodeProtocol>)R
                completion:(GYBaseAPICompletion)block
{
    NSString *reqSignature = [GYUtils requestSignature:req];
    if (self.completions[reqSignature]) {
        GYLog(@"API [%@] IN FLIGHT %@?%@", [reqSignature substringToIndex:3], req.URL.lastPathComponent, req.URL.query);
        if (block) {
            NSMutableArray *arr = self.completions[reqSignature];
            [arr addObject:[block copy]];
        }
        return;
    }
    else {
        GYLog(@"API [%@] START %@?%@", [reqSignature substringToIndex:3], req.URL.lastPathComponent, req.URL.query);
        if (block) {
            self.completions[reqSignature] = [NSMutableArray arrayWithObject:[block copy]];
        }
        else {
            self.completions[reqSignature] = [NSMutableArray array];
        }
    }
    
    __weak typeof(self) weakSelf = self;
    [[self.session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        //ToDO test NSHTTPURLResponse code != 200?
        id obj;
        NSError *err = error;
        if (!err) {
            obj = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
        }
        id res;
        if (!err) {
            res = [[(Class)R alloc] initWithObject:obj error:&err];
        }
        
        GYLogInfo(@"API [%@] RESPONSE: %@", [reqSignature substringToIndex:3], [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        
        dispatch_async(Glassfy.shared.glqueue, ^{
            NSArray *completions = weakSelf.completions[reqSignature];
            weakSelf.completions[reqSignature] = nil;
            for (GYBaseAPICompletion c in completions) {
                if (err) {
                    GYLogErr(@"API [%@] ERROR: %@", [reqSignature substringToIndex:3], err);
                    
                    c(nil, err);
                }
                else {
                    c(res, nil);
                }
                GYLog(@"API [%@] END", [reqSignature substringToIndex:3]);
            }
        });
    }] resume];
}

@end
