//
//  GLAPIManager.h
//  Glassfy
//
//  Created by Luca Garbolino on 18/12/20.
//

#import <Foundation/Foundation.h>
#import "GLAPIInitResponse.h"
#import "GLAPIPermissionsResponse.h"
#import "GLAPIOfferingsResponse.h"
#import "GLAPISignatureResponse.h"
@class SKProduct;
@class SKPaymentTransaction;
@class GLCacheManager;

typedef void(^GLGetInitCompletion)(GLAPIInitResponse* _Nullable, NSError* _Nullable);
typedef void(^GLGetPermissionsCompletion)(GLAPIPermissionsResponse* _Nullable, NSError* _Nullable);
typedef void(^GLGetOfferingsCompletion)(GLAPIOfferingsResponse* _Nullable, NSError* _Nullable);
typedef void(^GLGetSignatureCompletion)(GLAPISignatureResponse* _Nullable, NSError* _Nullable);
typedef void(^GLBaseCompletion)(GLAPIBaseResponse* _Nullable, NSError* _Nullable);

typedef GLBaseCompletion GLProductsCompletion;
typedef GLBaseCompletion GLLogoutCompletion;


NS_ASSUME_NONNULL_BEGIN

@interface GLAPIManager : NSObject
@property(nonatomic, readonly) NSString *apiKey;

- (instancetype)initWithApiKey:(NSString *)apiKey cache:(GLCacheManager *)cache;

- (void)getInitWithInfoWithCompletion:(GLGetInitCompletion _Nullable)block;

- (void)getOfferingsWithCompletion:(GLGetOfferingsCompletion _Nullable)block;
- (void)getOfferingWithIdentifier:(NSString *)identifier completion:(GLGetOfferingsCompletion _Nullable)block;

- (void)getPermissionsWithCompletion:(GLGetPermissionsCompletion _Nullable)block;
- (void)getPermissionWithIdentifier:(NSString *)identifier completion:(GLGetPermissionsCompletion _Nullable)block;

- (void)postProducts:(NSArray<SKProduct *> *)products
          completion:(GLProductsCompletion _Nullable)block;

- (void)postReceipt:(NSData *)receipt
            product:(SKProduct *_Nullable)product
        transaction:(SKPaymentTransaction *_Nullable)transaction
         completion:(GLGetPermissionsCompletion _Nullable)block;

- (void)postLogoutWithCompletion:(GLLogoutCompletion _Nullable)block;

- (void)getSignatureForProductId:(NSString *)productId offerId:(NSString *)offerId completion:(GLGetSignatureCompletion _Nullable)block;

@end

NS_ASSUME_NONNULL_END
