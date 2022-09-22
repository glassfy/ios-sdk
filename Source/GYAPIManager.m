//
//  GYAPIManager.m
//  Glassfy
//
//  Created by Luca Garbolino on 18/12/20.
//

#import <CommonCrypto/CommonDigest.h>
#import "Glassfy+Private.h"
#import "GYUserProperties+Private.h"
#import "GYSku+Private.h"
#import "SKPaymentTransaction+GYEncode.h"
#import "SKProduct+GYEncode.h"
#import "GYSysInfo.h"
#import "GYAPIManager.h"
#import "GYError.h"
#import "GYLogger.h"
#import "GYCacheManager.h"
#import "GYUtils.h"

#define BASE_URL @"https://api.glassfy.io"

typedef NSString *     GYAPIVersion;
#define GYAPIVersionV0 @"v0"
#define GYAPIVersionV1 @"v1"

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

- (NSURLComponents *)baseURL:(GYAPIVersion)apiVersion
{
    NSURLComponents *baseURL = [NSURLComponents componentsWithString:[BASE_URL stringByAppendingPathComponent:apiVersion]];
    
    NSMutableArray *queryItems = [NSMutableArray array];
    [queryItems addObject:[NSURLQueryItem queryItemWithName:@"installationid" value:self.cache.installationId]];
    [queryItems addObject:[NSURLQueryItem queryItemWithName:@"glii" value:self.glii]];
    baseURL.queryItems = [queryItems copy];

    return baseURL;
}

- (NSURLComponents *)baseURLV0
{
    return [self baseURL:GYAPIVersionV0];
}

- (NSURLComponents *)baseURLV1
{
    return [self baseURL:GYAPIVersionV1];
}

#pragma mark - public

- (void)getInitWithInfoWithCompletion:(GYGetInitCompletion)block
{
    NSURLComponents *url = [self baseURLV0];
    url.path = [url.path stringByAppendingPathComponent:@"init"];
    
    NSURLRequest *req = [self authorizedRequestWithComponents:url];
    [self callApiWithRequest:req response:GYAPIInitResponse.class completion:block];
}

- (void)getSkuWithProductId:(NSString *)productid
              promotionalId:(NSString *)promoid
             withCompletion:(GYGetSkuCompletion)block
{
    [self getSkuWithId:nil productId:productid promotionalId:promoid store:GYStoreAppStore withCompletion:block];
}

- (void)getSkuWithId:(NSString *)skuid
               store:(GYStore)store
      withCompletion:(GYGetSkuCompletion)block
{
    [self getSkuWithId:skuid productId:nil promotionalId:nil store:store withCompletion:block];
}

- (void)getSkuWithId:(NSString *)skuid
           productId:(NSString *)productid
       promotionalId:(NSString *)promoid
               store:(GYStore)store
      withCompletion:(GYGetSkuCompletion)block
{
    NSURLComponents *url = [self baseURLV1];
    url.path = [url.path stringByAppendingPathComponent:@"sku"];
    
    NSMutableArray<NSURLQueryItem*> *queryItems = [(url.queryItems ?: @[]) mutableCopy];
    if (skuid) {
        [queryItems addObject:[NSURLQueryItem queryItemWithName:@"identifier" value:skuid]];
    }
    [queryItems addObject:[NSURLQueryItem queryItemWithName:@"store" value:[NSString stringWithFormat:@"%lu", (unsigned long)store]]];
    if (productid) {
        [queryItems addObject:[NSURLQueryItem queryItemWithName:@"productid" value:productid]];
    }
    if (promoid && promoid.length > 0) {
        [queryItems addObject:[NSURLQueryItem queryItemWithName:@"promotionalid" value:promoid]];
    }
    NSString *pricelocale = [NSLocale.currentLocale objectForKey:NSLocaleCurrencyCode];
    if (pricelocale && pricelocale.length > 0) {
        [queryItems addObject:[NSURLQueryItem queryItemWithName:@"pricelocale" value:pricelocale]];
    }
    url.queryItems = queryItems;

    NSURLRequest *req = [self authorizedRequestWithComponents:url];
    [self callApiWithRequest:req response:GYAPISkuResponse.class completion:block];
}

- (void)getOfferingsWithCompletion:(GYGetOfferingsCompletion)block
{
    NSURLComponents *url = [self baseURLV0];
    url.path = [url.path stringByAppendingPathComponent:@"offerings"];

    NSURLRequest *req = [self authorizedRequestWithComponents:url];
    [self callApiWithRequest:req response:GYAPIOfferingsResponse.class completion:block];
}

- (void)getSignatureForProductId:(NSString *)productid
                         offerId:(NSString *)offerId
                      completion:(GYGetSignatureCompletion)block
{
    NSURLComponents *url = [self baseURLV0];
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
    NSURLComponents *url = [self baseURLV1];
    url.path = [url.path stringByAppendingPathComponent:@"permissions"];
    
    NSURLRequest *req = [self authorizedRequestWithComponents:url];
    [self callApiWithRequest:req response:GYAPIPermissionsResponse.class completion:block];
}

- (void)postProducts:(NSArray<SKProduct*> *)products completion:(GYBaseCompletion)block
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
    
    NSURLComponents *url = [self baseURLV0];
    url.path = [url.path stringByAppendingPathComponent:@"products"];
    
    NSMutableURLRequest *req = [self authorizedRequestWithComponents:url];
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:body];
    [self callApiWithRequest:req response:GYAPIBaseResponse.class completion:block];
}

- (void)postReceipt:(NSData *)receipt
                sku:(GYSku *)sku
        transaction:(SKPaymentTransaction *)transaction
         completion:(GYGetPermissionsCompletion)block
{
    NSMutableDictionary *bodyEncoded = [NSMutableDictionary dictionary];
    NSDictionary *skuinfo = [sku encodedObject];
    if ([skuinfo isKindOfClass:NSDictionary.class]) {
        [bodyEncoded addEntriesFromDictionary:skuinfo];
    }
    bodyEncoded[@"receiptdata"] = [receipt base64EncodedStringWithOptions:kNilOptions];
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
    
    NSURLComponents *url = [self baseURLV1];
    url.path = [url.path stringByAppendingPathComponent:@"receipt"];
    
    NSMutableURLRequest *req = [self authorizedRequestWithComponents:url];
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:body];
    [self callApiWithRequest:req response:GYAPIPermissionsResponse.class completion:block];
}

- (void)postLogoutWithCompletion:(GYLogoutCompletion _Nullable)block
{
    NSURLComponents *url = [self baseURLV0];
    url.path = [url.path stringByAppendingPathComponent:@"logout"];
    
    NSMutableURLRequest *req = [self authorizedRequestWithComponents:url];
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req setHTTPMethod:@"POST"];
    [self callApiWithRequest:req response:GYAPIBaseResponse.class completion:block];
}

- (void)postLogin:(NSString *)userId withCompletion:(GYLoginCompletion _Nullable)block
{
    NSURLComponents *url = [self baseURLV0];
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
    NSURLComponents *url = [self baseURLV0];
    url.path = [url.path stringByAppendingPathComponent:@"lastseen"];
    NSMutableURLRequest *req = [self authorizedRequestWithComponents:url];
    [req setHTTPMethod:@"PUT"];
    [self callApiWithRequest:req response:nil completion:nil];
}

- (void)postProperty:(GYUserPropertyType)property obj:(id _Nullable)obj completion:(GYPropertyCompletion _Nullable)block
{
    NSURLComponents *url = [self baseURLV1];
    url.path = [url.path stringByAppendingPathComponent:@"property"];
    
    NSDictionary *bodyEncoded = @{property: obj ?: NSNull.null};
    
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
            GYPropertyCompletion completion = block;
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

- (void)postConnectUser:(NSString *_Nullable)customId
             completion:(GYGetConnectCompletion _Nullable)block
{
    NSURLComponents *url = [self baseURLV0];
    url.path = [url.path stringByAppendingPathComponent:@"connect"];
        
    NSDictionary *bodyEncoded = @{@"customid": customId ?: NSNull.null};
    
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
            GYGetConnectCompletion completion = block;
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

- (void)postConnectPaddleLicenseKey:(NSString *)licenseKey
                              force:(BOOL)force
                         completion:(GYGetConnectCompletion _Nullable)block
{
    NSURLComponents *url = [self baseURLV0];
    url.path = [url.path stringByAppendingPathComponent:@"connect"];
        
    NSDictionary *bodyEncoded = @{
        @"store": @(GYStorePaddle),
        @"licensekey": licenseKey,
        @"force": [NSNumber numberWithBool:force]
    };
    
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
            GYGetConnectCompletion completion = block;
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


- (void)getStoreInfoWithCompletion:(GYGetStoreInfo _Nullable)block
{
    NSURLComponents *url = [self baseURLV0];
    url.path = [url.path stringByAppendingPathComponent:@"storeinfo"];
    
    NSURLRequest *req = [self authorizedRequestWithComponents:url];
    [self callApiWithRequest:req response:GYAPIStoreInfoResponse.class completion:block];
}

- (void)getPropertiesWithCompletion:(GYGetPropertiesCompletion _Nullable)block
{
    NSURLComponents *url = [self baseURLV0];
    url.path = [url.path stringByAppendingPathComponent:@"property"];
    
    NSURLRequest *req = [self authorizedRequestWithComponents:url];
    [self callApiWithRequest:req response:GYAPIPropertiesResponse.class completion:block];
}

- (void)getPaywall:(NSString *)paywallId locale:(NSString *)locale completion:(GYGetPaywallCompletion _Nullable)block
{
    NSURLComponents *url = [self baseURLV0];
    url.path = [url.path stringByAppendingPathComponent:@"paywall"];
    
    NSMutableArray<NSURLQueryItem*> *queryItems = [(url.queryItems ?: @[]) mutableCopy];
    [queryItems addObject:[NSURLQueryItem queryItemWithName:@"identifier" value:paywallId]];
    if (locale) {
        [queryItems addObject:[NSURLQueryItem queryItemWithName:@"locale" value:locale]];
    }
    url.queryItems = queryItems;

    NSURLRequest *req = [self authorizedRequestWithComponents:url];
    [self callApiWithRequest:req response:GYAPIPaywallResponse.class completion:block];
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
        GYLog(@"API [%@] In Progress", [reqSignature substringToIndex:3]);
        if (block) {
            NSMutableArray *arr = self.completions[reqSignature];
            [arr addObject:[block copy]];
        }
        return;
    }
    else {
        GYLog(@"API [%@] Start\t/%@", [reqSignature substringToIndex:3], req.URL.lastPathComponent);
        GYLogInfo(@"API [%@] Query:\n?%@", [reqSignature substringToIndex:3], req.URL.query);
        if (block) {
            self.completions[reqSignature] = [NSMutableArray arrayWithObject:[block copy]];
        }
        else {
            self.completions[reqSignature] = [NSMutableArray array];
        }
    }
    
    typeof(self) __weak weakSelf = self;
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
        
        GYLogInfo(@"API [%@] Response:\n%@", [reqSignature substringToIndex:3], err ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:obj options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding] );
        
        dispatch_async(Glassfy.shared.glqueue, ^{
            NSArray *completions = weakSelf.completions[reqSignature];
            weakSelf.completions[reqSignature] = nil;
            for (GYBaseAPICompletion c in completions) {
                if (err) {
                    GYLogErr(@"API [%@] Error: %@", [reqSignature substringToIndex:3], err);
                    
                    c(nil, err);
                }
                else {
                    c(res, nil);
                }
                GYLog(@"API [%@] End", [reqSignature substringToIndex:3]);
            }
        });
    }] resume];
}

@end
