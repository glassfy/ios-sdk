//
//  GLAPIManager.m
//  Glassfy
//
//  Created by Luca Garbolino on 18/12/20.
//

#import <CommonCrypto/CommonDigest.h>
#import "GLSysInfo.h"
#import "GLAPIManager.h"
#import "Glassfy+Private.h"
#import "SKProduct+GLEncode.h"
#import "SKPaymentTransaction+GLEncode.h"
#import "GLError.h"
#import "GLLogger.h"
#import "GLCacheManager.h"

#define BASE_URL @"https://api.glassfy.net/v0"

typedef void(^GLBaseAPICompletion)(id<GLDecodeProtocol>, NSError *);

@interface GLAPIManager()
@property(nonatomic, strong) GLCacheManager *cache;
@property(nonatomic, strong) NSURLSession *session;
@property(nonatomic, strong) NSString *apiKey;
@property(nonatomic, strong) NSString *glii;

@property(nonatomic, strong) NSMutableDictionary<NSString*,NSMutableArray<GLBaseAPICompletion>*> *completions;
@end

@implementation GLAPIManager

- (instancetype)initWithApiKey:(NSString *)apiKey cache:(GLCacheManager *)cache
{
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    NSString *glii = GLSysInfo.installationInfo;
    return [self initWithApiKey:apiKey cache:cache session:session glii:glii];
}

- (instancetype)initWithApiKey:(NSString *)apiKey cache:(GLCacheManager *)cache session:(NSURLSession *)session glii:(NSString *)glii
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
    NSString *userId = self.cache.userId;
    NSMutableArray *queryItems = [NSMutableArray array];
    [queryItems addObject:[NSURLQueryItem queryItemWithName:@"installationid" value:installationId]];
    if (userId) {
        [queryItems addObject:[NSURLQueryItem queryItemWithName:@"userid" value:userId]];
    }
    [queryItems addObject:[NSURLQueryItem queryItemWithName:@"glii" value:self.glii]];
    baseURL.queryItems = [queryItems copy];
    
    return baseURL;
}


#pragma mark - public

- (void)getInitWithInfoWithCompletion:(GLGetInitCompletion)block
{
    NSURLComponents *url = [self baseURL];
    url.path = [url.path stringByAppendingPathComponent:@"init"];
    
    NSURLRequest *req = [self authorizedRequestWithComponents:url];
    [self callApiWithRequest:req response:GLAPIInitResponse.class completion:block];
}

- (void)getOfferingsWithCompletion:(GLGetOfferingsCompletion)block
{
    NSURLComponents *url = [self baseURL];
    url.path = [url.path stringByAppendingPathComponent:@"offerings"];

    NSURLRequest *req = [self authorizedRequestWithComponents:url];
    [self callApiWithRequest:req response:GLAPIOfferingsResponse.class completion:block];
}

- (void)getOfferingWithIdentifier:(NSString *)identifier completion:(GLGetOfferingsCompletion)block
{
    NSURLComponents *url = [self baseURL];
    url.path = [url.path stringByAppendingPathComponent:@"offerings"];
    NSMutableArray<NSURLQueryItem*> *queryItems = [(url.queryItems ?: @[]) mutableCopy];
    [queryItems addObject:[NSURLQueryItem queryItemWithName:@"identifier" value:identifier]];
    url.queryItems = queryItems;

    NSURLRequest *req = [self authorizedRequestWithComponents:url];
    [self callApiWithRequest:req response:GLAPIOfferingsResponse.class completion:block];
}

- (void)getSignatureForProductId:(NSString *)productid
                         offerId:(NSString *)offerId
                      completion:(GLGetSignatureCompletion)block
{
    NSURLComponents *url = [self baseURL];
    url.path = [url.path stringByAppendingPathComponent:@"signature"];
    NSMutableArray<NSURLQueryItem*> *queryItems = [(url.queryItems ?: @[]) mutableCopy];
    [queryItems addObject:[NSURLQueryItem queryItemWithName:@"productid" value:productid]];
    [queryItems addObject:[NSURLQueryItem queryItemWithName:@"subscriptionofferid" value:offerId]];
    [queryItems addObject:[NSURLQueryItem queryItemWithName:@"appbundleid" value:NSBundle.mainBundle.bundleIdentifier]];
    url.queryItems = queryItems;

    NSURLRequest *req = [self authorizedRequestWithComponents:url];
    [self callApiWithRequest:req response:GLAPISignatureResponse.class completion:block];
}

- (void)getPermissionsWithCompletion:(GLGetPermissionsCompletion)block
{
    NSURLComponents *url = [self baseURL];
    url.path = [url.path stringByAppendingPathComponent:@"permissions"];
    
    NSURLRequest *req = [self authorizedRequestWithComponents:url];
    [self callApiWithRequest:req response:GLAPIPermissionsResponse.class completion:block];
}

- (void)getPermissionWithIdentifier:(NSString *)identifier completion:(GLGetPermissionsCompletion)block
{
    NSURLComponents *url = [self baseURL];
    url.path = [url.path stringByAppendingPathComponent:@"permissions"];
    NSMutableArray<NSURLQueryItem*> *queryItems = [(url.queryItems ?: @[]) mutableCopy];
    [queryItems addObject:[NSURLQueryItem queryItemWithName:@"permissionidentifier" value:identifier]];
    url.queryItems = queryItems;

    NSURLRequest *req = [self authorizedRequestWithComponents:url];
    [self callApiWithRequest:req response:GLAPIPermissionsResponse.class completion:block];
}

- (void)postProducts:(NSArray<SKProduct *> *)products completion:(GLBaseCompletion)block
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
        err = GLError.encodeData;
    }
    else {
        body = [NSJSONSerialization dataWithJSONObject:bodyEncoded options:kNilOptions error:&err];
    }
    
    if (err) {
        dispatch_async(Glassfy.shared.glqueue, ^{
            GLBaseCompletion completion = block;
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
    [self callApiWithRequest:req response:GLAPIBaseResponse.class completion:block];
}

- (void)postReceipt:(NSData *)receipt
            product:(SKProduct *)product
        transaction:(SKPaymentTransaction *)transaction
         completion:(GLGetPermissionsCompletion)block
{
    NSMutableDictionary *bodyEncoded = [NSMutableDictionary dictionary];
    bodyEncoded[@"receiptdata"] = [receipt base64EncodedStringWithOptions:kNilOptions];
    bodyEncoded[@"productinfo"] = [product encodedObject];
    bodyEncoded[@"transactioninfo"] = [transaction encodedObject];
    
    NSError *err;
    NSData *body;
    if (![NSJSONSerialization isValidJSONObject:bodyEncoded]) {
        err = GLError.encodeData;
    }
    else {
        body = [NSJSONSerialization dataWithJSONObject:bodyEncoded options:kNilOptions error:&err];
    }
    if (err || !receipt) {
        dispatch_async(Glassfy.shared.glqueue, ^{
            GLGetPermissionsCompletion completion = block;
            if (completion) {
                completion(nil, err ?: GLError.missingReceipt);
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
    [self callApiWithRequest:req response:GLAPIPermissionsResponse.class completion:block];
}

- (void)postLogoutWithCompletion:(GLLogoutCompletion _Nullable)block
{
    NSURLComponents *url = [self baseURL];
    url.path = [url.path stringByAppendingPathComponent:@"logout"];
    
    NSMutableURLRequest *req = [self authorizedRequestWithComponents:url];
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req setHTTPMethod:@"POST"];
    [self callApiWithRequest:req response:GLAPIBaseResponse.class completion:block];
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
                  response:(Class<GLDecodeProtocol>)R
                completion:(GLBaseAPICompletion)block
{
    NSString *reqSignature = [self requestSignature:req];
    if (self.completions[reqSignature]) {
        GLLog(@"API [%@] IN FLIGHT %@?%@", [reqSignature substringToIndex:3], req.URL.lastPathComponent, req.URL.query);
        if (block) {
            NSMutableArray *arr = self.completions[reqSignature];
            [arr addObject:[block copy]];
        }
        return;
    }
    else {
        GLLog(@"API [%@] START %@?%@", [reqSignature substringToIndex:3], req.URL.lastPathComponent, req.URL.query);
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
        
        GLLogInfo(@"API [%@] RESPONSE: %@", [reqSignature substringToIndex:3], [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        
        dispatch_async(Glassfy.shared.glqueue, ^{
            NSArray *completions = weakSelf.completions[reqSignature];
            weakSelf.completions[reqSignature] = nil;
            for (GLBaseAPICompletion c in completions) {
                if (err) {
                    GLLogErr(@"API [%@] ERROR: %@", [reqSignature substringToIndex:3], err);
                    
                    c(nil, err);
                }
                else {
                    c(res, nil);
                }
                GLLog(@"API [%@] END", [reqSignature substringToIndex:3]);
            }
        });
    }] resume];
}


- (NSString *)requestSignature:(NSURLRequest *)req
{
    NSString *(^md5)(const char *, NSUInteger) = ^NSString *(const char *data, NSUInteger len)
    {
        if (!data) {
            return @"";
        }

        unsigned char md[CC_MD5_DIGEST_LENGTH];
        CC_MD5(data, (CC_LONG) (len > UINT32_MAX ? UINT32_MAX : len) , md);

        NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
        for (unsigned int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
            [output appendFormat:@"%02x", md[i]];
            md[i] = 0;
        }
        return output;
    };

    const char *data;
    NSUInteger len;
    
    data = req.URL.absoluteString.UTF8String;
    len = [req.URL.absoluteString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlMD5 = md5(data, len);
    
    data = req.HTTPBody.bytes;
    len = req.HTTPBody.length;
    NSString *bodyMD5 = md5(data, len);
    
    if (bodyMD5) {
        NSString *md5Str = [urlMD5 stringByAppendingString:bodyMD5];
        data = md5Str.UTF8String;
        len = [md5Str lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        return md5(data, len);
    }
    else {
        return urlMD5;
    }
}

@end
